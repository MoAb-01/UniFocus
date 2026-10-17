import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/program.dart';
import '../models/semester.dart';
import '../models/course.dart';
import '../models/task_item.dart';
import '../models/calendar_event.dart';
import '../models/study_session.dart';
import '../models/scanned_document.dart';
import '../utils/grade_calculator.dart';
import 'storage_service.dart';
import 'firestore_user_service.dart';
import 'gamification_service.dart';

class AcademicService extends ChangeNotifier {
  final StorageService _storage;
  final FirestoreUserService _firestoreUserService;

  late UserProfile _profile;
  List<Program> _programs = [];
  List<Semester> _semesters = [];
  List<TaskItem> _tasks = [];
  List<CalendarEvent> _events = [];
  List<StudySession> _sessions = [];
  List<ScannedDocument> _documents = [];
  String? _selectedProgramId; // null = all programs

  AcademicService(
    this._storage, {
    FirestoreUserService? firestoreUserService,
  }) : _firestoreUserService = firestoreUserService ?? FirestoreUserService() {
    loadData();
  }

  void loadData() {
    _profile = _storage.getProfile();
    _programs = List<Program>.from(_storage.getPrograms());
    _semesters = List<Semester>.from(_storage.getSemesters());
    _tasks = List<TaskItem>.from(_storage.getTasks());
    _events = List<CalendarEvent>.from(_storage.getEvents());
    _sessions = List<StudySession>.from(_storage.getSessions());
    _documents = List<ScannedDocument>.from(_storage.getDocuments());

    // Default to main program if available
    if (_programs.isNotEmpty && _selectedProgramId == null) {
      _selectedProgramId = _programs.first.id;
    }
    recalculateAllMetrics();
  }

  /// Loads authenticated user data from Cloud Firestore
  Future<void> loadUserData(String userId) async {
    try {
      final remoteProfile = await _firestoreUserService.fetchUserProfile(userId);
      if (remoteProfile != null) {
        _profile = remoteProfile;
        if (_programs.isEmpty || _programs.first.department != remoteProfile.department) {
          final progs = <Program>[
            Program(
              id: 'main_${remoteProfile.department.toLowerCase().replaceAll(' ', '_')}',
              name: remoteProfile.department,
              department: remoteProfile.department,
              type: ProgramType.main,
              gano: remoteProfile.previousGpa ?? remoteProfile.currentGano,
              completedAkts: remoteProfile.previousCompletedAKTS > 0
                  ? remoteProfile.previousCompletedAKTS
                  : remoteProfile.completedAkts,
            ),
          ];
          if (remoteProfile.secondProgramType.toUpperCase() == 'CAP' && remoteProfile.secondProgramName != null) {
            progs.add(Program(
              id: 'cap_${remoteProfile.secondProgramName!.toLowerCase().replaceAll(' ', '_')}',
              name: remoteProfile.secondProgramName!,
              department: remoteProfile.secondProgramName!,
              type: ProgramType.cap,
              gano: 0.0,
              completedAkts: 0,
            ));
          } else if (remoteProfile.secondProgramType.toUpperCase() == 'MINOR' && remoteProfile.secondProgramName != null) {
            progs.add(Program(
              id: 'minor_${remoteProfile.secondProgramName!.toLowerCase().replaceAll(' ', '_')}',
              name: remoteProfile.secondProgramName!,
              department: remoteProfile.secondProgramName!,
              type: ProgramType.minor,
              gano: 0.0,
              completedAkts: 0,
            ));
          }
          _programs = progs;
          _selectedProgramId = progs.first.id;
        }
      } else {
        // No remote profile found; ensure local profile is associated with the authenticated UID
        _profile = _profile.copyWith(id: userId);
      }
      final remoteSemesters = await _firestoreUserService.fetchUserSemesters(userId);
      if (remoteSemesters.isNotEmpty) {
        _semesters = remoteSemesters;
      }
      final remoteSessions = await _firestoreUserService.fetchSessionHistory(userId);
      if (remoteSessions.isNotEmpty) {
        _sessions = remoteSessions;
      }
    } catch (e) {
      debugPrint('[AcademicService] loadUserData remote sync note: $e');
    }
    recalculateAllMetrics();
  }

  /// Clears in-memory user data upon logout to prevent state leakage between accounts
  void clearUserData() {
    _profile = StorageService.cleanInitialUser;
    _programs = [];
    _semesters = [];
    _tasks = [];
    _events = [];
    _sessions = [];
    _documents = [];
    _selectedProgramId = null;
    notifyListeners();
  }

  /// Initializes a freshly registered user with zero fake courses, semesters, or XP
  Future<void> resetToCleanUser(UserProfile cleanProfile) async {
    _profile = cleanProfile;
    final progs = <Program>[
      Program(
        id: 'main_${cleanProfile.department.toLowerCase().replaceAll(' ', '_')}',
        name: cleanProfile.department,
        department: cleanProfile.department,
        type: ProgramType.main,
        gano: cleanProfile.previousGpa ?? 0.0,
        completedAkts: cleanProfile.previousCompletedAKTS,
      ),
    ];

    if (cleanProfile.secondProgramType.toUpperCase() == 'CAP' && cleanProfile.secondProgramName != null) {
      progs.add(Program(
        id: 'cap_${cleanProfile.secondProgramName!.toLowerCase().replaceAll(' ', '_')}',
        name: cleanProfile.secondProgramName!,
        department: cleanProfile.secondProgramName!,
        type: ProgramType.cap,
        gano: 0.0,
        completedAkts: 0,
      ));
    } else if (cleanProfile.secondProgramType.toUpperCase() == 'MINOR' && cleanProfile.secondProgramName != null) {
      progs.add(Program(
        id: 'minor_${cleanProfile.secondProgramName!.toLowerCase().replaceAll(' ', '_')}',
        name: cleanProfile.secondProgramName!,
        department: cleanProfile.secondProgramName!,
        type: ProgramType.minor,
        gano: 0.0,
        completedAkts: 0,
      ));
    }

    _programs = progs;
    _semesters = [];
    _tasks = [];
    _events = [];
    _sessions = [];
    _documents = [];
    _selectedProgramId = _programs.first.id;

    _persistAll();
    await _firestoreUserService.saveUserProfile(_profile);
    notifyListeners();
  }

  // Getters
  UserProfile get profile => _profile;
  List<Program> get programs => List.unmodifiable(_programs);
  List<Semester> get semesters => List.unmodifiable(_semesters);
  List<TaskItem> get tasks => List.unmodifiable(_tasks);
  List<CalendarEvent> get events => List.unmodifiable(_events);
  List<StudySession> get sessions => List.unmodifiable(_sessions);
  List<ScannedDocument> get documents => List.unmodifiable(_documents);
  String? get selectedProgramId => _selectedProgramId;

  Program? get currentProgram {
    if (_selectedProgramId == null) return _programs.isNotEmpty ? _programs.first : null;
    return _programs.firstWhere((p) => p.id == _selectedProgramId, orElse: () => _programs.first);
  }

  Semester? get currentSemester {
    final filtered = activeProgramSemesters;
    try {
      return filtered.firstWhere((s) => s.isCurrent);
    } catch (_) {
      return filtered.isNotEmpty ? filtered.first : null;
    }
  }

  List<Semester> get activeProgramSemesters {
    if (_selectedProgramId == null) return _semesters;
    return _semesters.where((s) => s.programId == _selectedProgramId).toList();
  }

  List<Course> get activeCourses {
    final sems = activeProgramSemesters;
    final list = <Course>[];
    for (final sem in sems) {
      list.addAll(sem.courses);
    }
    return list;
  }

  List<Course> get currentSemesterCourses {
    final cur = currentSemester;
    if (cur == null) return [];
    return cur.courses;
  }

  // Switch selected program (Main, ÇAP, or All)
  void selectProgram(String? programId) {
    _selectedProgramId = programId;
    notifyListeners();
  }

  // Recalculate GPAs and GANOs
  void recalculateAllMetrics() {
    // 1. Recalculate each semester GPA
    for (int i = 0; i < _semesters.length; i++) {
      final sem = _semesters[i];
      final gpa = GradeCalculator.calculateSemesterGpa(sem.courses);
      int akts = 0;
      for (final c in sem.courses) {
        akts += c.akts;
      }
      _semesters[i] = sem.copyWith(semesterGpa: gpa, totalAkts: akts);
    }

    // 2. Recalculate GANO for each program incorporating academic baseline
    for (int i = 0; i < _programs.length; i++) {
      final prog = _programs[i];
      final progSemesters = _semesters.where((s) => s.programId == prog.id).toList();
      final isMain = prog.type == ProgramType.main;
      final baselineGpa = isMain ? _profile.previousGpa : null;
      final baselineAkts = isMain ? _profile.previousCompletedAKTS : 0;

      final gano = GradeCalculator.calculateCumulativeGanoWithBaseline(
        progSemesters,
        baselineGpa: baselineGpa,
        baselineAkts: baselineAkts,
      );
      final completedAkts = GradeCalculator.calculateTotalCompletedAkts(
        progSemesters,
        baselineAkts: baselineAkts,
      );
      _programs[i] = prog.copyWith(gano: gano ?? 0.0, completedAkts: completedAkts);
    }

    // 3. Update main profile metrics from main program
    if (_programs.isNotEmpty) {
      final mainProg = _programs.firstWhere(
        (p) => p.type == ProgramType.main,
        orElse: () => _programs.first,
      );
      _profile = _profile.copyWith(
        currentGano: mainProg.gano,
        completedAkts: mainProg.completedAkts,
      );
    }

    _persistAll();
    notifyListeners();
  }

  void _persistAll() {
    _storage.saveProfile(_profile);
    _storage.savePrograms(_programs);
    _storage.saveSemesters(_semesters);
    _storage.saveTasks(_tasks);
    _storage.saveEvents(_events);
    _storage.saveSessions(_sessions);
    _storage.saveDocuments(_documents);

    // Sync profile to Cloud Firestore
    _firestoreUserService.saveUserProfile(_profile);
  }

  // Course Management
  void addCourse({
    required String semesterId,
    required String code,
    required String name,
    required String instructor,
    required int credit,
    required int akts,
    required String programId,
    String programType = 'MAIN',
    String? programName,
    String? letterGrade,
  }) {
    final semIndex = _semesters.indexWhere((s) => s.id == semesterId);
    if (semIndex == -1) return;

    final newCourse = Course(
      id: 'c_${DateTime.now().millisecondsSinceEpoch}',
      code: code,
      name: name,
      instructor: instructor,
      credit: credit,
      akts: akts,
      programId: programId,
      programType: programType,
      programName: programName,
      semesterId: semesterId,
      letterGrade: letterGrade,
      isCompleted: letterGrade != null,
    );

    final updatedCourses = List<Course>.from(_semesters[semIndex].courses)..add(newCourse);
    _semesters[semIndex] = _semesters[semIndex].copyWith(courses: updatedCourses);
    recalculateAllMetrics();

    _firestoreUserService.saveCourse(_profile.id, semesterId, newCourse);
  }

  void updateCourse(Course updatedCourse) {
    for (int i = 0; i < _semesters.length; i++) {
      final sem = _semesters[i];
      final cIdx = sem.courses.indexWhere((c) => c.id == updatedCourse.id);
      if (cIdx != -1) {
        final updatedCourses = List<Course>.from(sem.courses);
        updatedCourses[cIdx] = updatedCourse;
        _semesters[i] = sem.copyWith(courses: updatedCourses);
        _firestoreUserService.saveCourse(_profile.id, sem.id, updatedCourse);
        break;
      }
    }
    recalculateAllMetrics();
  }

  void deleteCourse(String courseId) {
    String? targetSemId;
    for (int i = 0; i < _semesters.length; i++) {
      final sem = _semesters[i];
      final updatedCourses = sem.courses.where((c) => c.id != courseId).toList();
      if (updatedCourses.length != sem.courses.length) {
        targetSemId = sem.id;
        _semesters[i] = sem.copyWith(courses: updatedCourses);
        break;
      }
    }
    if (targetSemId != null) {
      _firestoreUserService.deleteCourse(_profile.id, targetSemId, courseId);
    }
    _tasks.removeWhere((t) => t.courseId == courseId);
    _events.removeWhere((e) => e.courseId == courseId);
    _documents.removeWhere((d) => d.courseId == courseId);
    recalculateAllMetrics();
  }

  // Semester Management
  void addSemester({
    required String academicYear,
    required String term,
    required String programId,
    bool isCurrent = false,
  }) {
    if (isCurrent) {
      for (int i = 0; i < _semesters.length; i++) {
        if (_semesters[i].programId == programId) {
          _semesters[i] = _semesters[i].copyWith(isCurrent: false);
        }
      }
    }

    final newSem = Semester(
      id: 'sem_${DateTime.now().millisecondsSinceEpoch}',
      programId: programId,
      academicYear: academicYear,
      term: term,
      isCurrent: isCurrent,
    );

    _semesters.insert(0, newSem);
    recalculateAllMetrics();

    _firestoreUserService.saveSemester(_profile.id, newSem);
  }

  // Task Management
  void addTask({
    required String courseId,
    required String courseCode,
    required String title,
    required String description,
    required DateTime dueDate,
    required String priority,
    int estimatedStudyMinutes = 60,
  }) {
    final task = TaskItem(
      id: 'task_${DateTime.now().millisecondsSinceEpoch}',
      courseId: courseId,
      courseCode: courseCode,
      title: title,
      description: description,
      dueDate: dueDate,
      priority: priority,
      estimatedStudyMinutes: estimatedStudyMinutes,
    );
    _tasks.insert(0, task);
    _storage.saveTasks(_tasks);
    notifyListeners();
  }

  void toggleTaskComplete(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      _tasks[idx] = task.copyWith(
        isCompleted: !task.isCompleted,
        progress: !task.isCompleted ? 1.0 : 0.0,
      );
      _storage.saveTasks(_tasks);
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((t) => t.id == taskId);
    _storage.saveTasks(_tasks);
    notifyListeners();
  }

  // Calendar Events
  void addEvent(CalendarEvent event) {
    _events.insert(0, event);
    _storage.saveEvents(_events);
    notifyListeners();
  }

  void deleteEvent(String eventId) {
    _events.removeWhere((e) => e.id == eventId);
    _storage.saveEvents(_events);
    notifyListeners();
  }

  // Scanned Documents
  void addDocument(ScannedDocument doc) {
    _documents.insert(0, doc);
    _storage.saveDocuments(_documents);
    notifyListeners();
  }

  void deleteDocument(String docId) {
    _documents.removeWhere((d) => d.id == docId);
    _storage.saveDocuments(_documents);
    notifyListeners();
  }

  // Pomodoro Study Sessions
  void addStudySession(StudySession session) {
    _sessions.insert(0, session);
    _storage.saveSessions(_sessions);
    _firestoreUserService.saveSessionSummary(_profile.id, session);
    notifyListeners();
  }

  // Profile and Onboarding
  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    final updatedPrograms = <Program>[
      Program(
        id: 'main_${_profile.department.toLowerCase().replaceAll(' ', '_')}',
        name: _profile.department,
        department: _profile.department,
        type: ProgramType.main,
        gano: _profile.currentGano,
        completedAkts: _profile.completedAkts,
      ),
    ];

    if (_profile.hasDoubleMajor && _profile.doubleMajorDepartment != null) {
      updatedPrograms.add(
        Program(
          id: 'cap_second',
          name: _profile.doubleMajorDepartment!,
          department: _profile.doubleMajorDepartment!,
          type: ProgramType.cap,
        ),
      );
    }

    if (_profile.hasMinor && _profile.minorDepartment != null) {
      updatedPrograms.add(
        Program(
          id: 'minor_prog',
          name: _profile.minorDepartment!,
          department: _profile.minorDepartment!,
          type: ProgramType.minor,
        ),
      );
    }

    _programs = updatedPrograms;
    recalculateAllMetrics();
  }

  // Productivity Metrics
  int get focusMinutesToday {
    final now = DateTime.now();
    int total = 0;
    for (final s in _sessions) {
      if (s.timestamp.year == now.year &&
          s.timestamp.month == now.month &&
          s.timestamp.day == now.day) {
        total += s.durationMinutes;
      }
    }
    return total;
  }

  int get focusMinutesThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int total = 0;
    for (final s in _sessions) {
      if (s.timestamp.isAfter(weekStart)) {
        total += s.durationMinutes;
      }
    }
    return total;
  }

  Map<String, int> get focusMinutesByCourse {
    final map = <String, int>{};
    for (final s in _sessions) {
      final code = s.courseCode.isNotEmpty ? s.courseCode : 'General Study';
      map[code] = (map[code] ?? 0) + s.durationMinutes;
    }
    return map;
  }

  // --- Real Gamification Logic (GamificationService) ---
  Future<void> addXp(int amount, {String? reason, String? idempotencyKey}) async {
    final key = idempotencyKey ?? 'xp_${DateTime.now().microsecondsSinceEpoch}';
    final awarded = await GamificationService.instance.awardXp(
      userId: _profile.id,
      amount: amount,
      reason: reason ?? 'Academic Focus Activity',
      idempotencyKey: key,
    );

    if (awarded != null && awarded > 0) {
      final newTotalXp = _profile.xp + awarded;
      final newLevel = GamificationService.calculateLevel(newTotalXp);
      final nextLevelXp = GamificationService.xpForLevel(newLevel + 1);

      _profile = _profile.copyWith(
        xp: newTotalXp,
        level: newLevel,
        maxXp: nextLevelXp,
      );
      _persistAll();
      notifyListeners();
    }
  }

  Future<void> addFocusMinutes(int minutes) async {
    _profile = _profile.copyWith(
      focusMinutesTotal: _profile.focusMinutesTotal + minutes,
    );
    _persistAll();
    notifyListeners();
  }

  Future<void> completeTaskAndReward(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      final task = _tasks[idx];
      _tasks[idx] = task.copyWith(isCompleted: true);
      _storage.saveTasks(_tasks);
      final isHigh = task.priority.toLowerCase() == 'high';
      final reward = isHigh
          ? GamificationService.xpHighPriorityTask
          : GamificationService.xpNormalTask;
      await addXp(
        reward,
        reason: 'Task Completed: ${task.title}',
        idempotencyKey: 'task_${task.id}',
      );
      notifyListeners();
    }
  }

  void _updateStreakOnSession(DateTime sessionDate) {
    final now = sessionDate;
    final today = DateTime(now.year, now.month, now.day);

    final previousSessions = _sessions.skip(1).toList();
    if (previousSessions.isEmpty) {
      _profile = _profile.copyWith(studyStreakDays: 1);
      return;
    }

    final lastDate = previousSessions.first.timestamp;
    final lastDay = DateTime(lastDate.year, lastDate.month, lastDate.day);
    final diffDays = today.difference(lastDay).inDays;

    if (diffDays == 1) {
      _profile = _profile.copyWith(studyStreakDays: _profile.studyStreakDays + 1);
    } else if (diffDays == 0) {
      if (_profile.studyStreakDays == 0) {
        _profile = _profile.copyWith(studyStreakDays: 1);
      }
    } else {
      _profile = _profile.copyWith(studyStreakDays: 1);
    }
  }

  Future<void> recordStudySessionAndReward(StudySession session, {int? earnedXp}) async {
    _sessions.insert(0, session);
    _storage.saveSessions(_sessions);
    _firestoreUserService.saveSessionSummary(_profile.id, session);
    _updateStreakOnSession(session.timestamp);
    await addFocusMinutes(session.durationMinutes);

    int xp = earnedXp ?? 0;
    if (earnedXp == null) {
      if (session.durationMinutes >= 90) {
        xp = GamificationService.xpFocus90PlusMin;
      } else if (session.durationMinutes >= 50) {
        xp = GamificationService.xpFocus50To60Min;
      } else if (session.durationMinutes >= 25) {
        xp = GamificationService.xpFocus25To30Min;
      }
    }

    if (xp > 0) {
      await addXp(
        xp,
        reason: 'Focus Session Completed (${session.durationMinutes}m)',
        idempotencyKey: 'session_${session.id}',
      );
    }
    notifyListeners();
  }

  Future<void> unlockAchievement(String title) async {
    if (!_profile.achievements.contains(title)) {
      final updated = List<String>.from(_profile.achievements)..add(title);
      _profile = _profile.copyWith(achievements: updated);
      _persistAll();
      await addXp(100, reason: 'Achievement Unlocked: $title', idempotencyKey: 'ach_$title');
      notifyListeners();
    }
  }
}
