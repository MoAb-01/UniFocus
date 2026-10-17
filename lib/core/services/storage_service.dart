import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../models/program.dart';
import '../models/semester.dart';
import '../models/task_item.dart';
import '../models/calendar_event.dart';
import '../models/study_session.dart';
import '../models/scanned_document.dart';
import '../models/user_settings.dart';
import 'seed_data_service.dart';

class StorageService {
  static const String _keyProfile = 'unifocus_profile';
  static const String _keyPrograms = 'unifocus_programs';
  static const String _keySemesters = 'unifocus_semesters';
  static const String _keyTasks = 'unifocus_tasks';
  static const String _keyEvents = 'unifocus_events';
  static const String _keySessions = 'unifocus_sessions';
  static const String _keyDocuments = 'unifocus_documents';
  static const String _keyDarkMode = 'unifocus_dark_mode';

  static UserProfile get cleanInitialUser => const UserProfile(
    id: 'user_initial',
    name: '',
    email: '',
    university: 'İzmir Kâtip Çelebi University',
    department: 'Computer Engineering',
    academicYear: 'YEAR_1',
    academicYearEnum: AcademicYear.year1,
    previousGpa: null,
    previousCompletedAKTS: 0,
    secondProgramType: 'NONE',
    hasDoubleMajor: false,
    hasMinor: false,
    currentGano: 0.0,
    completedAkts: 0,
    isOnboardingCompleted: false,
    level: 1,
    xp: 0,
    maxXp: 100,
    studyStreakDays: 0,
    focusMinutesTotal: 0,
    achievements: [],
  );

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Profile
  UserProfile getProfile() {
    final raw = _prefs.getString(_keyProfile);
    if (raw == null) return cleanInitialUser;
    try {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return cleanInitialUser;
    }
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _prefs.setString(_keyProfile, jsonEncode(profile.toJson()));
  }

  // Programs
  List<Program> getPrograms() {
    final raw = _prefs.getString(_keyPrograms);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Program.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> savePrograms(List<Program> programs) async {
    final list = programs.map((p) => p.toJson()).toList();
    await _prefs.setString(_keyPrograms, jsonEncode(list));
  }

  // Semesters
  List<Semester> getSemesters() {
    final raw = _prefs.getString(_keySemesters);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Semester.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSemesters(List<Semester> semesters) async {
    final list = semesters.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySemesters, jsonEncode(list));
  }

  // Tasks
  List<TaskItem> getTasks() {
    final raw = _prefs.getString(_keyTasks);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => TaskItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveTasks(List<TaskItem> tasks) async {
    final list = tasks.map((t) => t.toJson()).toList();
    await _prefs.setString(_keyTasks, jsonEncode(list));
  }

  // Events
  List<CalendarEvent> getEvents() {
    final raw = _prefs.getString(_keyEvents);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => CalendarEvent.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveEvents(List<CalendarEvent> events) async {
    final list = events.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyEvents, jsonEncode(list));
  }

  // Study Sessions
  List<StudySession> getSessions() {
    final raw = _prefs.getString(_keySessions);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => StudySession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveSessions(List<StudySession> sessions) async {
    final list = sessions.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySessions, jsonEncode(list));
  }

  // Scanned Documents
  List<ScannedDocument> getDocuments() {
    final raw = _prefs.getString(_keyDocuments);
    if (raw == null) return const [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ScannedDocument.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveDocuments(List<ScannedDocument> docs) async {
    final list = docs.map((d) => d.toJson()).toList();
    await _prefs.setString(_keyDocuments, jsonEncode(list));
  }

  // Clear user data on logout
  Future<void> clearAllUserData() async {
    await _prefs.remove(_keyProfile);
    await _prefs.remove(_keyPrograms);
    await _prefs.remove(_keySemesters);
    await _prefs.remove(_keyTasks);
    await _prefs.remove(_keyEvents);
    await _prefs.remove(_keySessions);
    await _prefs.remove(_keyDocuments);
  }

  // Theme Mode
  bool isDarkMode() {
    return _prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_keyDarkMode, value);
  }

  // Persistent User Settings
  static const String _keySettings = 'unifocus_user_settings';

  UserSettings getUserSettings() {
    final raw = _prefs.getString(_keySettings);
    if (raw == null) return const UserSettings();
    try {
      return UserSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const UserSettings();
    }
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    await _prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }
}
