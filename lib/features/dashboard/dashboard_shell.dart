import 'package:flutter/material.dart';
import '../../core/models/study_room.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/pomodoro_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/study_together_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../calendar/calendar_screen.dart';
import '../pomodoro/pomodoro_screen.dart';
import '../profile/profile_screen.dart';
import '../study_together/study_together_entry_screen.dart';
import 'dashboard_screen.dart';

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
    _studyTogetherService.addListener(_onStudyServiceChanged);
  }

  @override
  void dispose() {
    _studyTogetherService.removeListener(_onStudyServiceChanged);
    _pomodoroService.dispose();
    _studyTogetherService.dispose();
    super.dispose();
  }

  void _onStudyServiceChanged() {
    if (mounted) setState(() {});
  }

  void _onNavigateTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final activeRoom = _studyTogetherService.activeRoom;
    final isInsideActiveArena = activeRoom != null &&
        (activeRoom.status == StudyRoomStatus.active ||
            activeRoom.status == StudyRoomStatus.breakMode ||
            activeRoom.status == StudyRoomStatus.groupBreakRequested);

    final screens = [
      DashboardScreen(
        academicService: widget.academicService,
        pomodoroService: _pomodoroService,
        onNavigateTab: _onNavigateTab,
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
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          if (!isInsideActiveArena)
            buildFloatingDock(
              context: context,
              currentIndex: _currentIndex,
              onTap: _onNavigateTab,
            ),
        ],
      ),
    );
  }
}

Widget buildFloatingDock({
  required BuildContext context,
  required int currentIndex,
  required Function(int) onTap,
}) {
  final bottomInset = MediaQuery.of(context).padding.bottom;
  final isWide = MediaQuery.of(context).size.width >= 680;

  return Positioned(
    left: 16,
    right: 16,
    bottom: bottomInset > 0 ? bottomInset + 8 : 20,
    child: Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 760),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF2B2421),
              offset: Offset(0, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: isWide ? MainAxisSize.min : MainAxisSize.max,
          mainAxisAlignment:
              isWide ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            _dockTabItem(
              index: 0,
              icon: Icons.home_rounded,
              label: isWide ? 'Home & Focus' : 'Home',
              currentIndex: currentIndex,
              isWide: isWide,
              onTap: onTap,
            ),
            if (isWide) const SizedBox(width: 4),
            _dockTabItem(
              index: 1,
              icon: Icons.event_note_rounded,
              label: isWide ? 'Events / Docket' : 'Events',
              currentIndex: currentIndex,
              isWide: isWide,
              onTap: onTap,
            ),
            if (isWide) const SizedBox(width: 4),
            _dockTabItem(
              index: 2,
              icon: Icons.timer_outlined,
              label: isWide ? 'Timer' : 'Timer',
              currentIndex: currentIndex,
              isWide: isWide,
              onTap: onTap,
            ),
            if (isWide) const SizedBox(width: 4),
            _dockTabItem(
              index: 3,
              icon: Icons.groups_outlined,
              label: isWide ? 'Together' : 'Together',
              currentIndex: currentIndex,
              isWide: isWide,
              onTap: onTap,
            ),
            if (isWide) const SizedBox(width: 4),
            _dockTabItem(
              index: 4,
              icon: Icons.person_outline_rounded,
              label: isWide ? 'Archive & Profile' : 'Profile',
              currentIndex: currentIndex,
              isWide: isWide,
              onTap: onTap,
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _dockTabItem({
  required int index,
  required IconData icon,
  required String label,
  required int currentIndex,
  required bool isWide,
  required Function(int) onTap,
}) {
  final isSelected = index == currentIndex;
  final fgColor = isSelected ? const Color(0xFFFFFFFF) : const Color(0xFF424842);

  final content = GestureDetector(
    onTap: () => onTap(index),
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.symmetric(
        horizontal: isWide ? 16 : 10,
        vertical: isWide ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF2E5339) : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: isWide
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fgColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: AppTypography.courierPrime(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: fgColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: fgColor),
                const SizedBox(height: 2),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.courierPrime(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: fgColor,
                    height: 1.0,
                  ),
                ),
              ],
            ),
    ),
  );

  if (isWide) return content;
  return Expanded(child: content);
}
