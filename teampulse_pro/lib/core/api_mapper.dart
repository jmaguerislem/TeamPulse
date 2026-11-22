import '../models/models.dart';

/// Conversion entre les objets de l'application et le JSON du serveur.

DateTime _date(dynamic v) {
  if (v is List) return DateTime(v[0] as int, v[1] as int, v[2] as int);
  final parts = (v as String).split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

DateTime _instant(String s) => DateTime.parse(s).toLocal();

// ---------- Projets ----------
ProjectStatus _projectStatus(String s) => switch (s) {
  'DONE' => ProjectStatus.done,
  'ON_HOLD' => ProjectStatus.onHold,
  _ => ProjectStatus.inProgress,
};

String _projectStatusApi(ProjectStatus s) => switch (s) {
  ProjectStatus.done => 'DONE',
  ProjectStatus.onHold => 'ON_HOLD',
  ProjectStatus.inProgress => 'IN_PROGRESS',
};

Project projectFromJson(Map<String, dynamic> j) => Project(
  id: j['id'] as String,
  name: j['name'] as String,
  description: (j['description'] as String?) ?? '',
  startDate: _date(j['startDate']),
  deadline: _date(j['deadline']),
  status: _projectStatus(j['status'] as String),
);

Map<String, dynamic> projectBody({
  required String name,
  required String description,
  required DateTime startDate,
  required DateTime deadline,
  required ProjectStatus status,
}) => {
  'name': name,
  'description': description,
  'startDate': _isoDate(startDate),
  'deadline': _isoDate(deadline),
  'status': _projectStatusApi(status),
};

// ---------- Tâches ----------
TaskStatus _taskStatus(String s) => switch (s) {
  'DONE' => TaskStatus.done,
  'IN_PROGRESS' => TaskStatus.inProgress,
  _ => TaskStatus.todo,
};

String taskStatusApi(TaskStatus s) => switch (s) {
  TaskStatus.done => 'DONE',
  TaskStatus.inProgress => 'IN_PROGRESS',
  TaskStatus.todo => 'TODO',
};

TaskPriority _priority(String s) => switch (s) {
  'HIGH' => TaskPriority.high,
  'LOW' => TaskPriority.low,
  _ => TaskPriority.medium,
};

String _priorityApi(TaskPriority p) => switch (p) {
  TaskPriority.high => 'HIGH',
  TaskPriority.medium => 'MEDIUM',
  TaskPriority.low => 'LOW',
};

Task taskFromJson(Map<String, dynamic> j) => Task(
  id: j['id'] as String,
  projectId: j['projectId'] as String,
  title: j['title'] as String,
  description: (j['description'] as String?) ?? '',
  dueDate: _date(j['dueDate']),
  priority: _priority(j['priority'] as String),
  status: _taskStatus(j['status'] as String),
  assignee: j['assigneeId'] as String?,
  createdAt: _instant(j['createdAt'] as String),
  completedAt: j['completedAt'] == null
      ? null
      : _instant(j['completedAt'] as String),
);

Map<String, dynamic> taskBody({
  required String projectId,
  required String title,
  required String description,
  required DateTime dueDate,
  required TaskPriority priority,
}) => {
  'projectId': projectId,
  'title': title,
  'description': description,
  'dueDate': _isoDate(dueDate),
  'priority': _priorityApi(priority),
};

// ---------- Membres ----------
Member memberFromJson(Map<String, dynamic> j) => Member(
  id: j['id'] as String,
  name: j['name'] as String,
  role: (j['role'] as String?) ?? '',
  isLead: (j['lead'] as bool?) ?? false,
  email: (j['email'] as String?) ?? '',
  joined: (j['joined'] as bool?) ?? false,
);
