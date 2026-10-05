import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/study_room.dart';
import '../../core/services/study_together_service.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/break_request_banner.dart';
import '../../core/widgets/room_music_dock.dart';
import '../../core/widgets/session_control_dock.dart';
import '../../core/widgets/session_goal_widget.dart';
import '../../core/widgets/session_timer.dart';
import '../../core/widgets/study_arena.dart';
import 'session_summary_dialog.dart';
import 'study_room_lobby_screen.dart';

/// Flagship Multiplayer Study Arena: The Signature Feature of UniFocus.
/// A shared digital study space, NOT a generic dashboard of cards.
/// Zero Unicode emojis.
class ActiveStudySessionScreen extends StatefulWidget {
  final StudyTogetherService studyService;
  final AcademicService academicService;

  const ActiveStudySessionScreen({
    super.key,
    required this.studyService,
    required this.academicService,
  });

  @override
  State<ActiveStudySessionScreen> createState() => _ActiveStudySessionScreenState();
}

class _ActiveStudySessionScreenState extends State<ActiveStudySessionScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  bool _showMusicDock = false;

  @override
  void initState() {
    super.initState();
    widget.studyService.addListener(_onServiceUpdate);

    final myId = widget.academicService.profile.id;
    final me = widget.studyService.activeRoom?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => widget.studyService.activeRoom!.participants.first,
    );
    if (me != null) {
      _subjectController.text = me.currentSubject;
      _goalController.text = me.personalGoal ?? '';
    }
  }

  @override
  void dispose() {
    widget.studyService.removeListener(_onServiceUpdate);
    _subjectController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _showSubjectDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'What are you studying?',
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: TextField(
          controller: _subjectController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'e.g. Writing CENG401 proposal',
            border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
            ),
            onPressed: () {
              final newSubject = _subjectController.text.trim();
              if (newSubject.isNotEmpty) {
                widget.studyService.updateSubject(newSubject);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save Subject', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showGoalDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'Set Today\'s Session Goal',
          style: AppTypography.title.copyWith(
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complete your goal during this session to earn +25 XP.',
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'e.g. Complete introduction & system architecture',
                border: OutlineInputBorder(borderRadius: AppRadii.roundedMd),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gamifyPurple,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
            ),
            onPressed: () {
              final newGoal = _goalController.text.trim();
              if (newGoal.isNotEmpty) {
                widget.studyService.setPersonalGoal(newGoal);
              }
              Navigator.pop(ctx);
            },
            child: const Text('Set Goal (+25 XP)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showBreakRequestSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.streakOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.free_breakfast_rounded, color: AppColors.streakOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Request a Study Break',
                      style: AppTypography.headline.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'Submit break duration to the room host',
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [5, 10, 15].map((mins) {
                return OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                    side: const BorderSide(color: AppColors.streakOrange, width: 1.5),
                  ),
                  onPressed: () {
                    widget.studyService.requestBreak(mins);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Break request for $mins minutes submitted to host.'),
                        backgroundColor: AppColors.streakOrange,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    '$mins MIN',
                    style: AppTypography.button.copyWith(
                      color: AppColors.streakOrangeDark,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  void _showMoreActionsSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final room = widget.studyService.activeRoom;
    final myId = widget.academicService.profile.id;
    final isHost = room != null && room.hostId == myId;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Arena Options & Controls',
              style: AppTypography.headline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),

            // Live Status Selector
            ListTile(
              leading: const Icon(Icons.palette_rounded, color: AppColors.brandBlue),
              title: const Text('Change Live Status', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Studying, On Break, Need Help, Leaving Soon', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.pop(ctx);
                _showStatusPicker();
              },
            ),

            // Voice Break Room Status (Architected for future WebRTC)
            ListTile(
              leading: const Icon(Icons.mic_none_rounded, color: AppColors.gamifyPurple),
              title: const Text('Voice Break Room', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Standby during focus · Activates on group break', style: TextStyle(fontSize: 12)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gamifyPurple.withValues(alpha: 0.15),
                  borderRadius: AppRadii.roundedXs,
                ),
                child: Text(
                  'STANDBY',
                  style: AppTypography.label.copyWith(fontSize: 9, color: AppColors.gamifyPurple),
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice Break Room is architected and will engage when a room-wide break is agreed upon.'),
                    backgroundColor: AppColors.gamifyPurple,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            const Divider(),

            // End / Leave Session
            ListTile(
              leading: Icon(
                isHost ? Icons.stop_circle_rounded : Icons.logout_rounded,
                color: AppColors.dangerRed,
              ),
              title: Text(
                isHost ? 'End Study Arena' : 'Leave Arena',
                style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.dangerRed),
              ),
              subtitle: Text(
                isHost
                    ? 'Concludes session for all students and saves productivity stats'
                    : 'Exit back to dashboard',
                style: const TextStyle(fontSize: 12),
              ),
              onTap: () {
                Navigator.pop(ctx);
                if (isHost) {
                  _handleEndSession();
                } else {
                  widget.studyService.leaveRoom();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set Your Live Status',
              style: AppTypography.headline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 16),
            ...ParticipantStatus.values.map((status) {
              return ListTile(
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: status.color,
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  status.label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
                trailing: Icon(status.icon, size: 20, color: status.color),
                onTap: () {
                  widget.studyService.updateStatus(status);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showParticipantDetailSheet(RoomParticipant p) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: p.status.color,
                  child: Text(
                    p.displayName.isNotEmpty ? p.displayName[0] : 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.displayName,
                        style: AppTypography.title.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        '${p.major} · Level ${p.level}',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: p.status.color.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedPill,
                  ),
                  child: Text(
                    p.status.label.toUpperCase(),
                    style: AppTypography.label.copyWith(
                      color: p.status.color,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'CURRENT SUBJECT',
              style: AppTypography.label.copyWith(
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              p.currentSubject,
              style: AppTypography.body.copyWith(
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            if (p.personalGoal != null && p.personalGoal!.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'SESSION GOAL',
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                p.personalGoal!,
                style: AppTypography.bodySmall.copyWith(
                  color: p.isGoalCompleted ? AppColors.gamifyEmerald : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                  decoration: p.isGoalCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEndSession() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          'End Study Arena Session?',
          style: AppTypography.title.copyWith(fontWeight: FontWeight.w900),
        ),
        content: const Text('This will complete the study session for all students and reward focus XP.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dangerRed,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Session', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final summary = await widget.studyService.endSession();
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SessionSummaryDialog(
        summary: summary,
        onDone: () {
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
        onStudyAgain: () {
          Navigator.pop(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => StudyRoomLobbyScreen(
                studyService: widget.studyService,
                academicService: widget.academicService,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.studyService.activeRoom;
    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Arena')),
        body: const Center(child: Text('Session ended.')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final elapsed = widget.studyService.getElapsedDuration();
    final myId = widget.academicService.profile.id;
    final isHost = room.hostId == myId;
    final me = room.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => room.participants.first,
    );

    final isRoomOnBreak = room.isAnyOnBreak;
    final pendingBreaks = room.breakRequests.where((b) => b.isApproved == null).toList();
    final music = room.musicState;
    final musicPosSec = widget.studyService.getMusicPositionSeconds();

    return Scaffold(
      backgroundColor: isDark
          ? (isRoomOnBreak ? const Color(0xFF14100D) : AppColors.backgroundDark)
          : (isRoomOnBreak ? const Color(0xFFFFFBEB) : AppColors.backgroundLight),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (isHost) {
              _handleEndSession();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              room.title,
              style: AppTypography.title.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'ARENA ${room.id} · ${room.participants.length} STUDYING',
              style: AppTypography.caption.copyWith(
                fontSize: 10,
                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          // Course Tag
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandBlueLight,
              borderRadius: AppRadii.roundedXs,
              border: Border.all(color: AppColors.brandBlue.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                room.courseCode,
                style: AppTypography.label.copyWith(
                  color: AppColors.brandBlue,
                  fontSize: 11,
                ),
              ),
            ),
          ),
          // Local Audio Quick Mute Toggle
          IconButton(
            icon: Icon(
              widget.studyService.isLocalMuted
                  ? Icons.volume_off_rounded
                  : Icons.volume_up_rounded,
              color: widget.studyService.isLocalMuted
                  ? AppColors.dangerRed
                  : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            onPressed: widget.studyService.toggleLocalMute,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Host Pending Break Request Banner (floating notification)
            if (isHost && pendingBreaks.isNotEmpty)
              BreakRequestBanner(
                request: pendingBreaks.first,
                onAccept: () => widget.studyService.respondToBreakRequest(pendingBreaks.first.id, true),
                onDecline: () => widget.studyService.respondToBreakRequest(pendingBreaks.first.id, false),
              ),

            const SizedBox(height: 6),

            // Hero Timer: The heartbeat of the room
            SessionTimer(
              elapsed: elapsed,
              isBreakMode: isRoomOnBreak,
              breakRemaining: isRoomOnBreak ? const Duration(minutes: 9, seconds: 42) : null,
              courseCode: room.courseCode,
            ),

            // Central Study Arena: The Multiplayer Place
            Expanded(
              child: Center(
                child: StudyArena(
                  participants: room.participants,
                  currentUserId: myId,
                  isBreakMode: isRoomOnBreak,
                  onParticipantTap: _showParticipantDetailSheet,
                ),
              ),
            ),

            // Integrated Session Goal Chip
            SessionGoalWidget(
              goal: me.personalGoal,
              isCompleted: me.isGoalCompleted,
              onToggleCompleted: widget.studyService.toggleGoalCompleted,
              onEditGoal: _showGoalDialog,
            ),

            const SizedBox(height: 6),

            // Compact Integrated Room Music Dock (if enabled or playing)
            if (_showMusicDock || music.isPlaying)
              RoomMusicDock(
                musicState: music,
                positionSeconds: musicPosSec,
                isHost: isHost,
                isLocalMuted: widget.studyService.isLocalMuted,
                onTogglePlay: widget.studyService.toggleMusicPlay,
                onNextTrack: widget.studyService.nextTrack,
                onToggleMute: widget.studyService.toggleLocalMute,
              ),

            // Floating Game-Style Control Dock
            SessionControlDock(
              isBreakActive: isRoomOnBreak,
              isMusicPlaying: music.isPlaying,
              onBreakPressed: _showBreakRequestSheet,
              onSubjectPressed: _showSubjectDialog,
              onGoalPressed: _showGoalDialog,
              onMusicPressed: () {
                setState(() => _showMusicDock = !_showMusicDock);
              },
              onMorePressed: _showMoreActionsSheet,
            ),
          ],
        ),
      ),
    );
  }
}
