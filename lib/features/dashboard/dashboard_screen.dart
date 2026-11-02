import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/models/calendar_event.dart';
import '../../core/models/program.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/pomodoro_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class DashboardScreen extends StatefulWidget {
  final AcademicService academicService;
  final PomodoroService pomodoroService;
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.academicService,
    required this.pomodoroService,
    required this.onNavigateTab,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _activeTabMinutes = 25; // 50, 10, or 25
  int _extraSecondsOffset = 0;
  bool _ambientPlaying = true;

  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onServiceUpdate);
    widget.pomodoroService.addListener(_onServiceUpdate);
    try {
      if (widget.pomodoroService.isBreak) {
        _activeTabMinutes = 10;
      } else {
        _activeTabMinutes = widget.pomodoroService.workMinutes;
      }
    } catch (_) {
      _activeTabMinutes = 25;
    }
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    widget.pomodoroService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  // Safe getters to prevent any DDC hot-reload undefined TypeError
  String _safeName() {
    try {
      final raw = widget.academicService.profile.name;
      if (raw.trim().isNotEmpty) return raw.trim();
    } catch (_) {}
    return 'STUDENT';
  }

  String _safeDepartment() {
    try {
      final raw = widget.academicService.profile.department;
      if (raw.trim().isNotEmpty) return raw.trim();
    } catch (_) {}
    return 'University Program';
  }

  String _safeSemesterLabel() {
    try {
      final raw = widget.academicService.profile.currentSemester;
      if (raw != null && raw.trim().isNotEmpty) return raw.trim();
    } catch (_) {}
    return 'Semester 1';
  }

  String _safeGano() {
    try {
      final g = widget.academicService.profile.currentGano;
      if (g > 0) return g.toStringAsFixed(2);
      final prev = widget.academicService.profile.previousGpa;
      if (prev != null && prev > 0) return prev.toStringAsFixed(2);
    } catch (_) {}
    return '0.00';
  }

  int _safeStreak() {
    try {
      final s = widget.academicService.profile.studyStreakDays;
      return s;
    } catch (_) {
      return 0;
    }
  }

  String _safeFocusedHoursToday() {
    try {
      final mins = widget.academicService.focusMinutesToday;
      if (mins > 0) {
        return '${(mins / 60.0).toStringAsFixed(1)}h Focused Today';
      }
      final totalMins = widget.academicService.profile.focusMinutesTotal;
      if (totalMins > 0) {
        return '${(totalMins / 60.0).toStringAsFixed(1)}h Focused Total';
      }
    } catch (_) {}
    return '0.0h Focused Today';
  }

  void _selectTimerTab(int minutes) {
    setState(() {
      _activeTabMinutes = minutes;
      _extraSecondsOffset = 0;
    });
    try {
      if (minutes == 10) {
        widget.pomodoroService.setDurations(workMinutes: 50, breakMinutes: 10);
      } else if (minutes == 25) {
        widget.pomodoroService.setDurations(workMinutes: 25, breakMinutes: 5);
      } else {
        widget.pomodoroService.setDurations(workMinutes: 50, breakMinutes: 10);
      }
    } catch (_) {}
  }

  void _toggleTimer() {
    try {
      if (widget.pomodoroService.isRunning) {
        widget.pomodoroService.pause();
      } else {
        widget.pomodoroService.startOrResume();
      }
    } catch (_) {}
  }

  void _addFiveMinutes() {
    setState(() {
      _extraSecondsOffset += 300;
    });
  }

  void _completeOrSkipSprint() {
    setState(() {
      _extraSecondsOffset = 0;
    });
    try {
      widget.pomodoroService.skipToNextPhase();
    } catch (_) {}
  }

  void _showAddDocketDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final codeCtrl = TextEditingController(text: 'CS 301');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppColors.onSurface, width: 1.5),
          ),
          title: Text(
            'Pin New Docket Card',
            style: AppTypography.literata(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: codeCtrl,
                style: AppTypography.courierPrime(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  labelText: 'Course Code (e.g. CS 301)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                style: AppTypography.literata(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: AppTypography.plusJakartaSans(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                decoration: const InputDecoration(
                  labelText: 'Study Objective / Margin Note',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'CANCEL',
                style: AppTypography.courierPrime(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                if (title.isEmpty) return;
                widget.academicService.addTask(
                  courseId: 'general',
                  courseCode: codeCtrl.text.trim().isEmpty
                      ? 'STUDY'
                      : codeCtrl.text.trim().toUpperCase(),
                  title: title,
                  description: descCtrl.text.trim().isEmpty
                      ? 'Scheduled deep focus sprint'
                      : descCtrl.text.trim(),
                  dueDate: DateTime.now(),
                  priority: 'High',
                  estimatedStudyMinutes: 50,
                );
                Navigator.of(ctx).pop();
              },
              child: Text(
                'PIN TO DOCKET',
                style: AppTypography.courierPrime(
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => widget.academicService.loadData(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 960;
              final horizontalPadding = constraints.maxWidth >= 600 ? 28.0 : 16.0;

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  116, // Ensures floating bottom pill dock never covers bottom buttons
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. TOP STATUS BANNER / TACTILE DESK LEDGER STRIP
                        _buildTopStatusBanner(constraints.maxWidth),
                        const SizedBox(height: 24),

                        // 2. MAIN SPLIT WORKSPACE DESK (2-Column Grid on Desktop, Stack on Mobile)
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 6,
                                child: Column(
                                  children: [
                                    _buildMechanicalClockHousing(),
                                    const SizedBox(height: 18),
                                    _buildUpcomingEventsCard(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 6,
                                child: _buildTodaysTasksDocket(),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMechanicalClockHousing(),
                              const SizedBox(height: 20),
                              _buildTodaysTasksDocket(),
                              const SizedBox(height: 20),
                              _buildUpcomingEventsCard(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION A: TOP STATUS BANNER & WASHI TAPE (`code.txt` lines 4-54)
  // ===========================================================================
  Widget _buildTopStatusBanner(double maxWidth) {
    final isWide = maxWidth >= 980;
    final name = _safeName();
    final dept = _safeDepartment();
    final semLabel = _safeSemesterLabel();
    final gano = _safeGano();
    final streak = _safeStreak();
    final focusedToday = _safeFocusedHoursToday();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow, // #FFF1EC
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: AppColors.onSurface, // #211A17
                offset: Offset(0, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: isWide
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 5,
                      child: _buildStudentAcademicPill(
                        name: name,
                        dept: dept,
                        semLabel: semLabel,
                        gano: gano,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      flex: 4,
                      child: _buildAtmosphereDeckPill(),
                    ),
                    const SizedBox(width: 12),
                    _buildRubberStampStreak(
                      streak: streak,
                      focusedToday: focusedToday,
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildStudentAcademicPill(
                      name: name,
                      dept: dept,
                      semLabel: semLabel,
                      gano: gano,
                    ),
                    const SizedBox(height: 10),
                    _buildAtmosphereDeckPill(),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildRubberStampStreak(
                        streak: streak,
                        focusedToday: focusedToday,
                      ),
                    ),
                  ],
                ),
        ),

        // Tilted Decorative Washi Tape Strip Left (`-top-3 left-10 -rotate-2`)
        Positioned(
          top: -10,
          left: 36,
          child: IgnorePointer(
            child: Transform.rotate(
              angle: -0.035,
              child: Container(
                width: 112,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xCCFFDBC9), // bg-secondary-fixed/80
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x18000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'SEMESTER VI',
                  style: AppTypography.courierPrime(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.onSecondaryFixedVariant.withOpacity(0.75),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAcademicPill({
    required String name,
    required String dept,
    required String semLabel,
    required String gano,
  }) {
    final initials = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface, // #FFF8F6
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.onSurface,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 48x48 Rounded-lg Avatar with green online status dot
          Stack(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer, // #F9EBE6
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.onSurface,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTypography.literata(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer, // #2E5339
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.surface, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.literata(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildAcademicDegreeSubtitle(dept, semLabel, gano),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.courierPrime(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildAcademicDegreeSubtitle(String dept, String semLabel, String gano) {
    final progs = widget.academicService.programs;
    final capProg = progs.where((p) => p.type == ProgramType.cap).firstOrNull;
    final minorProg = progs.where((p) => p.type == ProgramType.minor).firstOrNull;

    String text = 'B.S. $dept • $semLabel • GANO $gano';
    if (capProg != null) {
      text += ' • ÇAP: ${capProg.name}';
    } else if (minorProg != null) {
      text += ' • Yandal: ${minorProg.name}';
    }
    return text;
  }

  Widget _buildAtmosphereDeckPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface, // #FFF8F6
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.onSurface,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer, // #3A497A
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.onSurface,
                  offset: Offset(0, 1),
                  blurRadius: 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.headphones_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ATMOSPHERE DECK',
                  style: AppTypography.courierPrime(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: AppTypography.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                    children: [
                      const TextSpan(text: 'Lo-Fi Rainy Attic '),
                      TextSpan(
                        text: _ambientPlaying
                            ? '• Rain & Mech Switches'
                            : '• Deck Muted',
                        style: AppTypography.courierPrime(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => setState(() => _ambientPlaying = !_ambientPlaying),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: _ambientPlaying
                    ? AppColors.surfaceContainer
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Icon(
                Icons.graphic_eq_rounded,
                size: 16,
                color: _ambientPlaying
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRubberStampStreak({
    required int streak,
    required String focusedToday,
  }) {
    return Transform.rotate(
      angle: -0.017, // -rotate-1
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer, // #F9EBE6
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.onSurface,
              offset: Offset(0, 2),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 20,
                color: AppColors.secondary, // #994703
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$streak-DAY STREAK',
                  style: AppTypography.courierPrime(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.secondary,
                  ),
                ),
                Text(
                  focusedToday,
                  style: AppTypography.courierPrime(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'LEDGER',
                  style: AppTypography.courierPrime(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  'NO. 842',
                  style: AppTypography.courierPrime(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION B: PHYSICAL MECHANICAL RADIAL CLOCK HOUSING (`code.txt` lines 60-140)
  // ===========================================================================
  Widget _buildMechanicalClockHousing() {
    int remainingSec = widget.pomodoroService.remainingSeconds + _extraSecondsOffset;
    int totalSec = widget.pomodoroService.totalSeconds + _extraSecondsOffset;
    bool isRunning = widget.pomodoroService.isRunning;

    if (totalSec <= 0) totalSec = _activeTabMinutes * 60;
    if (remainingSec < 0) remainingSec = 0;

    final mins = (remainingSec ~/ 60).toString().padLeft(2, '0');
    final secs = (remainingSec % 60).toString().padLeft(2, '0');
    final progress = totalSec > 0
        ? (remainingSec / totalSec).clamp(0.0, 1.0)
        : 1.0;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow, // #FFF1EC
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.onSurface, // #211A17
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TIMER',
                        style: AppTypography.courierPrime(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'SPRINT ACTIVE',
                        style: AppTypography.courierPrime(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Notebook Tab Mode Selectors (`50m Focus`, `10m Break`, `25m Focus`)
              Row(
                children: [
                  _buildNotebookTab(
                    minutes: 50,
                    label: '50m Focus',
                    showGreenDot: true,
                  ),
                  const SizedBox(width: 8),
                  _buildNotebookTab(
                    minutes: 10,
                    label: '10m Break',
                    showGreenDot: false,
                  ),
                  const SizedBox(width: 8),
                  _buildNotebookTab(
                    minutes: 25,
                    label: '25m Focus',
                    showGreenDot: false,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Clock Face Radial Display Housing
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface, // #FFF8F6
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.onSurface.withOpacity(0.06),
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: SizedBox(
                    width: 248,
                    height: 248,
                    child: CustomPaint(
                      painter: _AnalogRadialClockPainter(
                        progress: progress,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$mins:$secs',
                              style: AppTypography.literata(
                                fontSize: 54,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSurface,
                                letterSpacing: -1.0,
                                height: 1.0,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _activeTabMinutes == 10
                                  ? 'REST INTERVAL'
                                  : 'DEEP WORK BLOCK',
                              style: AppTypography.courierPrime(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.0,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Big Physical "Start / Pause Sprint" Push Button
              GestureDetector(
                onTap: _toggleTimer,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary, // #163C24
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.onPrimaryFixed, // #00210E
                        offset: Offset(0, 5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isRunning
                            ? Icons.pause_circle_outline_rounded
                            : Icons.play_circle_outline_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isRunning ? 'Pause' : (remainingSec < totalSec ? 'Resume' : 'Start'),
                        style: AppTypography.literata(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Quick Interval Mechanical Micro-Keys (`+5 Mins`, `DONE`, `FULL CLOCK`)
              Row(
                children: [
                  Expanded(
                    child: _buildMicroKeyButton(
                      label: '+5 Mins',
                      onTap: _addFiveMinutes,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMicroKeyButton(
                      label: 'DONE',
                      onTap: _completeOrSkipSprint,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMicroKeyButton(
                      label: 'FOCUS TAB',
                      onTap: () => widget.onNavigateTab(2),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Subtle Vintage Plate Rivets on Top Corners (`top-3 left-3` & `top-3 right-3`)
        Positioned(
          top: 12,
          left: 12,
          child: _buildCornerRivet(),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: _buildCornerRivet(),
        ),
      ],
    );
  }

  Widget _buildCornerRivet() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: AppColors.outlineVariant.withOpacity(0.65),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.onSurface.withOpacity(0.25),
          width: 0.8,
        ),
      ),
    );
  }

  Widget _buildNotebookTab({
    required int minutes,
    required String label,
    required bool showGreenDot,
  }) {
    final isSelected = _activeTabMinutes == minutes;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTimerTab(minutes),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surface // #FFF8F6
                : AppColors.surfaceVariant.withOpacity(0.75), // #EDE0DB
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: AppColors.onSurface,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showGreenDot) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer, // #2E5339
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.courierPrime(
                    fontSize: 11.5,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMicroKeyButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surface, // #FFF8F6
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: AppColors.onSurface,
              offset: Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.courierPrime(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // SECTION C: TODAY'S TASKS DOCKET (WITH BRASS PAPERCLIP & COMPLETED STAMP!)
  // ===========================================================================
  Widget _buildTodaysTasksDocket() {
    List<TaskItem> serviceTasks = const [];
    try {
      serviceTasks = widget.academicService.tasks;
    } catch (_) {}

    final now = DateTime.now();
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    final dateStamp = '${months[(now.month - 1).clamp(0, 11)]} ${now.day}';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow, // #FFF1EC
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: AppColors.onSurface, // #211A17
                offset: Offset(0, 5),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 6),
              // Docket Header & Date Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        "Today's Tasks",
                        style: AppTypography.literata(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer, // #F9EBE6
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          dateStamp,
                          style: AppTypography.courierPrime(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Render user's real tasks (BOTH active AND completed — never hiding completed!)
              if (serviceTasks.isNotEmpty)
                ...serviceTasks.map(
                  (task) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildTaskDocketCard(
                      title: task.title,
                      description: task.description.isNotEmpty
                          ? task.description
                          : 'Scheduled study sprint for ${task.courseCode}',
                      badge: '${task.courseCode} • ${task.priority.toUpperCase()}',
                      note: 'Estimated ${task.estimatedStudyMinutes}m focus',
                      isCompleted: task.isCompleted,
                      completedLabel: 'VERIFIED • COMPLETED',
                      onToggle: () =>
                          widget.academicService.toggleTaskComplete(task.id),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Faithful vector custom paint of the Reddit "Wow, such empty" Doge meme face
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: CustomPaint(
                            painter: _SuchEmptyDogePainter(
                              color: AppColors.onSurface.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Wow, such empty',
                          style: AppTypography.courierPrime(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurfaceVariant,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 4),

              // Stitched Dashed Button: PIN NEW DOCKET CARD
              GestureDetector(
                onTap: _showAddDocketDialog,
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: AppColors.outline,
                    borderRadius: 16,
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                      horizontal: 16,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // #FFF8F6
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.onSurface,
                          offset: Offset(0, 2),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      'PIN NEW DOCKET CARD',
                      style: AppTypography.courierPrime(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Secondary Button: ADD TASKS FOR THE NEXT DAYS
              GestureDetector(
                onTap: () => widget.onNavigateTab(1),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 11,
                    horizontal: 16,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer, // #F9EBE6
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.6),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.onSurface,
                        offset: Offset(0, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'ADD TASKS FOR THE NEXT DAYS',
                    style: AppTypography.courierPrime(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Brass Paperclip Graphic in Upper Left (`-top-2 left-8 w-5 h-9`)
        Positioned(
          top: -8,
          left: 32,
          child: IgnorePointer(
            child: Container(
              width: 20,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.secondaryFixedDim.withOpacity(0.92), // #FFB68C
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.onSecondaryFixedVariant, // #753400
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 10,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow, // #FFF1EC
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskDocketCard({
    required String title,
    required String description,
    required String badge,
    required String note,
    required bool isCompleted,
    required String completedLabel,
    required VoidCallback onToggle,
  }) {
    if (isCompleted) {
      // Completed Sprint Stamp Style (`code.txt` lines 337-363)
      return Opacity(
        opacity: 0.85,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0x99F9EBE6), // bg-surface-container/60
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: AppColors.onSurface,
                offset: Offset(0, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      badge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.courierPrime(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0x1A163C24), // bg-primary/10
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          completedLabel,
                          style: AppTypography.courierPrime(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Checked Rubber Stamp State
                  GestureDetector(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary, // #163C24
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.onPrimaryFixed, // #00210E
                            offset: Offset(0, 1),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.literata(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface.withOpacity(0.70),
                            decoration: TextDecoration.lineThrough,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTypography.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.onSurfaceVariant.withOpacity(0.70),
                            decoration: TextDecoration.lineThrough,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // Active Docket Card Style (`code.txt` lines 263-304)
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // #FFF8F6
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.onSurface, // #211A17
            offset: Offset(0, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Priority Tab Strip Pin
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed, // #C2EDCA
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.courierPrime(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: AppColors.onPrimaryFixedVariant, // #294E35
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.timelapse_rounded,
                size: 15,
                color: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Main Task Title & Tactile Check Stamp Box
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer, // #F9EBE6
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: AppColors.onSurface.withOpacity(0.18),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: AppColors.primary.withOpacity(0.28),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.literata(
                        fontSize: 17.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTypography.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pomodoro Pips and Sticky Margin Note
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withOpacity(0.75),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'SPRINTS: ● ● ○',
                  style: AppTypography.courierPrime(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_note_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          note,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.courierPrime(
                            fontSize: 11.5,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w400,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION D1: UPCOMING EVENTS CARD (`code.txt` lines 142-239)
  // ===========================================================================
  Widget _buildUpcomingEventsCard() {
    List<CalendarEvent> userEvents = const [];
    try {
      userEvents = widget.academicService.events;
    } catch (_) {}

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // #FFF8F6
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline.withOpacity(0.30)),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF2B2421),
            offset: Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Memo Pin Accent Header
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColors.outlineVariant.withOpacity(0.60),
                ),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.push_pin_rounded,
                  size: 18,
                  color: AppColors.secondary, // #994703
                ),
                const SizedBox(width: 6),
                Text(
                  'UPCOMING EVENTS',
                  style: AppTypography.courierPrime(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.9,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          if (userEvents.isNotEmpty)
            ...userEvents.take(3).map((ev) {
              const months = [
                'JAN',
                'FEB',
                'MAR',
                'APR',
                'MAY',
                'JUN',
                'JUL',
                'AUG',
                'SEP',
                'OCT',
                'NOV',
                'DEC',
              ];
              final m = months[(ev.dateTime.month - 1).clamp(0, 11)];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildEventRowItem(
                  month: m,
                  day: '${ev.dateTime.day}',
                  dateBg: AppColors.secondaryFixed,
                  dateFg: AppColors.onSecondaryFixedVariant,
                  dateShadow: AppColors.onSecondaryFixedVariant,
                  title: ev.title,
                  badgeText: ev.type.toUpperCase(),
                  badgeBg: AppColors.secondaryContainer.withOpacity(0.20),
                  badgeFg: AppColors.onSecondaryContainer,
                  timeLabel: (ev.courseCode != null && ev.courseCode!.isNotEmpty)
                      ? ev.courseCode!
                      : 'Scheduled Event',
                  locationLabel: (ev.notes != null && ev.notes!.isNotEmpty)
                      ? ev.notes!
                      : 'Academic Calendar',
                  accentTimeColor: AppColors.secondary,
                ),
              );
            })
          else ...[
            // Item 1: Midterm Exam (OCT 25)
            _buildEventRowItem(
              month: 'OCT',
              day: '25',
              dateBg: AppColors.secondaryFixed, // #FFDBC9
              dateFg: AppColors.onSecondaryFixedVariant, // #753400
              dateShadow: AppColors.onSecondaryFixedVariant,
              title: 'Computer Systems Architecture (CS 301)',
              badgeText: 'MIDTERM EXAM',
              badgeBg: AppColors.secondaryContainer.withOpacity(0.20),
              badgeFg: AppColors.onSecondaryContainer,
              timeLabel: 'Tomorrow • 09:30 AM (in 22h)',
              locationLabel: 'Hall C • Closed Book',
              accentTimeColor: AppColors.secondary,
            ),
            const SizedBox(height: 8),
            // Item 2: OS Lab Quiz (OCT 26)
            _buildEventRowItem(
              month: 'OCT',
              day: '26',
              dateBg: AppColors.primaryFixed, // #C2EDCA
              dateFg: AppColors.onPrimaryFixedVariant, // #294E35
              dateShadow: AppColors.onPrimaryFixedVariant,
              title: 'Operating Systems: Virtual Memory Quiz',
              badgeText: 'QUIZ • 15%',
              badgeBg: AppColors.primaryFixed.withOpacity(0.80),
              badgeFg: AppColors.primary,
              timeLabel: 'In 2 Days • 14:00 PM',
              locationLabel: 'Canvas Portal Submission',
              accentTimeColor: AppColors.primary,
            ),
            const SizedBox(height: 8),
            // Item 3: Algorithms Submission Milestone (OCT 27)
            _buildEventRowItem(
              month: 'OCT',
              day: '27',
              dateBg: AppColors.surfaceVariant, // #EDE0DB
              dateFg: AppColors.onSurfaceVariant,
              dateShadow: AppColors.onSurface,
              title: 'Algorithms Problem Set 5 Submission',
              badgeText: 'ASSIGNMENT',
              badgeBg: AppColors.surfaceVariant,
              badgeFg: AppColors.onSurfaceVariant,
              timeLabel: 'Friday • In 3 Days (23:59)',
              locationLabel: 'Canvas / GitHub Classroom',
              accentTimeColor: AppColors.onSurfaceVariant,
            ),
          ],

          const SizedBox(height: 10),
          // Bottom Ledger Footer Link (`Set An Event In Your Calendar`)
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => widget.onNavigateTab(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow, // #FFF1EC
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.outlineVariant.withOpacity(0.60),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.onSurface,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_month_rounded,
                      size: 16,
                      color: AppColors.secondaryContainer,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Set An Event In Your Calendar',
                      style: AppTypography.courierPrime(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRowItem({
    required String month,
    required String day,
    required Color dateBg,
    required Color dateFg,
    required Color dateShadow,
    required String title,
    required String badgeText,
    required Color badgeBg,
    required Color badgeFg,
    required String timeLabel,
    required String locationLabel,
    required Color accentTimeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow, // #FFF1EC
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withOpacity(0.50),
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.onSurface,
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 32x32 Date Badge
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: dateBg,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: dateShadow,
                  offset: const Offset(0, 1),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  month,
                  style: AppTypography.courierPrime(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w700,
                    color: dateFg,
                    height: 1.0,
                  ),
                ),
                Text(
                  day,
                  style: AppTypography.literata(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: dateFg,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Text(
                      title,
                      style: AppTypography.literata(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText,
                        style: AppTypography.courierPrime(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeFg,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 2,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      timeLabel,
                      style: AppTypography.courierPrime(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: accentTimeColor,
                      ),
                    ),
                    Text(
                      '• $locationLabel',
                      style: AppTypography.courierPrime(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _showAddDocketDialog,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.outlineVariant),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.onSurface,
                    offset: Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.bookmark_add_outlined,
                size: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// CUSTOM PAINTERS (`code.txt` Radial Dial SVG & Dashed Border)
// =============================================================================
class _AnalogRadialClockPainter extends CustomPainter {
  final double progress;

  const _AnalogRadialClockPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.shortestSide / 2) * (102.0 / 120.0);
    final tickRadius = (size.shortestSide / 2) * (92.0 / 120.0);

    // 1. Outer Track Ring (`stroke="#ede0db" stroke-width="8"`)
    final trackPaint = Paint()
      ..color = const Color(0xFFEDE0DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(center, outerRadius, trackPaint);

    // 2. Inner Dashed 12-Chapter Tick Ring (`stroke="#c1c8c0" stroke-dasharray="2 10" stroke-width="1.5"`)
    final tickPaint = Paint()
      ..color = const Color(0x99C1C8C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const totalTicks = 48;
    const sweepPerTick = (2 * math.pi) / totalTicks;
    for (int i = 0; i < totalTicks; i++) {
      final startAngle = i * sweepPerTick;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: tickRadius),
        startAngle,
        sweepPerTick * 0.22,
        false,
        tickPaint,
      );
    }

    // 3. Active Progress Arc (`stroke="#fc934f" stroke-linecap="round" stroke-width="9"`)
    final activePaint = Paint()
      ..color = const Color(0xFFFC934F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogRadialClockPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  const _DashedBorderPainter({
    required this.color,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(borderRadius),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      const dashWidth = 6.0;
      const dashSpace = 4.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) => false;
}

class _SuchEmptyDogePainter extends CustomPainter {
  final Color color;

  const _SuchEmptyDogePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Head outline with cute doge/cat ears
    final headPath = Path();
    // Start at top center between ears
    headPath.moveTo(w * 0.40, h * 0.22);
    // Left ear
    headPath.lineTo(w * 0.22, h * 0.08);
    headPath.lineTo(w * 0.16, h * 0.35);
    // Left cheek
    headPath.quadraticBezierTo(w * 0.08, h * 0.60, w * 0.25, h * 0.82);
    // Chin
    headPath.quadraticBezierTo(w * 0.50, h * 0.94, w * 0.75, h * 0.82);
    // Right cheek
    headPath.quadraticBezierTo(w * 0.92, h * 0.60, w * 0.84, h * 0.35);
    // Right ear
    headPath.lineTo(w * 0.78, h * 0.08);
    headPath.lineTo(w * 0.60, h * 0.22);
    headPath.close();

    canvas.drawPath(headPath, strokePaint);

    // Left eye (circle outline with dot)
    canvas.drawCircle(Offset(w * 0.34, h * 0.48), w * 0.07, strokePaint);
    canvas.drawCircle(Offset(w * 0.34, h * 0.48), w * 0.03, fillPaint);

    // Right eye (circle outline with dot)
    canvas.drawCircle(Offset(w * 0.66, h * 0.48), w * 0.07, strokePaint);
    canvas.drawCircle(Offset(w * 0.66, h * 0.48), w * 0.03, fillPaint);

    // Small nose
    final nosePath = Path();
    nosePath.moveTo(w * 0.46, h * 0.59);
    nosePath.lineTo(w * 0.54, h * 0.59);
    nosePath.lineTo(w * 0.50, h * 0.64);
    nosePath.close();
    canvas.drawPath(nosePath, fillPaint);

    // W-shaped doge snout smile
    final mouthPath = Path();
    mouthPath.moveTo(w * 0.38, h * 0.69);
    mouthPath.quadraticBezierTo(w * 0.44, h * 0.75, w * 0.50, h * 0.68);
    mouthPath.quadraticBezierTo(w * 0.56, h * 0.75, w * 0.62, h * 0.69);
    canvas.drawPath(mouthPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant _SuchEmptyDogePainter oldDelegate) =>
      oldDelegate.color != color;
}
