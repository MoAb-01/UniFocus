class StudySession {
  final String id;
  final String courseId;
  final String courseCode;
  final String taskTitle;
  final int durationMinutes;
  final int breakMinutes;
  final DateTime timestamp;
  final bool completed;

  const StudySession({
    required this.id,
    required this.courseId,
    required this.courseCode,
    required this.taskTitle,
    required this.durationMinutes,
    this.breakMinutes = 5,
    required this.timestamp,
    this.completed = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'courseId': courseId,
    'courseCode': courseCode,
    'taskTitle': taskTitle,
    'durationMinutes': durationMinutes,
    'breakMinutes': breakMinutes,
    'timestamp': timestamp.toIso8601String(),
    'completed': completed,
  };

  factory StudySession.fromJson(Map<String, dynamic> json) => StudySession(
    id: json['id'] as String,
    courseId: json['courseId'] as String,
    courseCode: json['courseCode'] as String? ?? '',
    taskTitle: json['taskTitle'] as String? ?? 'Focus Session',
    durationMinutes: json['durationMinutes'] as int? ?? 25,
    breakMinutes: json['breakMinutes'] as int? ?? 5,
    timestamp: DateTime.parse(json['timestamp'] as String),
    completed: json['completed'] as bool? ?? true,
  );
}
