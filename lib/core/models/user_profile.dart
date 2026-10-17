enum AcademicYear {
  prep,
  year1,
  year2,
  year3,
  year4,
  year5,
  year6,
  other;

  String get value {
    switch (this) {
      case AcademicYear.prep:
        return 'PREP';
      case AcademicYear.year1:
        return 'YEAR_1';
      case AcademicYear.year2:
        return 'YEAR_2';
      case AcademicYear.year3:
        return 'YEAR_3';
      case AcademicYear.year4:
        return 'YEAR_4';
      case AcademicYear.year5:
        return 'YEAR_5';
      case AcademicYear.year6:
        return 'YEAR_6';
      case AcademicYear.other:
        return 'OTHER';
    }
  }

  String get displayName {
    switch (this) {
      case AcademicYear.prep:
        return 'Preparatory Year';
      case AcademicYear.year1:
        return '1st Year';
      case AcademicYear.year2:
        return '2nd Year';
      case AcademicYear.year3:
        return '3rd Year';
      case AcademicYear.year4:
        return '4th Year';
      case AcademicYear.year5:
        return '5th Year';
      case AcademicYear.year6:
        return '6th Year';
      case AcademicYear.other:
        return 'Other';
    }
  }

  static AcademicYear fromString(String? val) {
    if (val == null) return AcademicYear.year1;
    final upper = val.toUpperCase().trim();
    if (upper.contains('PREP')) return AcademicYear.prep;
    if (upper.contains('1ST') || upper == 'YEAR_1') return AcademicYear.year1;
    if (upper.contains('2ND') || upper == 'YEAR_2') return AcademicYear.year2;
    if (upper.contains('3RD') || upper == 'YEAR_3') return AcademicYear.year3;
    if (upper.contains('4TH') || upper == 'YEAR_4') return AcademicYear.year4;
    if (upper.contains('5TH') || upper == 'YEAR_5') return AcademicYear.year5;
    if (upper.contains('6TH') || upper == 'YEAR_6') return AcademicYear.year6;
    if (upper == 'OTHER') return AcademicYear.other;
    return AcademicYear.year1;
  }
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? universityId;
  final String university;
  final String? majorId;
  final String department;
  final String academicYear; // Stable enum string: PREP, YEAR_1, etc.
  final AcademicYear academicYearEnum;
  final String? currentSemester;
  final double? previousGpa; // Nullable baseline GPA
  final int previousCompletedAKTS; // Baseline completed AKTS
  final String secondProgramType; // 'NONE', 'CAP', 'MINOR'
  final String? secondProgramId;
  final String? secondProgramName;
  final bool hasDoubleMajor;
  final String? doubleMajorDepartment;
  final bool hasMinor;
  final String? minorDepartment;
  final double currentGano;
  final int completedAkts;
  final String? avatarUrl;
  final bool isOnboardingCompleted;
  final String preferredLanguage;

  final int level;
  final int xp;
  final int maxXp;
  final int studyStreakDays;
  final int focusMinutesTotal;
  final List<String> achievements;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // Aliases for Firestore conceptual fields
  String get uid => id;
  String get displayName => name;
  String get universityName => university;
  String get majorName => department;
  int get streak => studyStreakDays;
  int get totalFocusMinutes => focusMinutesTotal;

  /// Helper to get formatted GPA text: returns "GPA NOT SET" when baseline and courses have no GPA
  String get displayGpa {
    if (previousGpa == null && currentGano == 0.0) {
      return 'GPA NOT SET';
    }
    final effective = currentGano > 0 ? currentGano : (previousGpa ?? 0.0);
    return effective > 0 ? effective.toStringAsFixed(2) : 'GPA NOT SET';
  }

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.universityId,
    this.university = 'İzmir Kâtip Çelebi University',
    this.majorId,
    this.department = 'Computer Engineering',
    this.academicYear = 'YEAR_1',
    this.academicYearEnum = AcademicYear.year1,
    this.currentSemester = '2026–2027 Fall',
    this.previousGpa,
    this.previousCompletedAKTS = 0,
    this.secondProgramType = 'NONE',
    this.secondProgramId,
    this.secondProgramName,
    this.hasDoubleMajor = false,
    this.doubleMajorDepartment,
    this.hasMinor = false,
    this.minorDepartment,
    this.currentGano = 0.0,
    this.completedAkts = 0,
    this.avatarUrl,
    this.isOnboardingCompleted = false,
    this.preferredLanguage = 'en',
    this.level = 1,
    this.xp = 0,
    this.maxXp = 100,
    this.studyStreakDays = 0,
    this.focusMinutesTotal = 0,
    this.achievements = const [],
    this.createdAt,
    this.updatedAt,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? universityId,
    String? university,
    String? majorId,
    String? department,
    String? academicYear,
    AcademicYear? academicYearEnum,
    String? currentSemester,
    double? previousGpa,
    int? previousCompletedAKTS,
    String? secondProgramType,
    String? secondProgramId,
    String? secondProgramName,
    bool? hasDoubleMajor,
    String? doubleMajorDepartment,
    bool? hasMinor,
    String? minorDepartment,
    double? currentGano,
    int? completedAkts,
    String? avatarUrl,
    bool? isOnboardingCompleted,
    String? preferredLanguage,
    int? level,
    int? xp,
    int? maxXp,
    int? studyStreakDays,
    int? focusMinutesTotal,
    List<String>? achievements,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final yearEnum = academicYearEnum ??
        (academicYear != null
            ? AcademicYear.fromString(academicYear)
            : this.academicYearEnum);
    final yearStr = academicYear ?? (academicYearEnum?.value ?? this.academicYear);

    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      universityId: universityId ?? this.universityId,
      university: university ?? this.university,
      majorId: majorId ?? this.majorId,
      department: department ?? this.department,
      academicYear: yearStr,
      academicYearEnum: yearEnum,
      currentSemester: currentSemester ?? this.currentSemester,
      previousGpa: previousGpa ?? this.previousGpa,
      previousCompletedAKTS: previousCompletedAKTS ?? this.previousCompletedAKTS,
      secondProgramType: secondProgramType ?? this.secondProgramType,
      secondProgramId: secondProgramId ?? this.secondProgramId,
      secondProgramName: secondProgramName ?? this.secondProgramName,
      hasDoubleMajor: hasDoubleMajor ?? this.hasDoubleMajor,
      doubleMajorDepartment: doubleMajorDepartment ?? this.doubleMajorDepartment,
      hasMinor: hasMinor ?? this.hasMinor,
      minorDepartment: minorDepartment ?? this.minorDepartment,
      currentGano: currentGano ?? this.currentGano,
      completedAkts: completedAkts ?? this.completedAkts,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      studyStreakDays: studyStreakDays ?? this.studyStreakDays,
      focusMinutesTotal: focusMinutesTotal ?? this.focusMinutesTotal,
      achievements: achievements ?? this.achievements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': id,
    'id': id,
    'displayName': name,
    'name': name,
    'email': email,
    'universityId': universityId,
    'universityName': university,
    'university': university,
    'majorId': majorId,
    'majorName': department,
    'department': department,
    'academicYear': academicYear,
    'academicYearEnum': academicYearEnum.value,
    'currentSemester': currentSemester,
    'previousGpa': previousGpa,
    'previousCompletedAKTS': previousCompletedAKTS,
    'secondProgramType': secondProgramType,
    'secondProgramId': secondProgramId,
    'secondProgramName': secondProgramName,
    'hasDoubleMajor': hasDoubleMajor,
    'doubleMajorDepartment': doubleMajorDepartment,
    'hasMinor': hasMinor,
    'minorDepartment': minorDepartment,
    'currentGano': currentGano,
    'completedAkts': completedAkts,
    'avatarUrl': avatarUrl,
    'isOnboardingCompleted': isOnboardingCompleted,
    'preferredLanguage': preferredLanguage,
    'level': level,
    'xp': xp,
    'maxXp': maxXp,
    'streak': studyStreakDays,
    'studyStreakDays': studyStreakDays,
    'totalFocusMinutes': focusMinutesTotal,
    'focusMinutesTotal': focusMinutesTotal,
    'achievements': achievements,
    'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final secondTypeRaw = (json['secondProgramType'] as String?)?.toUpperCase() ??
        (json['hasDoubleMajor'] == true
            ? 'CAP'
            : (json['hasMinor'] == true ? 'MINOR' : 'NONE'));

    final yearStr = (json['academicYear'] ?? 'YEAR_1') as String;
    final yearEnum = AcademicYear.fromString(yearStr);

    return UserProfile(
      id: (json['uid'] ?? json['id'] ?? '') as String,
      name: (json['displayName'] ?? json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      universityId: json['universityId'] as String?,
      university: (json['universityName'] ?? json['university'] ?? 'İzmir Kâtip Çelebi University') as String,
      majorId: json['majorId'] as String?,
      department: (json['majorName'] ?? json['department'] ?? 'Computer Engineering') as String,
      academicYear: yearEnum.value,
      academicYearEnum: yearEnum,
      currentSemester: json['currentSemester'] as String? ?? '2026–2027 Fall',
      previousGpa: (json['previousGpa'] as num?)?.toDouble(),
      previousCompletedAKTS: (json['previousCompletedAKTS'] as num?)?.toInt() ?? 0,
      secondProgramType: secondTypeRaw,
      secondProgramId: json['secondProgramId'] as String?,
      secondProgramName: json['secondProgramName'] as String?,
      hasDoubleMajor: json['hasDoubleMajor'] as bool? ?? (secondTypeRaw == 'CAP'),
      doubleMajorDepartment: json['doubleMajorDepartment'] as String? ?? json['secondProgramName'] as String?,
      hasMinor: json['hasMinor'] as bool? ?? (secondTypeRaw == 'MINOR'),
      minorDepartment: json['minorDepartment'] as String? ?? json['secondProgramName'] as String?,
      currentGano: (json['currentGano'] as num?)?.toDouble() ?? 0.0,
      completedAkts: json['completedAkts'] as int? ?? 0,
      avatarUrl: json['avatarUrl'] as String?,
      isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      maxXp: json['maxXp'] as int? ?? 100,
      studyStreakDays: (json['streak'] ?? json['studyStreakDays']) as int? ?? 0,
      focusMinutesTotal: (json['totalFocusMinutes'] ?? json['focusMinutesTotal']) as int? ?? 0,
      achievements: (json['achievements'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt'] as String) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt'] as String) : null,
    );
  }
}
