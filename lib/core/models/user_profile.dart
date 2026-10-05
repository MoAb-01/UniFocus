class UserProfile {
  final String id;
  final String name;
  final String email;
  final String university;
  final String department;
  final String academicYear;
  final bool hasDoubleMajor; // ÇAP
  final String? doubleMajorDepartment;
  final bool hasMinor; // Yandal
  final String? minorDepartment;
  final double currentGano;
  final int completedAkts;
  final String? avatarUrl;
  final bool isOnboardingCompleted;

  final int level;
  final int xp;
  final int maxXp;
  final int studyStreakDays;
  final int focusMinutesTotal;
  final List<String> achievements;

  const UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.university,
    required this.department,
    required this.academicYear,
    this.hasDoubleMajor = false,
    this.doubleMajorDepartment,
    this.hasMinor = false,
    this.minorDepartment,
    this.currentGano = 0.0,
    this.completedAkts = 0,
    this.avatarUrl,
    this.isOnboardingCompleted = false,
    this.level = 7,
    this.xp = 1840,
    this.maxXp = 2000,
    this.studyStreakDays = 12,
    this.focusMinutesTotal = 420,
    this.achievements = const [
      'First Study Together Session',
      '5 Study Sessions Streak',
      '10 Goals Completed',
    ],
  });

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? university,
    String? department,
    String? academicYear,
    bool? hasDoubleMajor,
    String? doubleMajorDepartment,
    bool? hasMinor,
    String? minorDepartment,
    double? currentGano,
    int? completedAkts,
    String? avatarUrl,
    bool? isOnboardingCompleted,
    int? level,
    int? xp,
    int? maxXp,
    int? studyStreakDays,
    int? focusMinutesTotal,
    List<String>? achievements,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      university: university ?? this.university,
      department: department ?? this.department,
      academicYear: academicYear ?? this.academicYear,
      hasDoubleMajor: hasDoubleMajor ?? this.hasDoubleMajor,
      doubleMajorDepartment: doubleMajorDepartment ?? this.doubleMajorDepartment,
      hasMinor: hasMinor ?? this.hasMinor,
      minorDepartment: minorDepartment ?? this.minorDepartment,
      currentGano: currentGano ?? this.currentGano,
      completedAkts: completedAkts ?? this.completedAkts,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnboardingCompleted: isOnboardingCompleted ?? this.isOnboardingCompleted,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      maxXp: maxXp ?? this.maxXp,
      studyStreakDays: studyStreakDays ?? this.studyStreakDays,
      focusMinutesTotal: focusMinutesTotal ?? this.focusMinutesTotal,
      achievements: achievements ?? this.achievements,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'university': university,
    'department': department,
    'academicYear': academicYear,
    'hasDoubleMajor': hasDoubleMajor,
    'doubleMajorDepartment': doubleMajorDepartment,
    'hasMinor': hasMinor,
    'minorDepartment': minorDepartment,
    'currentGano': currentGano,
    'completedAkts': completedAkts,
    'avatarUrl': avatarUrl,
    'isOnboardingCompleted': isOnboardingCompleted,
    'level': level,
    'xp': xp,
    'maxXp': maxXp,
    'studyStreakDays': studyStreakDays,
    'focusMinutesTotal': focusMinutesTotal,
    'achievements': achievements,
  };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    university: json['university'] as String? ?? 'İzmir Kâtip Çelebi University',
    department: json['department'] as String? ?? 'Computer Engineering',
    academicYear: json['academicYear'] as String? ?? '4th Year (Senior)',
    hasDoubleMajor: json['hasDoubleMajor'] as bool? ?? false,
    doubleMajorDepartment: json['doubleMajorDepartment'] as String?,
    hasMinor: json['hasMinor'] as bool? ?? false,
    minorDepartment: json['minorDepartment'] as String?,
    currentGano: (json['currentGano'] as num?)?.toDouble() ?? 0.0,
    completedAkts: json['completedAkts'] as int? ?? 0,
    avatarUrl: json['avatarUrl'] as String?,
    isOnboardingCompleted: json['isOnboardingCompleted'] as bool? ?? false,
    level: json['level'] as int? ?? 7,
    xp: json['xp'] as int? ?? 1840,
    maxXp: json['maxXp'] as int? ?? 2000,
    studyStreakDays: json['studyStreakDays'] as int? ?? 12,
    focusMinutesTotal: json['focusMinutesTotal'] as int? ?? 420,
    achievements: (json['achievements'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [
          'First Study Together Session',
          '5 Study Sessions Streak',
          '10 Goals Completed',
        ],
  );
}
