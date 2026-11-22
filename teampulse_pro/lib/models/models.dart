enum ProjectStatus { inProgress, done, onHold }

enum TaskStatus { todo, inProgress, done }

enum TaskPriority { high, medium, low }

class Project {
  final String id;
  String name;
  String description;
  DateTime startDate;
  DateTime deadline;
  ProjectStatus status;

  Project({
    required this.id,
    required this.name,
    this.description = '',
    required this.startDate,
    required this.deadline,
    this.status = ProjectStatus.inProgress,
  });
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'startDate': startDate.toIso8601String(),
    'deadline': deadline.toIso8601String(),
    'status': status.name,
  };

  factory Project.fromJson(Map<String, dynamic> j) => Project(
    id: j['id'],
    name: j['name'],
    description: j['description'] ?? '',
    startDate: DateTime.parse(j['startDate']),
    deadline: DateTime.parse(j['deadline']),
    status: ProjectStatus.values.byName(j['status']),
  );
}

class Task {
  final String id;
  final List<Attachment> attachments;
  String projectId;
  String title;
  String description;
  DateTime dueDate;
  TaskPriority priority;
  TaskStatus status;
  String? assignee;
  DateTime createdAt;
  DateTime? completedAt;

  Task({
    required this.id,
    List<Attachment>? attachments,
    required this.projectId,
    required this.title,
    this.description = '',
    required this.dueDate,
    this.priority = TaskPriority.medium,
    this.status = TaskStatus.todo,
    this.assignee,
    DateTime? createdAt,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       attachments = attachments ?? [];

  bool get isLate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return status != TaskStatus.done && dueDate.isBefore(today);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'projectId': projectId,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority.name,
    'status': status.name,
    'assignee': assignee,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'attachments': attachments.map((a) => a.toJson()).toList(),
  };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
    id: j['id'],
    projectId: j['projectId'],
    title: j['title'],
    description: j['description'] ?? '',
    dueDate: DateTime.parse(j['dueDate']),
    priority: TaskPriority.values.byName(j['priority']),
    status: TaskStatus.values.byName(j['status']),
    assignee: j['assignee'],
    createdAt: DateTime.parse(j['createdAt']),
    completedAt: j['completedAt'] == null
        ? null
        : DateTime.parse(j['completedAt']),
    attachments:
        (j['attachments'] as List?)
            ?.map((a) => Attachment.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [],
  );
}

class Member {
  final String id;
  String name;
  String role;
  bool isLead;
  String email; // e-mail renseigné par la cheffe de projet
  bool joined; // true quand la personne a créé son compte

  Member({
    required this.id,
    required this.name,
    required this.role,
    this.isLead = false,
    this.email = '',
    this.joined = false,
  });

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'isLead': isLead,
    'email': email,
    'joined': joined,
  };

  factory Member.fromJson(Map<String, dynamic> j) => Member(
    id: j['id'],
    name: j['name'],
    role: j['role'],
    isLead: j['isLead'] ?? false,
    email: j['email'] ?? '',
    joined: j['joined'] ?? false,
  );
}

class Attachment {
  final String id; // identifiant sur le serveur
  final String name;
  final int size; // en octets
  const Attachment({required this.id, required this.name, required this.size});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'size': size};
  factory Attachment.fromJson(Map<String, dynamic> j) =>
      Attachment(id: j['id'], name: j['name'], size: j['size']);
}
