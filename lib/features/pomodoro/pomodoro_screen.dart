import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/pomodoro_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/pomodoro_timer_widget.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/celebration_dialog.dart';
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
          title: 'Nice work!',
          message: 'Focus session completed! Great study momentum.',
          earnedXp: 50,
          streakDays: widget.academicService.profile.studyStreakDays,
          extraSubtitle: 'Streak maintained & focus recorded!',
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

  @override
  Widget build(BuildContext context) {
    final ps = widget.pomodoroService;
    final courses = widget.academicService.activeCourses;
    final pendingTasks = widget.academicService.tasks.where((t) => !t.isCompleted).toList();

    final focusToday = widget.academicService.focusMinutesToday;
    final focusWeek = widget.academicService.focusMinutesThisWeek;
    final focusByCourse = widget.academicService.focusMinutesByCourse;

    final isRunning = ps.isRunning;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Focus & Pomodoro'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            children: [
              // Duration Mode Toggle (50/10 vs 25/5)
              if (!isRunning)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: const Text('50m Focus / 10m Break'),
                      selected: ps.workMinutes == 50,
                      onSelected: (_) => ps.setDurations(workMinutes: 50, breakMinutes: 10),
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(
                        color: ps.workMinutes == 50 ? Colors.white : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('25m Focus / 5m Break'),
                      selected: ps.workMinutes == 25,
                      onSelected: (_) => ps.setDurations(workMinutes: 25, breakMinutes: 5),
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(
                        color: ps.workMinutes == 25 ? Colors.white : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // Course & Task Selectors (if not actively running)
              if (!isRunning) ...[
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<Course?>(
                        value: ps.selectedCourse,
                        decoration: const InputDecoration(
                          hintText: 'Select Course',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        items: [
                          const DropdownMenuItem<Course?>(
                            value: null,
                            child: Text('General Focus', style: TextStyle(fontSize: 13)),
                          ),
                          ...courses.map((c) => DropdownMenuItem(
                                value: c,
                                child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                              )),
                        ],
                        onChanged: (val) => ps.selectCourse(val),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (pendingTasks.isNotEmpty)
                  DropdownButtonFormField<TaskItem?>(
                    value: ps.selectedTask,
                    decoration: const InputDecoration(
                      hintText: 'Select Goal / Task (Optional)',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: [
                      const DropdownMenuItem<TaskItem?>(
                        value: null,
                        child: Text('No specific task', style: TextStyle(fontSize: 13)),
                      ),
                      ...pendingTasks.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text('${t.courseCode}: ${t.title}', style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                          )),
                    ],
                    onChanged: (val) => ps.selectTask(val),
                  ),
                const SizedBox(height: 24),
              ],

              // Central Pomodoro Timer Widget
              PomodoroTimerWidget(
                remainingSeconds: ps.remainingSeconds,
                totalSeconds: ps.totalSeconds,
                isRunning: ps.isRunning,
                isBreak: ps.isBreak,
                courseCode: ps.selectedCourse?.code ?? ps.selectedTask?.courseCode ?? '',
                taskTitle: ps.selectedTask?.title ?? ps.selectedCourse?.name ?? 'General Focus Session',
                onToggleStartPause: () {
                  if (ps.isRunning) {
                    ps.pause();
                  } else {
                    ps.startOrResume();
                  }
                },
                onReset: ps.reset,
                onSkip: ps.skipToNextPhase,
              ),

              const SizedBox(height: 36),

              // Productivity Statistics
              const SectionHeader(
                title: 'Productivity Statistics',
                subtitle: 'Track your weekly focus consistency',
              ),

              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      title: 'Focus Today',
                      value: DateFormatters.formatDurationMinutes(focusToday),
                      subtitle: '${ps.completedSessionsToday} sessions completed',
                      icon: Icons.today_outlined,
                      valueColor: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatCard(
                      title: 'Focus This Week',
                      value: DateFormatters.formatDurationMinutes(focusWeek),
                      subtitle: 'Active study week',
                      icon: Icons.date_range_outlined,
                      valueColor: AppColors.accentIndigo,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Focus Time By Course breakdown
              if (focusByCourse.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FOCUS TIME BY COURSE',
                        style: AppTypography.labelUppercase,
                      ),
                      const SizedBox(height: 12),
                      ...focusByCourse.entries.map((entry) {
                        final percentage = focusWeek > 0 ? (entry.value / focusWeek) : 0.0;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    entry.key,
                                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    DateFormatters.formatDurationMinutes(entry.value),
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percentage.clamp(0.0, 1.0),
                                  backgroundColor: AppColors.surfaceSubtle,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
                                  minHeight: 5,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
