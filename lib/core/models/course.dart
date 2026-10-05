import '../constants/app_constants.dart';

class Course {
  final String id;
  final String code;
  final String name;
  final String instructor;
  final int credit;
  final int akts;
  final String programId;
  final String semesterId;
  final String? letterGrade;
  final double? gradePoints;
  final bool isCompleted;
  final String colorHex;

  const Course({
    required this.id,
    required this.code,
    required this.name,
    required this.instructor,
    required this.credit,
    required this.akts,
    required this.programId,
    required this.semesterId,
    this.letterGrade,
    this.gradePoints,
    this.isCompleted = false,
    this.colorHex = '#1E3A8A',
  });

  bool get isPassed {
    if (letterGrade == null) return false;
    return AppConstants.isPassingGrade(letterGrade!);
  }

  int get colorValue {
    final hex = colorHex.replaceAll('#', '');
    return int.tryParse('0xFF$hex') ?? 0xFF2563EB;
  }

  Course copyWith({
    String? id,
    String? code,
    String? name,
    String? instructor,
    int? credit,
    int? akts,
    String? programId,
    String? semesterId,
    String? letterGrade,
    double? gradePoints,
    bool? isCompleted,
    String? colorHex,
  }) {
    return Course(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      instructor: instructor ?? this.instructor,
      credit: credit ?? this.credit,
      akts: akts ?? this.akts,
      programId: programId ?? this.programId,
      semesterId: semesterId ?? this.semesterId,
      letterGrade: letterGrade ?? this.letterGrade,
      gradePoints: gradePoints ?? this.gradePoints,
      isCompleted: isCompleted ?? this.isCompleted,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'code': code,
    'name': name,
    'instructor': instructor,
    'credit': credit,
    'akts': akts,
    'programId': programId,
    'semesterId': semesterId,
    'letterGrade': letterGrade,
    'gradePoints': gradePoints,
    'isCompleted': isCompleted,
    'colorHex': colorHex,
  };

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'] as String,
    code: json['code'] as String,
    name: json['name'] as String,
    instructor: json['instructor'] as String? ?? '',
    credit: json['credit'] as int? ?? 3,
    akts: json['akts'] as int? ?? 5,
    programId: json['programId'] as String? ?? 'main_prog',
    semesterId: json['semesterId'] as String? ?? '',
    letterGrade: json['letterGrade'] as String?,
    gradePoints: (json['gradePoints'] as num?)?.toDouble(),
    isCompleted: json['isCompleted'] as bool? ?? false,
    colorHex: json['colorHex'] as String? ?? '#1E3A8A',
  );
}
