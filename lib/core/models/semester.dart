import 'course.dart';

class Semester {
  final String id;
  final String programId;
  final String academicYear; // e.g. "2026–2027"
  final String term; // 'Fall', 'Spring', 'Summer'
  final List<Course> courses;
  final double semesterGpa;
  final int totalAkts;
  final bool isCurrent;

  const Semester({
    required this.id,
    required this.programId,
    required this.academicYear,
    required this.term,
    this.courses = const [],
    this.semesterGpa = 0.0,
    this.totalAkts = 0,
    this.isCurrent = false,
  });

  String get displayName => '$academicYear $term';

  Semester copyWith({
    String? id,
    String? programId,
    String? academicYear,
    String? term,
    List<Course>? courses,
    double? semesterGpa,
    int? totalAkts,
    bool? isCurrent,
  }) {
    return Semester(
      id: id ?? this.id,
      programId: programId ?? this.programId,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      courses: courses ?? this.courses,
      semesterGpa: semesterGpa ?? this.semesterGpa,
      totalAkts: totalAkts ?? this.totalAkts,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'programId': programId,
    'academicYear': academicYear,
    'term': term,
    'courses': courses.map((c) => c.toJson()).toList(),
    'semesterGpa': semesterGpa,
    'totalAkts': totalAkts,
    'isCurrent': isCurrent,
  };

  factory Semester.fromJson(Map<String, dynamic> json) => Semester(
    id: json['id'] as String,
    programId: json['programId'] as String? ?? 'main_prog',
    academicYear: json['academicYear'] as String,
    term: json['term'] as String,
    courses: (json['courses'] as List<dynamic>?)
            ?.map((e) => Course.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    semesterGpa: (json['semesterGpa'] as num?)?.toDouble() ?? 0.0,
    totalAkts: json['totalAkts'] as int? ?? 0,
    isCurrent: json['isCurrent'] as bool? ?? false,
  );
}
