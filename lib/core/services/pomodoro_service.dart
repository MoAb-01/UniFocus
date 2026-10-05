import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/course.dart';
import '../models/task_item.dart';
import '../models/study_session.dart';
import 'academic_service.dart';

enum PomodoroState {
  idle,
  running,
  paused,
  breakTime,
}

class PomodoroService extends ChangeNotifier {
  final AcademicService _academicService;

  int _workMinutes = 50;
  int _breakMinutes = 10;
  int _remainingSeconds = 50 * 60;
  PomodoroState _state = PomodoroState.idle;
  Timer? _timer;

  Course? _selectedCourse;
  TaskItem? _selectedTask;
  int _completedSessionsToday = 0;
  int _consecutiveMinutesStudied = 0;

  String? _pendingBreakRecommendation;

  PomodoroService(this._academicService) {
    _remainingSeconds = _workMinutes * 60;
  }

  // Getters
  int get workMinutes => _workMinutes;
  int get breakMinutes => _breakMinutes;
  int get remainingSeconds => _remainingSeconds;
  int get totalSeconds => (_state == PomodoroState.breakTime ? _breakMinutes : _workMinutes) * 60;
  PomodoroState get state => _state;
  bool get isRunning => _state == PomodoroState.running;
  bool get isBreak => _state == PomodoroState.breakTime;
  Course? get selectedCourse => _selectedCourse;
  TaskItem? get selectedTask => _selectedTask;
  int get completedSessionsToday => _completedSessionsToday;
  String? get pendingBreakRecommendation => _pendingBreakRecommendation;

  void selectCourse(Course? course) {
    _selectedCourse = course;
    notifyListeners();
  }

  void selectTask(TaskItem? task) {
    _selectedTask = task;
    if (task != null && task.courseCode.isNotEmpty) {
      // Find course matching task
      try {
        _selectedCourse = _academicService.activeCourses.firstWhere((c) => c.id == task.courseId);
      } catch (_) {}
    }
    notifyListeners();
  }

  void setDurations({required int workMinutes, required int breakMinutes}) {
    _workMinutes = workMinutes;
    _breakMinutes = breakMinutes;
    if (_state == PomodoroState.idle) {
      _remainingSeconds = _workMinutes * 60;
    }
    notifyListeners();
  }

  void startOrResume() {
    if (_state == PomodoroState.running) return;

    _state = PomodoroState.running;
    _startTimer();
    notifyListeners();
  }

  void pause() {
    if (_state != PomodoroState.running) return;
    _state = PomodoroState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void reset() {
    _timer?.cancel();
    _state = PomodoroState.idle;
    _remainingSeconds = _workMinutes * 60;
    notifyListeners();
  }

  void skipToNextPhase() {
    _timer?.cancel();
    if (_state == PomodoroState.breakTime) {
      // Break finished, return to focus mode
      _state = PomodoroState.idle;
      _remainingSeconds = _workMinutes * 60;
    } else {
      // Focus session manually finished
      _onFocusSessionCompleted();
    }
    notifyListeners();
  }

  void clearBreakRecommendation() {
    _pendingBreakRecommendation = null;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        if (_state == PomodoroState.running) {
          _onFocusSessionCompleted();
        } else if (_state == PomodoroState.breakTime) {
          _state = PomodoroState.idle;
          _remainingSeconds = _workMinutes * 60;
          notifyListeners();
        }
      }
    });
  }

  bool _hasPendingCelebration = false;
  bool get hasPendingCelebration => _hasPendingCelebration;

  void clearCelebration() {
    _hasPendingCelebration = false;
    notifyListeners();
  }

  void _onFocusSessionCompleted() {
    _completedSessionsToday++;
    _consecutiveMinutesStudied += _workMinutes;

    // Record study session in AcademicService with XP reward
    final session = StudySession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      courseId: _selectedCourse?.id ?? '',
      courseCode: _selectedCourse?.code ?? _selectedTask?.courseCode ?? 'FOCUS',
      taskTitle: _selectedTask?.title ?? _selectedCourse?.name ?? 'Deep Focus Session',
      durationMinutes: _workMinutes,
      breakMinutes: _breakMinutes,
      timestamp: DateTime.now(),
      completed: true,
    );
    _academicService.recordStudySessionAndReward(session, earnedXp: 50);

    _hasPendingCelebration = true;

    // Generate intelligent break recommendation
    _generateBreakRecommendation();

    // Transition to break
    _state = PomodoroState.breakTime;
    _remainingSeconds = _breakMinutes * 60;
    _startTimer();
    notifyListeners();
  }

  void _generateBreakRecommendation() {
    if (_consecutiveMinutesStudied >= 100) {
      _pendingBreakRecommendation =
          'You have completed $_consecutiveMinutesStudied minutes of continuous focus! '
          'We recommend a 15-minute screen-free rest. Drink a glass of water, stretch your neck and shoulders, and look at objects in the distance to relax your eye muscles.';
    } else if (_workMinutes >= 45) {
      _pendingBreakRecommendation =
          'Great 50-minute study session completed! Take a 10-minute break: walk around, hydrate, and give your mind a moment to consolidate what you learned.';
    } else {
      _pendingBreakRecommendation =
          'Solid 25-minute Pomodoro completed! Stand up, stretch, and take 5 restful minutes before your next sprint.';
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
