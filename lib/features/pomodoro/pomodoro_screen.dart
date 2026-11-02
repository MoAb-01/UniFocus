import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/pomodoro_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/celebration_dialog.dart';
import '../../core/widgets/pomodoro_timer_widget.dart';
import 'break_recommendation_dialog.dart';

class PomodoroScreen extends StatefulWidget {
  final PomodoroService pomodoroService;
  final AcademicService academicService;

  const PomodoroScreen({
    super.key,
    required this.pomodoroService,
    required this.academicService,
  });

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  int _extraSecondsOffset = 0;

  @override
  void initState() {
    super.initState();
    widget.pomodoroService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.pomodoroService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    setState(() {});

    // Check for celebration
    if (widget.pomodoroService.hasPendingCelebration) {
      widget.pomodoroService.clearCelebration();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        CelebrationDialog.show(
          context: context,
          title: 'SESSION CONCLUDED',
          message: 'Cadence maintained. Great focus work today.',
          earnedXp: 50,
          streakDays: widget.academicService.profile.studyStreakDays,
          extraSubtitle: 'Sprint recorded to your desk ledger.',
        );
      });
    }

    // Check for pending break recommendation
    final rec = widget.pomodoroService.pendingBreakRecommendation;
    if (rec != null) {
      widget.pomodoroService.clearBreakRecommendation();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => BreakRecommendationDialog(
            recommendation: rec,
            onDismiss: () {},
          ),
        );
      });
    }
  }

  void _selectTimerMode(int workMins, int breakMins) {
    setState(() => _extraSecondsOffset = 0);
    widget.pomodoroService.setDurations(workMinutes: workMins, breakMinutes: breakMins);
  }

  void _toggleTimer() {
    if (widget.pomodoroService.isRunning) {
      widget.pomodoroService.pause();
    } else {
      widget.pomodoroService.startOrResume();
    }
  }

  void _addFiveMinutes() {
    setState(() => _extraSecondsOffset += 300);
  }

  void _completeOrSkipSprint() {
    setState(() => _extraSecondsOffset = 0);
    widget.pomodoroService.skipToNextPhase();
  }

  void _resetTimer() {
    setState(() => _extraSecondsOffset = 0);
    widget.pomodoroService.reset();
  }

  @override
  Widget build(BuildContext context) {
    final ps = widget.pomodoroService;
    final courses = widget.academicService.activeCourses;
    final pendingTasks = widget.academicService.tasks.where((t) => !t.isCompleted).toList();

    final isRunning = ps.isRunning;
    final isBreak = ps.isBreak;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          'TIMER',
          style: AppTypography.literata(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
        ),
        centerTitle: false,
        backgroundColor: AppColors.surface,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 116),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Mode selectors: 50m Focus / 10m Break vs 25m Focus / 5m Break
              if (!isRunning) ...[
                Row(
                  children: [
                    Expanded(
                      child: _buildDurationOption(
                        label: '50m Focus / 10m Break',
                        isSelected: !isBreak && ps.workMinutes == 50,
                        onTap: () => _selectTimerMode(50, 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildDurationOption(
                        label: '25m Focus / 5m Break',
                        isSelected: !isBreak && ps.workMinutes == 25,
                        onTap: () => _selectTimerMode(25, 5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Course & Task Selector
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
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
                    children: [
                      DropdownButtonFormField<Course?>(
                        value: ps.selectedCourse,
                        decoration: const InputDecoration(
                          hintText: 'Select Course',
                          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: [
                          DropdownMenuItem<Course?>(
                            value: null,
                            child: Text(
                              'General Focus',
                              style: AppTypography.courierPrime(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                          ),
                          ...courses.map((c) => DropdownMenuItem(
                                value: c,
                                child: Text(
                                  '${c.code} - ${c.name}',
                                  style: AppTypography.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )),
                        ],
                        onChanged: (val) => ps.selectCourse(val),
                      ),
                      if (pendingTasks.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<TaskItem?>(
                          value: ps.selectedTask,
                          decoration: const InputDecoration(
                            hintText: 'Attach Docket Task (Optional)',
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                          items: [
                            DropdownMenuItem<TaskItem?>(
                              value: null,
                              child: Text(
                                'No specific task',
                                style: AppTypography.courierPrime(fontSize: 12, fontWeight: FontWeight.w400),
                              ),
                            ),
                            ...pendingTasks.map((t) => DropdownMenuItem(
                                  value: t,
                                  child: Text(
                                    '${t.courseCode}: ${t.title}',
                                    style: AppTypography.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                          ],
                          onChanged: (val) => ps.selectTask(val),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Central Mechanical Radial Pomodoro Widget (with +5 Mins, Reset, Done)
              PomodoroTimerWidget(
                remainingSeconds: ps.remainingSeconds + _extraSecondsOffset,
                totalSeconds: ps.totalSeconds + _extraSecondsOffset,
                isRunning: ps.isRunning,
                isBreak: ps.isBreak,
                courseCode: ps.selectedCourse?.code ?? ps.selectedTask?.courseCode ?? '',
                taskTitle: ps.selectedTask?.title ?? ps.selectedCourse?.name ?? 'Deep Focus Session',
                onToggleStartPause: _toggleTimer,
                onReset: _resetTimer,
                onSkip: _completeOrSkipSprint,
                onAddFiveMinutes: _addFiveMinutes,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.onPrimaryFixed,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : const [
                  BoxShadow(
                    color: AppColors.onSurface,
                    offset: Offset(0, 1),
                    blurRadius: 0,
                  ),
                ],
        ),
        child: Text(
          label,
          style: AppTypography.courierPrime(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.onSurface,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
