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

class AcademicService extends ChangeNotifier {
  final StorageService _storage;

  late UserProfile _profile;
  List<Program> _programs = [];
  List<Semester> _semesters = [];
  List<TaskItem> _tasks = [];
  List<CalendarEvent> _events = [];
  List<StudySession> _sessions = [];
  List<ScannedDocument> _documents = [];
  String? _selectedProgramId; // null = all programs

  AcademicService(this._storage) {
    loadData();
  }

  void loadData() {
    _profile = _storage.getProfile();
    _programs = _storage.getPrograms();
    _semesters = _storage.getSemesters();
    _tasks = _storage.getTasks();
    _events = _storage.getEvents();
    _sessions = _storage.getSessions();
    _documents = _storage.getDocuments();

    // Default to main program if available
    if (_programs.isNotEmpty && _selectedProgramId == null) {
      _selectedProgramId = _programs.first.id;
    }
    recalculateAllMetrics();
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

    // 2. Recalculate GANO for each program
    for (int i = 0; i < _programs.length; i++) {
      final prog = _programs[i];
      final progSemesters = _semesters.where((s) => s.programId == prog.id).toList();
      final gano = GradeCalculator.calculateCumulativeGano(progSemesters);
      final completedAkts = GradeCalculator.calculateTotalCompletedAkts(progSemesters);
      _programs[i] = prog.copyWith(gano: gano, completedAkts: completedAkts);
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
      semesterId: semesterId,
      letterGrade: letterGrade,
      isCompleted: letterGrade != null,
    );

    final updatedCourses = List<Course>.from(_semesters[semIndex].courses)..add(newCourse);
    _semesters[semIndex] = _semesters[semIndex].copyWith(courses: updatedCourses);
    recalculateAllMetrics();
  }

  void updateCourse(Course updatedCourse) {
    for (int i = 0; i < _semesters.length; i++) {
      final sem = _semesters[i];
      final cIdx = sem.courses.indexWhere((c) => c.id == updatedCourse.id);
      if (cIdx != -1) {
        final updatedCourses = List<Course>.from(sem.courses);
        updatedCourses[cIdx] = updatedCourse;
        _semesters[i] = sem.copyWith(courses: updatedCourses);
        break;
      }
    }
    recalculateAllMetrics();
  }

  void deleteCourse(String courseId) {
    for (int i = 0; i < _semesters.length; i++) {
      final sem = _semesters[i];
      final updatedCourses = sem.courses.where((c) => c.id != courseId).toList();
      if (updatedCourses.length != sem.courses.length) {
        _semesters[i] = sem.copyWith(courses: updatedCourses);
        break;
      }
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
    notifyListeners();
  }

  // Profile and Onboarding
  void updateProfile(UserProfile newProfile) {
    _profile = newProfile;
    // Update or create programs if ÇAP/Yandal changed
    final updatedPrograms = <Program>[
      Program(
        id: 'main_ceng',
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

  // --- Gamification Logic ---
  Future<void> addXp(int amount, {String? reason}) async {
    int currentXp = _profile.xp + amount;
    int currentLevel = _profile.level;
    int currentMax = _profile.maxXp;

    while (currentXp >= currentMax) {
      currentXp -= currentMax;
      currentLevel += 1;
      currentMax = (currentLevel * 300) + 1000;
    }

    _profile = _profile.copyWith(
      xp: currentXp,
      level: currentLevel,
      maxXp: currentMax,
    );
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> addFocusMinutes(int minutes) async {
    _profile = _profile.copyWith(
      focusMinutesTotal: _profile.focusMinutesTotal + minutes,
    );
    await _storage.saveProfile(_profile);
    notifyListeners();
  }

  Future<void> completeTaskAndReward(String taskId) async {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx != -1) {
      _tasks[idx] = _tasks[idx].copyWith(isCompleted: true);
      await _storage.saveTasks(_tasks);
      await addXp(40, reason: 'Task Completed: ${_tasks[idx].title}');
      notifyListeners();
    }
  }

  Future<void> recordStudySessionAndReward(StudySession session, {int earnedXp = 50}) async {
    _sessions.insert(0, session);
    await _storage.saveSessions(_sessions);
    await addFocusMinutes(session.durationMinutes);
    await addXp(earnedXp, reason: 'Focus Session Completed');
    notifyListeners();
  }

  Future<void> unlockAchievement(String title) async {
    if (!_profile.achievements.contains(title)) {
      final updated = List<String>.from(_profile.achievements)..add(title);
      _profile = _profile.copyWith(achievements: updated);
      await _storage.saveProfile(_profile);
      await addXp(100, reason: 'Achievement Unlocked: $title');
      notifyListeners();
    }
  }
}
