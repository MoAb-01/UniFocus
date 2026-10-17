class UserSettings {
  final String theme; // 'light', 'dark', 'system'
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool musicEnabled;
  final String language; // 'en', 'tr', 'ar'
  final Map<String, dynamic> privacySettings;

  const UserSettings({
    this.theme = 'light',
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.language = 'en',
    this.privacySettings = const {
      'showMajorInRoom': true,
      'showLevelInRoom': true,
      'allowVoiceInBreak': true,
    },
  });

  UserSettings copyWith({
    String? theme,
    bool? notificationsEnabled,
    bool? soundEnabled,
    bool? musicEnabled,
    String? language,
    Map<String, dynamic>? privacySettings,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      language: language ?? this.language,
      privacySettings: privacySettings ?? this.privacySettings,
    );
  }

  Map<String, dynamic> toJson() => {
    'theme': theme,
    'notificationsEnabled': notificationsEnabled,
    'soundEnabled': soundEnabled,
    'musicEnabled': musicEnabled,
    'language': language,
    'privacySettings': privacySettings,
  };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
    theme: json['theme'] as String? ?? 'light',
    notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    musicEnabled: json['musicEnabled'] as bool? ?? true,
    language: json['language'] as String? ?? 'en',
    privacySettings: json['privacySettings'] != null
        ? Map<String, dynamic>.from(json['privacySettings'] as Map)
        : const {
            'showMajorInRoom': true,
            'showLevelInRoom': true,
            'allowVoiceInBreak': true,
          },
  );
}
