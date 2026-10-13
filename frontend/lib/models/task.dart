class Task {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? deadline;
  final String priority; // 'urgent', 'high', 'medium', 'low'
  final String status; // 'pending', 'completed', 'overdue'
  final String? sourceEvidence;
  final bool isConfirmed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Task({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.deadline,
    this.priority = 'medium',
    this.status = 'pending',
    this.sourceEvidence,
    this.isConfirmed = true,
    required this.createdAt,
    this.updatedAt,
  });

  bool get isOverdue {
    if (status == 'completed' || deadline == null) return false;
    return deadline!.isBefore(DateTime.now());
  }

  bool get isDueToday {
    if (deadline == null) return false;
    final now = DateTime.now();
    return deadline!.year == now.year &&
        deadline!.month == now.month &&
        deadline!.day == now.day;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'deadline': deadline?.toIso8601String(),
      'priority': priority,
      'status': status,
      'source_evidence': sourceEvidence,
      'is_confirmed': isConfirmed,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      deadline: map['deadline'] != null
          ? DateTime.tryParse(map['deadline'].toString())
          : null,
      priority: map['priority']?.toString().toLowerCase() ?? 'medium',
      status: map['status']?.toString().toLowerCase() ?? 'pending',
      sourceEvidence: map['source_evidence']?.toString(),
      isConfirmed: map['is_confirmed'] == true || map['is_confirmed'] == 1,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  Task copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? deadline,
    String? priority,
    String? status,
    String? sourceEvidence,
    bool? isConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      deadline: deadline ?? this.deadline,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      sourceEvidence: sourceEvidence ?? this.sourceEvidence,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
