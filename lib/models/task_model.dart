class Task {
  final String? id;  // Changed from int? to String? for Firebase
  final String title;
  final String subtitle;
  final DateTime dueDate;
  final String priority; // 'High', 'Medium', 'Low'
  final String category; // 'Venue', 'Catering', 'Guests', 'Decoration'
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    required this.title,
    required this.subtitle,
    required this.dueDate,
    required this.priority,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.updatedAt,
  });

  // Convert Task to JSON for API/Firebase
  Map<String, dynamic> toJson() => {
    'title': title,
    'subtitle': subtitle,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'category': category,
    'isCompleted': isCompleted,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create Task from JSON
  factory Task.fromJson(Map<String, dynamic> json) => Task(
    id: json['id'] as String?,
    title: json['title'] as String,
    subtitle: json['subtitle'] as String,
    dueDate: DateTime.parse(json['dueDate'] as String),
    priority: json['priority'] as String,
    category: json['category'] as String,
    isCompleted: (json['isCompleted'] as bool?) ?? false,
    createdAt: DateTime.parse(json['createdAt'] as String),
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
  );

  // Create a copy with modifications
  Task copyWith({
    String? id,
    String? title,
    String? subtitle,
    DateTime? dueDate,
    String? priority,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
    Task(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );

  // Convert to Map for database (SQLite)
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'subtitle': subtitle,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'category': category,
    'isCompleted': isCompleted ? 1 : 0,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };

  // Create from database Map (SQLite)
  factory Task.fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as String?,
    title: map['title'] as String,
    subtitle: map['subtitle'] as String,
    dueDate: DateTime.parse(map['dueDate'] as String),
    priority: map['priority'] as String,
    category: map['category'] as String,
    isCompleted: (map['isCompleted'] as int?) == 1,
    createdAt: DateTime.parse(map['createdAt'] as String),
    updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt'] as String) : null,
  );
}
