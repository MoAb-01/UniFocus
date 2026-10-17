class TaskItem {
  final String id;
  final String courseId;
  final String courseCode;
  final String title;
  final String description;
  final DateTime dueDate;
  final String priority; // 'Low', 'Medium', 'High'
  final double progress; // 0.0 to 1.0
  final bool isCompleted;
  final int estimatedStudyMinutes;

  const TaskItem({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    this.progress = 0.0,
    this.isCompleted = false,
    this.estimatedStudyMinutes = 60,
  });

  int get estimatedMinutes => estimatedStudyMinutes;

  TaskItem copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? title,
    String? description,
    DateTime? dueDate,
    String? priority,
    double? progress,
    bool? isCompleted,
    int? estimatedStudyMinutes,
  }) {
    return TaskItem(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
      estimatedStudyMinutes: estimatedStudyMinutes ?? this.estimatedStudyMinutes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'courseCode': courseCode,
    'title': title,
    'description': description,
    'dueDate': dueDate.toIso8601String(),
    'priority': priority,
    'progress': progress,
    'isCompleted': isCompleted,
    'estimatedStudyMinutes': estimatedStudyMinutes,
  };

  factory TaskItem.fromJson(Map<String, dynamic> json) => TaskItem(
    id: json['id'] as String,
    courseId: json['courseId'] as String,
    courseCode: json['courseCode'] as String? ?? '',
    title: json['title'] as String,
    description: json['description'] as String? ?? '',
    dueDate: DateTime.parse(json['dueDate'] as String),
    priority: json['priority'] as String? ?? 'Medium',
    progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
    isCompleted: json['isCompleted'] as bool? ?? false,
    estimatedStudyMinutes: json['estimatedStudyMinutes'] as int? ?? 60,
  );
}
