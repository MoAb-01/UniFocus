import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/models/study_room.dart';
import '../../core/services/session_notification_service.dart';
import '../../core/services/study_together_service.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/break_request_banner.dart';
import '../../core/widgets/study_arena.dart';
import 'isometric_room/study_room_hud.dart';
import 'isometric_room/group_break_lounge_view.dart';
import 'isometric_room/group_break_voting_banner.dart';
import 'session_summary_dialog.dart';
import 'study_room_lobby_screen.dart';
import 'widgets/study_room_music_overlay.dart';

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

class _ActiveStudySessionScreenState extends State<ActiveStudySessionScreen>
    with WidgetsBindingObserver {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  bool _showMusicDock = false;
  final SessionNotificationService _notifService = SessionNotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

    // Start the persistent session notification immediately when the
    // study room screen is opened.
    final roomId = widget.studyService.activeRoom?.id ?? '';
    if (roomId.isNotEmpty) {
      _notifService.showSessionNotification(roomId: roomId);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.studyService.removeListener(_onServiceUpdate);
    _subjectController.dispose();
    _goalController.dispose();
    _notifService.cancelSessionNotification();
    _notifService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final roomId = widget.studyService.activeRoom?.id ?? '';
    if (roomId.isEmpty) return;
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // App moved to background — make sure notification is visible
      _notifService.showSessionNotification(roomId: roomId);
    } else if (state == AppLifecycleState.resumed) {
      // User returned to the app — cancel the notification so it doesn't
      // clutter the shade while the session screen is in the foreground
      _notifService.cancelSessionNotification();
    }
  }

  bool _hasHandledEnded = false;

  void _onServiceUpdate() {
    if (!mounted) return;
    final room = widget.studyService.activeRoom;
    final myId = widget.academicService.profile.id;
    final isHost = room != null && room.hostId == myId;

    if (room != null && room.status == StudyRoomStatus.ended && !_hasHandledEnded && !isHost) {
      _hasHandledEnded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showHostEndedSessionDialog();
      });
      return;
    }
    setState(() {});
  }

  Future<void> _showHostEndedSessionDialog() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.brandOrange),
            const SizedBox(width: 8),
            Text(
              'SESSION ENDED',
              style: AppTypography.headline.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
        content: Text(
          'The host ended the session.',
          style: AppTypography.body.copyWith(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandBlue,
              shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('View Summary', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (!mounted) return;
    final summary = await widget.studyService.recordParticipantSessionSummary();
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
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
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
            hintText: 'e.g. Solving calculus problem set',
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
    final room = widget.studyService.activeRoom;
    final myId = widget.academicService.profile.id;
    final me = room?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => room.participants.first,
    );
    final isCompleted = me?.isGoalCompleted ?? false;
    final hasGoal = me?.personalGoal != null && me!.personalGoal!.isNotEmpty;

    if (isCompleted) {
      _goalController.text = '';
    } else if (hasGoal) {
      _goalController.text = me!.personalGoal!;
    } else {
      _goalController.text = '';
    }

    final dialogTitle = isCompleted
        ? 'Set Next Session Goal'
        : (hasGoal ? 'Edit Session Goal' : 'Set Today\'s Session Goal');

    final dialogSubtitle = isCompleted
        ? 'Great job crushing your previous goal (+25 XP)! Set your next goal to stay focused and earn an extra +25 XP.'
        : 'Complete your goal during this session to earn +25 XP.';

    final buttonText = isCompleted
        ? 'Set Next Goal (+25 XP)'
        : (hasGoal ? 'Save Goal' : 'Set Goal (+25 XP)');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        title: Text(
          dialogTitle,
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
              dialogSubtitle,
              style: AppTypography.caption.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _goalController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: isCompleted
                    ? 'e.g. Solve next 5 practice problems'
                    : 'e.g. Complete introduction & system architecture',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isCompleted
                        ? 'Next goal set! Complete it for another +25 XP.'
                        : 'Session goal set! Complete it to earn +25 XP.'),
                    backgroundColor: AppColors.gamifyPurple,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: Text(buttonText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openMusicOverlay() {
    final room = widget.studyService.activeRoom;
    if (room == null) return;
    final myId = widget.academicService.profile.id;
    final isHost = room.hostId == myId;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Study Soundtrack',
      barrierColor: Colors.black.withValues(alpha: 0.35),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, anim1, anim2, child) {
        final curve = CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic);
        return ScaleTransition(
          scale: Tween<double>(begin: 0.90, end: 1.0).animate(curve),
          child: FadeTransition(
            opacity: curve,
            child: child,
          ),
        );
      },
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: AnimatedBuilder(
              animation: widget.studyService,
              builder: (context, _) {
                final currentRoom = widget.studyService.activeRoom;
                final music = currentRoom?.musicState ?? room.musicState;
                return StudyRoomMusicOverlayCard(
                  musicState: music,
                  isHost: isHost,
                  onTogglePlay: () {
                    if (isHost) {
                      widget.studyService.toggleMusicPlay();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Room music playback is synchronized and controlled by the host.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onNextTrack: () {
                    if (isHost) {
                      widget.studyService.nextTrack();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Track selection is controlled by the host.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onPreviousTrack: () {
                    if (isHost) {
                      widget.studyService.prevTrack();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Track selection is controlled by the host.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  onClose: () => Navigator.of(ctx).pop(),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showBreakRequestSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myId = widget.academicService.profile.id;
    final me = widget.studyService.activeRoom?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => widget.studyService.activeRoom!.participants.first,
    );
    final isAlreadyOnBreak = me?.status == ParticipantStatus.onBreak;

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
                    color: AppColors.brandOrange.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.free_breakfast_rounded, color: AppColors.brandOrange, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAlreadyOnBreak ? 'You are On Break' : 'Take a Study Break',
                        style: AppTypography.headline.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        isAlreadyOnBreak
                            ? 'Your character has stepped outside the study hall'
                            : 'Step away from your workstation or propose a group pause',
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (isAlreadyOnBreak) ...[
              // Action to return from break back to desk
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gamifyEmerald,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                ),
                icon: const Icon(Icons.chair_alt_rounded, color: Colors.white),
                label: const Text(
                  'RETURN TO WORKSTATION',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.8),
                ),
                onPressed: () {
                  widget.studyService.returnFromPersonalBreak();
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Returning to your workstation. Focus resumed!'),
                      backgroundColor: AppColors.gamifyEmerald,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ] else ...[
              Text(
                'PERSONAL BREAK (PHYSICAL EXIT)',
                style: AppTypography.label.copyWith(
                  color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                  fontSize: 10,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [5, 10, 15].map((mins) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandOrange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedMd),
                        ),
                        onPressed: () {
                          widget.studyService.startPersonalBreak(minutes: mins);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Personal break started ($mins min). Character stepping outside.'),
                              backgroundColor: AppColors.brandOrange,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Text(
                          '$mins MIN',
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),

              // Group break proposal
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.gamifyPurple.withValues(alpha: 0.15),
                    borderRadius: AppRadii.roundedSm,
                  ),
                  child: const Icon(Icons.groups_rounded, color: AppColors.gamifyPurple, size: 20),
                ),
                title: const Text('Propose Group Break to Room', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: const Text('Broadcasts a vote to all room members for a 5-min shared pause', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  widget.studyService.requestGroupBreak(minutes: 5);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group break vote requested. Broadcast to all participants.'),
                      backgroundColor: AppColors.gamifyPurple,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
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
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: AppRadii.sheetTop),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 540,
      ),
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 540,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
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

                // Room Breaks & Multiplayer Actions
                Text(
                  'ROOM BREAKS & MULTIPLAYER ACTIONS',
                  style: AppTypography.label.copyWith(
                    fontSize: 10,
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                    letterSpacing: 1.0,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.groups_rounded, color: AppColors.brandOrange, size: 20),
                  title: const Text('Vote for group break', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: const Text('Broadcast break vote banner to all room members', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.studyService.requestBreakForAhmed(5);
                  },
                ),
                ListTile(
                  dense: true,
                  leading: const Icon(Icons.directions_walk_rounded, color: AppColors.streakOrange, size: 20),
                  title: const Text('Toggle personal break', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                  subtitle: const Text('Take a short break without interrupting the room session', style: TextStyle(fontSize: 11)),
                  onTap: () {
                    Navigator.pop(ctx);
                    final ahmed = room?.participants.firstWhere(
                      (p) => p.userId == 'user_ahmed_peer',
                      orElse: () => room.participants.first,
                    );
                    final isBreak = ahmed?.status == ParticipantStatus.onBreak;
                    widget.studyService.simulateAhmedPersonalBreak(!isBreak);
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

    // Transition to Group Break Lounge when room is in synchronized group break
    if (room.isGroupBreakActive) {
      return Scaffold(
        body: GroupBreakLoungeView(
          room: room,
          studyService: widget.studyService,
          academicService: widget.academicService,
          currentUserId: myId,
          isHost: isHost,
        ),
      );
    }

    final isMyBreak = me.status == ParticipantStatus.onBreak;
    final isGroupBreak = room.isGroupBreakActive;
    final pendingBreaks = room.breakRequests.where((b) => b.isApproved == null).toList();
    final music = room.musicState;

    return Scaffold(
      backgroundColor: isDark
          ? (isGroupBreak ? const Color(0xFF14100D) : AppColors.backgroundDark)
          : (isGroupBreak ? const Color(0xFFFFFBEB) : const Color(0xFFF6F3EE)),
      body: Stack(
        children: [
          // 1. Immersive Strategy/Game Study Room Canvas (fills visual area)
          Positioned.fill(
            child: StudyArena(
              participants: room.participants,
              currentUserId: myId,
              isBreakMode: isGroupBreak,
              hideUnusedWorkstations: true,
              onParticipantTap: _showParticipantDetailSheet,
              onDoorTap: _showBreakRequestSheet,
            ),
          ),

          // 2. Top Strategy Game HUD Bar & Overlays
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 720),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      StudyRoomTopHud(
                        room: room,
                        elapsed: elapsed,
                        isHost: isHost,
                        isLocalMuted: widget.studyService.isLocalMuted,
                        onExit: () {
                          if (isHost) {
                            _notifService.cancelSessionNotification();
                            _handleEndSession();
                          } else {
                            _notifService.cancelSessionNotification();
                            widget.studyService.leaveRoom();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          }
                        },
                        onToggleMute: widget.studyService.toggleLocalMute,
                      ),

                      const SizedBox(height: 6),

                      // Group Break Voting Banner (broadcast to all participants)
                      if (room.status == StudyRoomStatus.groupBreakRequested && room.activeGroupBreak != null)
                        GroupBreakVotingBanner(
                          proposal: room.activeGroupBreak!,
                          totalParticipants: room.participants.length,
                          currentUserId: myId,
                          currentUserName: me.displayName,
                          onVote: (accept) => widget.studyService.voteGroupBreak(accept: accept),
                        ),

                      // Host Pending Single Break Request Alert Banner
                      if (isHost && pendingBreaks.isNotEmpty)
                        BreakRequestBanner(
                          request: pendingBreaks.first,
                          onAccept: () => widget.studyService.respondToBreakRequest(pendingBreaks.first.id, true),
                          onDecline: () => widget.studyService.respondToBreakRequest(pendingBreaks.first.id, false),
                        ),

                      const SizedBox(height: 4),

                      // Sub-HUD Row: Contextual Session Goal & Compact Music Button
                      Row(
                        children: [
                          // Contextual Goal Mini-Pill claims all remaining horizontal width
                          Expanded(
                            child: StudyRoomGoalOverlay(
                              goal: me.personalGoal,
                              isCompleted: me.isGoalCompleted,
                              onToggleCompleted: () async {
                                final wasCompleted = me.isGoalCompleted;
                                await widget.studyService.toggleGoalCompleted();
                                if (!wasCompleted && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.stars_rounded, color: Colors.amber, size: 20),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text('🎉 Goal completed! +25 XP earned. Tap "Next Goal" to set another!'),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: AppColors.gamifyEmerald,
                                      behavior: SnackBarBehavior.floating,
                                      duration: Duration(seconds: 4),
                                    ),
                                  );
                                }
                              },
                              onEditGoal: _showGoalDialog,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Compact Music Button
                          InkWell(
                            onTap: _openMusicOverlay,
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              width: 38,
                              height: 36,
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: music.isPlaying
                                      ? Colors.tealAccent.withValues(alpha: 0.6)
                                      : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                                  width: 1.2,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x10000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  music.isPlaying ? Icons.graphic_eq_rounded : Icons.music_note_rounded,
                                  size: 18,
                                  color: music.isPlaying
                                      ? (isDark ? Colors.tealAccent : const Color(0xFF0D9488))
                                      : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Bottom Floating Strategy Game Dock
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 12,
            left: 10,
            right: 10,
            child: Center(
              child: StudyRoomBottomDock(
                isBreakActive: isMyBreak || isGroupBreak,
                isMusicPlaying: music.isPlaying,
                onBreakPressed: _showBreakRequestSheet,
                onSubjectPressed: _showSubjectDialog,
                onGoalPressed: _showGoalDialog,
                onMusicPressed: _openMusicOverlay,
                onMorePressed: _showMoreActionsSheet,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
