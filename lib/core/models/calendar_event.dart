class CalendarEvent {
  final String id;
  final String? courseId;
  final String? courseCode;
  final String title;
  final String type; // 'Class', 'Exam', 'Quiz', 'Assignment', 'Project', 'Presentation', 'Study Session', 'Personal'
  final DateTime dateTime;
  final String priority;
  final String? notes;
  final bool isCompleted;

  const CalendarEvent({
    required this.id,
    this.courseId,
    this.courseCode,
    required this.title,
    required this.type,
    required this.dateTime,
    this.priority = 'Medium',
    this.notes,
    this.isCompleted = false,
  });

  CalendarEvent copyWith({
    String? id,
    String? courseId,
    String? courseCode,
    String? title,
    String? type,
    DateTime? dateTime,
    String? priority,
    String? notes,
    bool? isCompleted,
  }) {
    return CalendarEvent(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseCode: courseCode ?? this.courseCode,
      title: title ?? this.title,
      type: type ?? this.type,
      dateTime: dateTime ?? this.dateTime,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'courseCode': courseCode,
    'title': title,
    'type': type,
    'dateTime': dateTime.toIso8601String(),
    'priority': priority,
    'notes': notes,
    'isCompleted': isCompleted,
  };

  factory CalendarEvent.fromJson(Map<String, dynamic> json) => CalendarEvent(
    id: json['id'] as String,
    courseId: json['courseId'] as String?,
    courseCode: json['courseCode'] as String?,
    title: json['title'] as String,
    type: json['type'] as String? ?? 'Assignment',
    dateTime: DateTime.parse(json['dateTime'] as String),
    priority: json['priority'] as String? ?? 'Medium',
    notes: json['notes'] as String?,
    isCompleted: json['isCompleted'] as bool? ?? false,
  );
}
