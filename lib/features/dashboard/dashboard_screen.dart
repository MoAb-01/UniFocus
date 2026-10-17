import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/models/program.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/study_together_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatters.dart';
import '../../core/widgets/game_button.dart';
import '../../core/widgets/streak_badge.dart';
import '../../core/widgets/xp_bar.dart';
import '../courses/courses_screen.dart';
import '../courses/course_detail_screen.dart';
import '../documents/documents_screen.dart';
import '../gpa/gpa_dashboard_screen.dart';
import '../study_places/study_places_screen.dart';
import '../tasks/add_edit_task_screen.dart';
import '../tasks/tasks_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AcademicService academicService;
  final StorageService storage;
  final void Function(int tabIndex)? onNavigateTab;
  final void Function(TaskItem task)? onStartTaskFocus;
  final StudyTogetherService? studyTogetherService;

  const DashboardScreen({
    super.key,
    required this.academicService,
    required this.storage,
    this.onNavigateTab,
    this.onStartTaskFocus,
    this.studyTogetherService,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.academicService.profile;
    final currentSem = widget.academicService.currentSemester;
    final currentCourses = widget.academicService.currentSemesterCourses;
    final pendingTasks = widget.academicService.tasks.where((t) => !t.isCompleted).take(3).toList();
    final programs = widget.academicService.programs;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            widget.academicService.loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: HELLO, MOHAMED + Streak Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'HELLO, ${profile.name.split(' ').first.toUpperCase()}',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryLight,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${profile.university} • ${profile.academicYearEnum.displayName}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    StreakBadge(streakDays: profile.studyStreakDays, isLarge: false),
                  ],
                ),
                const SizedBox(height: 16),

                // Gamification XP & Level Bar
                XpBar(
                  level: profile.level,
                  currentXp: profile.xp,
                  maxXp: profile.maxXp,
                ),
                const SizedBox(height: 16),

                // Program Selector Chips (Main vs ÇAP)
                if (programs.length > 1) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('All Programs'),
                          selected: widget.academicService.selectedProgramId == null,
                          onSelected: (_) => widget.academicService.selectProgram(null),
                          selectedColor: AppColors.brandBlue,
                          labelStyle: TextStyle(
                            color: widget.academicService.selectedProgramId == null
                                ? Colors.white
                                : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...programs.map((p) {
                          final isSelected = widget.academicService.selectedProgramId == p.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(p.type == ProgramType.cap ? 'ÇAP: ${p.name}' : p.name),
                              selected: isSelected,
                              onSelected: (_) => widget.academicService.selectProgram(p.id),
                              selectedColor: p.type == ProgramType.cap
                                  ? AppColors.gamifyPurple
                                  : AppColors.brandBlue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Academic Metric Pill Card (GANO & AKTS)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GpaDashboardScreen(academicService: widget.academicService),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x262563EB),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CURRENT GANO',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  profile.displayGpa,
                                  style: TextStyle(
                                    fontSize: profile.displayGpa == 'GPA NOT SET' ? 22 : 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                if (profile.previousGpa != null &&
                                    profile.currentGano > 0 &&
                                    (profile.currentGano - profile.previousGpa!).abs() >= 0.01) ...[
                                  const SizedBox(width: 8),
                                  Builder(
                                    builder: (_) {
                                      final diff = profile.currentGano - profile.previousGpa!;
                                      final isUp = diff > 0;
                                      return Text(
                                        '${isUp ? '↑ +' : '↓ '}${diff.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isUp ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${profile.completedAkts} Completed AKTS • ${profile.currentSemester ?? 'Academic Year'}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TODAY'S FOCUS SECTION
                const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final pendingTasks = widget.academicService.tasks.where((t) => !t.isCompleted).toList();
                    final priorityTask = pendingTasks.isNotEmpty ? pendingTasks.first : null;

                    if (priorityTask == null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.check_circle_outline_rounded, color: Color(0xFF64748B), size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'No Focus Tasks Pending',
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Add an academic task to schedule focused study sprints.',
                                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => widget.onNavigateTab?.call(1),
                              child: const Text('ADD TASK', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: AppColors.brandBlue, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  priorityTask.courseCode.isNotEmpty ? priorityTask.courseCode : 'Academic Goal',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.brandBlue),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  priorityTask.title,
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${priorityTask.estimatedMinutes > 0 ? priorityTask.estimatedMinutes : 25} min recommended focus',
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.brandBlue,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: () => widget.onNavigateTab?.call(2), // Focus tab
                            child: const Text('FOCUS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // UPCOMING DEADLINE
                const Text(
                  'UPCOMING',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (context) {
                    final upcomingTasks = widget.academicService.tasks.where((t) => !t.isCompleted).toList();
                    final upcoming = upcomingTasks.length > 1 ? upcomingTasks[1] : (upcomingTasks.isNotEmpty ? upcomingTasks.first : null);

                    if (upcoming == null) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.event_available_rounded, color: AppColors.brandBlue, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No upcoming deadlines. Your academic schedule is clear!',
                                style: TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.local_fire_department_rounded, color: AppColors.streakOrange, size: 26),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  upcoming.title,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  upcoming.priority.toLowerCase() == 'high' ? 'High Priority • Academic Deadline' : 'Scheduled Academic Task',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: upcoming.priority.toLowerCase() == 'high' ? AppColors.dangerRed : const Color(0xFF64748B),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (upcoming.priority.toLowerCase() == 'high')
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'URGENT',
                                style: TextStyle(color: AppColors.dangerRed, fontWeight: FontWeight.w900, fontSize: 11),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // TODAY'S GOAL PROGRESS
                const Text(
                  'TODAY\'S GOAL',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Builder(
                    builder: (context) {
                      final today = DateTime.now();
                      final todaySessions = widget.academicService.sessions.where((s) =>
                          s.timestamp.year == today.year &&
                          s.timestamp.month == today.month &&
                          s.timestamp.day == today.day).length;
                      const targetSessions = 4;
                      final progressRatio = (todaySessions / targetSessions).clamp(0.0, 1.0);
                      final percent = (progressRatio * 100).toInt();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$todaySessions / $targetSessions Focus Sessions',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimaryLight),
                              ),
                              Text(
                                '$percent%',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.gamifyEmeraldDark),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progressRatio,
                              minHeight: 10,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: const AlwaysStoppedAnimation(AppColors.gamifyEmerald),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            todaySessions >= targetSessions
                                ? 'Daily goal reached! Great academic consistency.'
                                : (todaySessions == 0
                                    ? 'Start your first 25-minute study sprint today to build your streak!'
                                    : 'Keep it going! ${targetSessions - todaySessions} more sessions to reach your daily goal.'),
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // QUICK ACTIONS GRID
                const Text(
                  'QUICK ACTIONS',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.add_task_rounded,
                        label: 'Add Task',
                        color: AppColors.brandBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddEditTaskScreen(
                                academicService: widget.academicService,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.timer_rounded,
                        label: 'Start Focus',
                        color: AppColors.streakOrange,
                        onTap: () => widget.onNavigateTab?.call(2), // Focus
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.groups_rounded,
                        label: 'Study Together',
                        color: AppColors.gamifyPurple,
                        onTap: () => widget.onNavigateTab?.call(3), // Together
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildActionTile(
                        icon: Icons.menu_book_rounded,
                        label: 'Courses',
                        color: AppColors.gamifyEmerald,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CoursesScreen(
                                academicService: widget.academicService,
                                onStartFocus: (c) {
                                  Navigator.pop(context);
                                  widget.onNavigateTab?.call(2);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ACTIVE COURSES PREVIEW
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COURSES (${currentCourses.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CoursesScreen(
                              academicService: widget.academicService,
                            ),
                          ),
                        );
                      },
                      child: const Text('View All', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...currentCourses.take(3).map((course) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(course.colorValue),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            course.code,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                course.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${course.akts} AKTS • Letter: ${course.letterGrade ?? 'In Progress'}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CourseDetailScreen(
                                  course: course,
                                  academicService: widget.academicService,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: const [
            BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
