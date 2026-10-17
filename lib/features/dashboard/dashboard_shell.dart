import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/pomodoro_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/study_together_service.dart';
import '../../core/theme/app_colors.dart';
import '../calendar/calendar_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../profile/profile_screen.dart';
import '../study_together/study_together_entry_screen.dart';
import 'dashboard_screen.dart';

import '../../core/services/auth_service.dart';

class DashboardShell extends StatefulWidget {
  final AcademicService academicService;
  final StorageService storage;
  final AuthService? authService;

  const DashboardShell({
    super.key,
    required this.academicService,
    required this.storage,
    this.authService,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _currentIndex = 0;
  late final PomodoroService _pomodoroService;
  late final StudyTogetherService _studyTogetherService;

  @override
  void initState() {
    super.initState();
    _pomodoroService = PomodoroService(widget.academicService);
    _studyTogetherService = StudyTogetherService(widget.academicService);
  }

  @override
  void dispose() {
    _pomodoroService.dispose();
    _studyTogetherService.dispose();
    super.dispose();
  }

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  void _startTaskFocus(TaskItem task) {
    _pomodoroService.selectTask(task);
    setState(() => _currentIndex = 2); // Switch to Focus tab
  }

  void _startCourseFocus(Course course) {
    _pomodoroService.selectCourse(course);
    setState(() => _currentIndex = 2); // Switch to Focus tab
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      DashboardScreen(
        academicService: widget.academicService,
        storage: widget.storage,
        onNavigateTab: _onNavigateTab,
        onStartTaskFocus: _startTaskFocus,
        studyTogetherService: _studyTogetherService,
      ),
      CalendarScreen(
        academicService: widget.academicService,
      ),
      PomodoroScreen(
        pomodoroService: _pomodoroService,
        academicService: widget.academicService,
      ),
      StudyTogetherEntryScreen(
        studyService: _studyTogetherService,
        academicService: widget.academicService,
      ),
      ProfileScreen(
        academicService: widget.academicService,
        storage: widget.storage,
        authService: widget.authService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        indicatorColor: const Color(0xFFEFF6FF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded, color: AppColors.brandBlue),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today_rounded, color: AppColors.brandBlue),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded, color: AppColors.brandBlue),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups_rounded, color: AppColors.gamifyPurple),
            label: 'Together',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded, color: AppColors.brandBlue),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
