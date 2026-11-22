import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../models/models.dart';
import '../models/notification_item.dart';
import 'api_client.dart';
import 'api_mapper.dart';
import 'auth_service.dart';
import 'local_db.dart';

class DayStat {
  final int done;
  final int inProgress;
  final int overdue;
  const DayStat(this.done, this.inProgress, this.overdue);
}

class ReportData {
  final int total;
  final int done;
  final int overdue;
  final Duration? avgResolution;
  const ReportData({
    required this.total,
    required this.done,
    required this.overdue,
    required this.avgResolution,
  });

  double get successRate => total == 0 ? 0 : done / total;
}

class AppState extends ChangeNotifier {
  final List<Project> _projects = [];
  final List<Task> _tasks = [];
  final List<Member> _members = [];
  final Set<String> _readNotifs = {};

  List<Project> get projects => List.unmodifiable(_projects);
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Member> get members => List.unmodifiable(_members);

  // ---------- Statistiques globales ----------
  int get projectCount => _projects.length;
  int get projectsInProgress =>
      _projects.where((p) => p.status == ProjectStatus.inProgress).length;
  int get projectsDone =>
      _projects.where((p) => p.status == ProjectStatus.done).length;

  int get taskCount => _tasks.length;
  int get tasksDone => _tasks.where((t) => t.status == TaskStatus.done).length;
  int get tasksLate => _tasks.where((t) => t.isLate).length;
  int get tasksActive => taskCount - tasksDone - tasksLate;

  double get globalProgress => taskCount == 0 ? 0 : tasksDone / taskCount;

  // ---------- Par projet ----------
  Project? projectById(String id) {
    for (final p in _projects) {
      if (p.id == id) return p;
    }
    return null;
  }

  List<Task> tasksOf(String projectId) =>
      _tasks.where((t) => t.projectId == projectId).toList();

  int tasksDoneOf(String projectId) =>
      tasksOf(projectId).where((t) => t.status == TaskStatus.done).length;

  int tasksLateOf(String projectId) =>
      tasksOf(projectId).where((t) => t.isLate).length;

  double projectProgress(String projectId) {
    final total = tasksOf(projectId).length;
    return total == 0 ? 0 : tasksDoneOf(projectId) / total;
  }

  bool isProjectLate(Project p) {
    if (p.status == ProjectStatus.done) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return p.deadline.isBefore(today);
  }

  List<Project> get upcomingProjects {
    final list = _projects
        .where((p) => p.status != ProjectStatus.done)
        .toList();
    list.sort((a, b) => a.deadline.compareTo(b.deadline));
    return list.take(2).toList();
  }

  // ---------- Membres ----------
  /// La fiche « membre » de la personne connectée.
  Member? get me {
    final id = AuthService.current?.memberId;
    return id == null ? null : memberById(id);
  }

  /// Seule la cheffe de projet gère les membres.
  bool get isLead => me?.isLead ?? false;

  Member? memberById(String id) {
    for (final m in _members) {
      if (m.id == id) return m;
    }
    return null;
  }

  int tasksOfMember(String memberId) =>
      _tasks.where((t) => t.assignee == memberId).length;

  List<Task> tasksOnDay(DateTime day) => _tasks
      .where(
        (t) =>
            t.dueDate.year == day.year &&
            t.dueDate.month == day.month &&
            t.dueDate.day == day.day,
      )
      .toList();

  // ---------- Notifications (générées automatiquement) ----------
  List<AppNotification> get notifications {
    final list = <AppNotification>[];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (final t in _tasks) {
      if (t.status == TaskStatus.done) continue;
      final due = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
      final diff = due.difference(today).inDays;

      if (diff < 0) {
        list.add(
          AppNotification(
            id: 'overdue_${t.id}',
            type: NotifType.overdue,
            taskId: t.id,
            taskTitle: t.title,
            days: -diff,
          ),
        );
      } else if (diff <= 2) {
        list.add(
          AppNotification(
            id: 'reminder_${t.id}',
            type: NotifType.reminder,
            taskId: t.id,
            taskTitle: t.title,
            days: diff,
          ),
        );
      }

      if (t.assignee != null) {
        final m = memberById(t.assignee!);
        if (m != null) {
          list.add(
            AppNotification(
              id: 'assign_${t.id}_${m.id}',
              type: NotifType.assignment,
              taskId: t.id,
              taskTitle: t.title,
              memberName: m.name,
            ),
          );
        }
      }
    }

    list.sort((a, b) => a.type.index.compareTo(b.type.index));
    return list;
  }

  bool isRead(String id) => _readNotifs.contains(id);

  int get unreadCount =>
      notifications.where((n) => !_readNotifs.contains(n.id)).length;

  /// Notifications filtrées selon les préférences de l'utilisateur
  /// (alertes de retard, rappels, affectations).
  List<AppNotification> notificationsFor({
    required bool overdue,
    required bool reminder,
    required bool assignment,
  }) {
    return notifications.where((n) {
      switch (n.type) {
        case NotifType.overdue:
          return overdue;
        case NotifType.reminder:
          return reminder;
        case NotifType.assignment:
          return assignment;
      }
    }).toList();
  }

  int unreadCountFor({
    required bool overdue,
    required bool reminder,
    required bool assignment,
  }) {
    return notificationsFor(
      overdue: overdue,
      reminder: reminder,
      assignment: assignment,
    ).where((n) => !_readNotifs.contains(n.id)).length;
  }

  void markRead(String id) {
    if (_readNotifs.add(id)) {
      _saveRead();
      notifyListeners();
    }
  }

  void markAllRead() {
    for (final n in notifications) {
      _readNotifs.add(n.id);
    }
    _saveRead();
    notifyListeners();
  }

  // ---------- Graphique : évolution jour par jour ----------
  List<DayStat> statsSeries(int days) {
    final now = DateTime.now();
    return List.generate(days, (i) {
      final day = DateTime(now.year, now.month, now.day - (days - 1 - i));
      final end = DateTime(day.year, day.month, day.day + 1);
      var done = 0;
      var active = 0;
      var overdue = 0;

      for (final t in _tasks) {
        if (!t.createdAt.isBefore(end)) continue;
        final completed =
            t.status == TaskStatus.done &&
            t.completedAt != null &&
            t.completedAt!.isBefore(end);
        if (completed) {
          done++;
          continue;
        }
        final due = DateTime(t.dueDate.year, t.dueDate.month, t.dueDate.day);
        if (due.isBefore(day)) {
          overdue++;
        } else {
          active++;
        }
      }
      return DayStat(done, active, overdue);
    });
  }

  // ---------- Rapports ----------
  /// projectId null = rapport global
  ReportData reportFor(String? projectId) {
    final list = projectId == null ? _tasks : tasksOf(projectId);
    final done = list.where((t) => t.status == TaskStatus.done).toList();

    final times = done
        .where((t) => t.completedAt != null)
        .map((t) => t.completedAt!.difference(t.createdAt))
        .toList();

    Duration? avg;
    if (times.isNotEmpty) {
      final sum = times.fold<int>(0, (a, b) => a + b.inMicroseconds);
      final micro = sum ~/ times.length;
      avg = Duration(microseconds: micro < 0 ? 0 : micro);
    }

    return ReportData(
      total: list.length,
      done: done.length,
      overdue: list.where((t) => t.isLate).length,
      avgResolution: avg,
    );
  }

  // ---------- Synchronisation avec le serveur ----------
  Timer? _refreshTimer;
  String? _readKey;

  /// Éléments supprimés à l'écran mais pas encore supprimés sur le serveur
  /// (on attend la fin du message « Annuler »).
  final Set<String> _pendingDeletes = {};
  final Map<String, Timer> _deleteTimers = {};

  /// À appeler après la connexion : charge les données et les rafraîchit
  /// toutes les 30 secondes (pour voir les changements des collègues).
  Future<void> start() async {
    _readKey = 'readNotifs:${AuthService.current?.id}';
    final saved = await LocalDb.read(_readKey!);
    _readNotifs
      ..clear()
      ..addAll(
        saved == null ? <String>[] : (jsonDecode(saved) as List).cast<String>(),
      );
    await refresh();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => refresh(),
    );
  }

  /// Recharge membres, projets et tâches depuis le serveur.
  /// Hors connexion, on garde simplement ce qui est déjà affiché.
  Future<void> refresh() async {
    try {
      final results = await Future.wait([
        ApiClient.get('/api/members'),
        ApiClient.get('/api/projects'),
        ApiClient.get('/api/tasks'),
      ]);

      final oldTasks = {for (final t in _tasks) t.id: t};
      final members = (results[0] as List)
          .map((j) => memberFromJson(j as Map<String, dynamic>))
          .where((m) => !_pendingDeletes.contains(m.id))
          .toList();
      final projects = (results[1] as List)
          .map((j) => projectFromJson(j as Map<String, dynamic>))
          .where((p) => !_pendingDeletes.contains(p.id))
          .toList();
      final tasks = (results[2] as List)
          .map((j) => taskFromJson(j as Map<String, dynamic>))
          .where(
            (t) =>
                !_pendingDeletes.contains(t.id) &&
                !_pendingDeletes.contains(t.projectId),
          )
          .toList();

      // On garde les pièces jointes déjà chargées (elles sont rechargées
      // à l'ouverture d'une tâche).
      for (final t in tasks) {
        final old = oldTasks[t.id];
        if (old != null) t.attachments.addAll(old.attachments);
      }

      _members
        ..clear()
        ..addAll(members);
      _projects
        ..clear()
        ..addAll(projects);
      _tasks
        ..clear()
        ..addAll(tasks);
      notifyListeners();
    } on ApiException {
      // serveur injoignable : on garde l'affichage actuel
    }
  }

  /// Vide la mémoire à la déconnexion (les données restent sur le serveur).
  void unload() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    for (final t in _deleteTimers.values) {
      t.cancel();
    }
    _deleteTimers.clear();
    _pendingDeletes.clear();
    _projects.clear();
    _tasks.clear();
    _members.clear();
    _readNotifs.clear();
    notifyListeners();
  }

  void _saveRead() {
    final key = _readKey;
    if (key != null) LocalDb.write(key, jsonEncode(_readNotifs.toList()));
  }

  // ---------- Projets ----------
  // Créer / modifier : on attend la réponse du serveur (lance une
  // ApiException en cas de problème, affichée dans le formulaire).
  Future<void> createProject({
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime deadline,
    required ProjectStatus status,
  }) async {
    final json = await ApiClient.post(
      '/api/projects',
      projectBody(
        name: name,
        description: description,
        startDate: startDate,
        deadline: deadline,
        status: status,
      ),
    );
    _projects.add(projectFromJson(json as Map<String, dynamic>));
    notifyListeners();
  }

  Future<void> editProject(
    String id, {
    required String name,
    required String description,
    required DateTime startDate,
    required DateTime deadline,
    required ProjectStatus status,
  }) async {
    final json = await ApiClient.put(
      '/api/projects/$id',
      projectBody(
        name: name,
        description: description,
        startDate: startDate,
        deadline: deadline,
        status: status,
      ),
    );
    final updated = projectFromJson(json as Map<String, dynamic>);
    final i = _projects.indexWhere((p) => p.id == id);
    if (i >= 0) {
      _projects[i] = updated;
    } else {
      _projects.add(updated);
    }
    notifyListeners();
  }

  /// Supprime un projet et ses tâches de l'écran tout de suite ; le serveur
  /// les supprime 6 secondes plus tard, sauf si l'utilisateur annule
  /// (voir [restoreProject]).
  ({Project project, List<Task> tasks})? removeProject(String id) {
    final p = projectById(id);
    if (p == null) return null;
    final removed = tasksOf(id);
    _projects.remove(p);
    _tasks.removeWhere((t) => t.projectId == id);
    _scheduleDelete(id, '/api/projects/$id');
    notifyListeners();
    return (project: p, tasks: removed);
  }

  void restoreProject(Project project, List<Task> tasks) {
    _cancelDelete(project.id);
    _projects.add(project);
    _tasks.addAll(tasks);
    notifyListeners();
  }

  // ---------- Tâches ----------
  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    final json = await ApiClient.post(
      '/api/tasks',
      taskBody(
        projectId: projectId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
      ),
    );
    _tasks.add(taskFromJson(json as Map<String, dynamic>));
    notifyListeners();
  }

  Future<void> editTask(
    String id, {
    required String projectId,
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
  }) async {
    final json = await ApiClient.put(
      '/api/tasks/$id',
      taskBody(
        projectId: projectId,
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
      ),
    );
    final updated = taskFromJson(json as Map<String, dynamic>);
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i >= 0) {
      updated.attachments.addAll(_tasks[i].attachments);
      _tasks[i] = updated;
    } else {
      _tasks.add(updated);
    }
    notifyListeners();
  }

  Task? taskById(String id) {
    for (final t in _tasks) {
      if (t.id == id) return t;
    }
    return null;
  }

  /// Changement de statut : l'écran réagit tout de suite, puis le serveur
  /// confirme. En cas d'échec, on revient à l'ancien statut.
  void setTaskStatus(String id, TaskStatus status) {
    final t = taskById(id);
    if (t == null) return;
    final oldStatus = t.status;
    final oldCompleted = t.completedAt;
    t.status = status;
    t.completedAt = status == TaskStatus.done ? DateTime.now() : null;
    notifyListeners();
    _syncStatus(t, status, oldStatus, oldCompleted);
  }

  Future<void> _syncStatus(
    Task t,
    TaskStatus status,
    TaskStatus oldStatus,
    DateTime? oldCompleted,
  ) async {
    try {
      final json = await ApiClient.patch('/api/tasks/${t.id}/status', {
        'status': taskStatusApi(status),
      });
      t.completedAt = taskFromJson(json as Map<String, dynamic>).completedAt;
    } catch (_) {
      t.status = oldStatus;
      t.completedAt = oldCompleted;
    }
    notifyListeners();
  }

  void assignTask(String taskId, String? memberId) {
    final t = taskById(taskId);
    if (t == null) return;
    final old = t.assignee;
    t.assignee = memberId;
    notifyListeners();
    _syncAssignee(t, old);
  }

  Future<void> _syncAssignee(Task t, String? old) async {
    try {
      await ApiClient.patch('/api/tasks/${t.id}/assignee', {
        'memberId': t.assignee,
      });
    } catch (_) {
      t.assignee = old;
      notifyListeners();
    }
  }

  Task? removeTask(String id) {
    final t = taskById(id);
    if (t == null) return null;
    _tasks.remove(t);
    _scheduleDelete(id, '/api/tasks/$id');
    notifyListeners();
    return t;
  }

  void restoreTask(Task t) {
    _cancelDelete(t.id);
    _tasks.add(t);
    notifyListeners();
  }

  // ---------- Membres ----------
  Future<void> createMember({
    required String name,
    required String role,
    required String email,
  }) async {
    final json = await ApiClient.post('/api/members', {
      'name': name,
      'role': role,
      'email': email,
    });
    _members.add(memberFromJson(json as Map<String, dynamic>));
    notifyListeners();
  }

  /// Retire un membre. Ses tâches redeviennent « non assignées » ; la liste
  /// retournée permet de les réassigner si l'utilisateur annule.
  ({Member member, List<String> taskIds})? removeMember(String id) {
    final m = memberById(id);
    if (m == null) return null;
    final ids = <String>[];
    for (final t in _tasks) {
      if (t.assignee == id) {
        t.assignee = null;
        ids.add(t.id);
      }
    }
    _members.remove(m);
    _scheduleDelete(id, '/api/members/$id');
    notifyListeners();
    return (member: m, taskIds: ids);
  }

  void restoreMember(Member m, List<String> taskIds) {
    _cancelDelete(m.id);
    _members.add(m);
    for (final id in taskIds) {
      taskById(id)?.assignee = m.id;
    }
    notifyListeners();
  }

  // ---------- Pièces jointes (stockées sur le serveur) ----------
  Future<void> loadAttachments(String taskId) async {
    final json = await ApiClient.get('/api/tasks/$taskId/attachments');
    final t = taskById(taskId);
    if (t == null) return;
    t.attachments
      ..clear()
      ..addAll(
        (json as List).map(
          (j) => Attachment.fromJson(j as Map<String, dynamic>),
        ),
      );
    notifyListeners();
  }

  Future<void> uploadAttachment(
    String taskId,
    String filePath,
    String fileName,
  ) async {
    final json = await ApiClient.upload(
      '/api/tasks/$taskId/attachments',
      filePath,
      fileName,
    );
    taskById(taskId)?.attachments
        .add(Attachment.fromJson(json as Map<String, dynamic>));
    notifyListeners();
  }

  Future<void> deleteAttachment(String taskId, Attachment a) async {
    await ApiClient.delete('/api/attachments/${a.id}');
    taskById(taskId)?.attachments.removeWhere((x) => x.id == a.id);
    notifyListeners();
  }

  // ---------- Suppression différée (permet « Annuler ») ----------
  void _scheduleDelete(String id, String path) {
    _pendingDeletes.add(id);
    _deleteTimers[id]?.cancel();
    _deleteTimers[id] = Timer(const Duration(seconds: 6), () async {
      _deleteTimers.remove(id);
      try {
        await ApiClient.delete(path);
      } catch (_) {
        // échec : l'élément réapparaîtra au prochain rafraîchissement
      }
      _pendingDeletes.remove(id);
      await refresh();
    });
  }

  void _cancelDelete(String id) {
    _deleteTimers.remove(id)?.cancel();
    _pendingDeletes.remove(id);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    for (final t in _deleteTimers.values) {
      t.cancel();
    }
    super.dispose();
  }
}
