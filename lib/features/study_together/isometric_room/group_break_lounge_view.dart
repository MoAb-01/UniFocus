import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/services/study_together_service.dart';
import '../../../core/services/academic_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import 'participant_voice_panel.dart';
import '../mini_games/synchronized_mini_games_view.dart';

/// Flagship Multiplayer Group Break & Lounge View:
/// When a room-wide break is approved by vote, all students transition together
/// into this shared lounge environment featuring:
/// - Synchronized countdown break clock
/// - Shared temporary voice lounge
/// - 4-7-8 Mindful breathing guide
/// - Quick focus trivia & wellness recharge checklist (+XP reward)
/// - Synchronized return to study hall when timer completes
/// Zero Unicode emojis.
class GroupBreakLoungeView extends StatefulWidget {
  final StudyRoom room;
  final StudyTogetherService studyService;
  final AcademicService academicService;
  final String currentUserId;
  final bool isHost;

  const GroupBreakLoungeView({
    super.key,
    required this.room,
    required this.studyService,
    required this.academicService,
    required this.currentUserId,
    required this.isHost,
  });

  @override
  State<GroupBreakLoungeView> createState() => _GroupBreakLoungeViewState();
}

class _GroupBreakLoungeViewState extends State<GroupBreakLoungeView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _completedWellnessTasks = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void didUpdateWidget(covariant GroupBreakLoungeView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a mini-game starts in the room, bring this participant into the Mini Games tab automatically
    if (widget.room.activeMiniGame != null &&
        oldWidget.room.activeMiniGame == null &&
        _tabController.index != 1) {
      _tabController.index = 1;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Duration _getRemainingBreakDuration() {
    final endsAt = widget.room.breakEndsAt;
    if (endsAt == null) return Duration.zero;
    final diff = endsAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  double _getBreakProgress() {
    final start = widget.room.breakStartedAt;
    final end = widget.room.breakEndsAt;
    if (start == null || end == null) return 0.0;
    final total = end.difference(start).inSeconds;
    if (total <= 0) return 1.0;
    final elapsed = DateTime.now().difference(start).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }

  String _buildReadyStatusText() {
    final readyUserIds = widget.room.readyToResumeUserIds;
    final readyCount = readyUserIds.length;
    final totalCount = widget.room.participants.length;

    final names = widget.room.participants
        .where((p) => readyUserIds.contains(p.userId))
        .map((p) => p.userId == widget.currentUserId ? 'You' : p.displayName)
        .toList();

    final namesText = names.isNotEmpty ? ' (${names.join(", ")})' : '';
    return '$readyCount of $totalCount students ready to resume$namesText';
  }

  String _buildButtonLabel(bool isReady, int readyCount, int totalCount) {
    if (isReady) {
      if (totalCount <= 1) return 'RESUME STUDY HALL';
      return 'READY TO RESUME ($readyCount/$totalCount READY)';
    } else {
      if (readyCount > 0) {
        return 'READY TO RESUME ($readyCount/$totalCount READY)';
      }
      return 'READY TO RESUME STUDY';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final remaining = _getRemainingBreakDuration();
    final remMins = remaining.inMinutes;
    final remSecs = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    final progress = _getBreakProgress();
    final isReady = widget.room.readyToResumeUserIds.contains(widget.currentUserId);
    final readyCount = widget.room.readyToResumeUserIds.length;
    final totalCount = widget.room.participants.length;

    return Container(
      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFFFFBEB),
      child: SafeArea(
        child: Column(
          children: [
            // 1. Top Synchronized Break Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange.withValues(alpha: 0.15),
                          borderRadius: AppRadii.roundedPill,
                          border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.free_breakfast_rounded, size: 14, color: AppColors.brandOrange),
                            const SizedBox(width: 6),
                            Text(
                              'GROUP BREAK IN PROGRESS',
                              style: AppTypography.label.copyWith(
                                color: AppColors.brandOrange,
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (widget.isHost)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.streakOrangeDark,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: const Icon(Icons.keyboard_return_rounded, size: 14),
                          label: const Text('End Break', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          onPressed: () {
                            widget.studyService.endGroupBreak();
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Large Synchronized Countdown
                  Text(
                    '$remMins:$remSecs',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace',
                      letterSpacing: -1.5,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'All ${widget.room.participants.length} students will return to study desks together',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Synchronized Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandOrange),
                    ),
                  ),
                ],
              ),
            ),

            // 2. Shared Participant Voice Panel
            ParticipantVoicePanel(
              room: widget.room,
              studyService: widget.studyService,
              currentUserId: widget.currentUserId,
            ),

            const SizedBox(height: 8),

            // 3. Activity Tabs (Breathing, Mini Games, Recharge)
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.brandOrange,
              labelColor: AppColors.brandOrange,
              labelPadding: const EdgeInsets.symmetric(horizontal: 2),
              unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 10),
              tabs: const [
                Tab(icon: Icon(Icons.air_rounded, size: 17), text: 'Breathing'),
                Tab(icon: Icon(Icons.sports_esports_rounded, size: 17), text: 'Mini Games'),
                Tab(icon: Icon(Icons.spa_rounded, size: 17), text: 'Recharge (+XP)'),
              ],
            ),

            // 4. Activity Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildBreathingView(isDark),
                  SynchronizedMiniGamesView(
                    room: widget.room,
                    studyService: widget.studyService,
                    academicService: widget.academicService,
                    currentUserId: widget.currentUserId,
                    isHost: widget.isHost,
                  ),
                  _buildRechargeView(isDark),
                ],
              ),
            ),

            // 5. Bottom Return Status Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.room.readyToResumeUserIds.isNotEmpty) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gamifyEmerald.withValues(alpha: 0.12),
                        borderRadius: AppRadii.roundedMd,
                        border: Border.all(
                          color: AppColors.gamifyEmerald.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              size: 16, color: AppColors.gamifyEmerald),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _buildReadyStatusText(),
                              style: const TextStyle(
                                color: AppColors.gamifyEmerald,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isReady
                          ? AppColors.gamifyEmerald
                          : AppColors.brandOrange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                    ),
                    icon: Icon(isReady
                        ? Icons.check_circle_rounded
                        : Icons.chair_alt_rounded),
                    label: Text(
                      _buildButtonLabel(isReady, readyCount, totalCount),
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
                    ),
                    onPressed: () {
                      widget.studyService.toggleReadyToResume();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 4-7-8 Mindful Breathing Subview ---
  Widget _buildBreathingView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandOrange.withValues(alpha: 0.12),
                border: Border.all(color: AppColors.brandOrange, width: 3),
              ),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.spa_rounded, color: AppColors.brandOrange, size: 28),
                    SizedBox(height: 4),
                    Text('4-7-8', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.brandOrange)),
                    Text('Breathe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Calm your mind before the next sprint',
              style: AppTypography.title.copyWith(fontSize: 13, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'Inhale 4s · Hold 7s · Exhale 8s',
              style: AppTypography.caption.copyWith(color: AppColors.streakOrangeDark, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }



  // --- Physical Recharge Checklist ---
  Widget _buildRechargeView(bool isDark) {
    final tasks = [
      {'id': 'water', 'title': 'Drink a glass of water', 'desc': 'Rehydrate cognitive function'},
      {'id': 'eyes', 'title': '20-20-20 Eye Rest', 'desc': 'Look at an object 20ft away for 20s'},
      {'id': 'stretch', 'title': 'Shoulder & Neck Stretch', 'desc': 'Release posture strain from studying'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('RECHARGE CHECKLIST', style: AppTypography.label.copyWith(color: AppColors.brandOrange, fontSize: 11)),
              Text(
                '${_completedWellnessTasks.length} / ${tasks.length} Completed',
                style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((task) {
            final taskId = task['id']!;
            final isDone = _completedWellnessTasks.contains(taskId);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
              child: ListTile(
                leading: Icon(
                  isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                  color: isDone ? AppColors.gamifyEmerald : AppColors.brandOrange,
                ),
                title: Text(task['title']!, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, decoration: isDone ? TextDecoration.lineThrough : null)),
                subtitle: Text(task['desc']!, style: const TextStyle(fontSize: 11)),
                onTap: () {
                  setState(() {
                    if (isDone) {
                      _completedWellnessTasks.remove(taskId);
                    } else {
                      _completedWellnessTasks.add(taskId);
                      widget.academicService.addXp(5, reason: 'Break Wellness Recharge');
                    }
                  });
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
