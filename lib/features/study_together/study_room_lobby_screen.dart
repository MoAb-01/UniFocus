import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/study_together_service.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/game_button.dart';
import '../../core/widgets/level_badge.dart';
import 'active_study_session_screen.dart';

class StudyRoomLobbyScreen extends StatefulWidget {
  final StudyTogetherService studyService;
  final AcademicService academicService;

  const StudyRoomLobbyScreen({
    super.key,
    required this.studyService,
    required this.academicService,
  });

  @override
  State<StudyRoomLobbyScreen> createState() => _StudyRoomLobbyScreenState();
}

class _StudyRoomLobbyScreenState extends State<StudyRoomLobbyScreen> {
  int? _countdownSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    widget.studyService.addListener(_onServiceChanged);
  }

  @override
  void dispose() {
    widget.studyService.removeListener(_onServiceChanged);
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _onServiceChanged() {
    if (mounted) setState(() {});
  }

  void _startCountdown() {
    setState(() => _countdownSeconds = 3);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownSeconds! <= 1) {
        timer.cancel();
        setState(() => _countdownSeconds = null);
        widget.studyService.startSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ActiveStudySessionScreen(
              studyService: widget.studyService,
              academicService: widget.academicService,
            ),
          ),
        );
      } else {
        setState(() => _countdownSeconds = _countdownSeconds! - 1);
      }
    });
  }

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code $code copied to clipboard! Share with classmates.'),
        backgroundColor: AppColors.brandBlue,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase() : 'U';
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.studyService.activeRoom;
    if (room == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Arena')),
        body: const Center(child: Text('No active room found.')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myId = widget.academicService.profile.id;
    final isHost = room.hostId == myId;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'ARENA LOBBY',
          style: AppTypography.label.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () => _copyRoomCode(room.id),
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Room Code Share Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : Colors.white,
                    borderRadius: AppRadii.roundedLg,
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ARENA CODE',
                              style: AppTypography.label.copyWith(
                                color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              room.id,
                              style: AppTypography.headline.copyWith(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                color: AppColors.brandBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.brandBlueLight,
                          foregroundColor: AppColors.brandBlue,
                        ),
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () => _copyRoomCode(room.id),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Room Session Title & Course
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gamifyPurple,
                        borderRadius: AppRadii.roundedSm,
                      ),
                      child: Text(
                        room.courseCode,
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        room.title,
                        style: AppTypography.title.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Player Roster Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'STUDENTS IN LOBBY (${room.participants.length})',
                      style: AppTypography.label.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        letterSpacing: 0.9,
                      ),
                    ),
                    Text(
                      'READY',
                      style: AppTypography.label.copyWith(
                        color: AppColors.gamifyEmerald,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Player List in Game Roster cards
                Expanded(
                  child: ListView.separated(
                    itemCount: room.participants.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (ctx, idx) {
                      final p = room.participants[idx];
                      final isMe = p.userId == myId;

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceElevatedDark : Colors.white,
                          borderRadius: AppRadii.roundedMd,
                          border: Border.all(
                            color: isMe
                                ? AppColors.brandBlue.withValues(alpha: 0.5)
                                : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
                            width: isMe ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Circular Avatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isMe
                                  ? AppColors.brandBlue
                                  : (isDark ? AppColors.surfaceDark : const Color(0xFFE2E8F0)),
                              child: Text(
                                _getInitials(p.displayName),
                                style: TextStyle(
                                  color: isMe ? Colors.white : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Name & Major
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        p.displayName,
                                        style: AppTypography.body.copyWith(
                                          fontWeight: FontWeight.w800,
                                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                        ),
                                      ),
                                      if (p.isHost) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                          decoration: BoxDecoration(
                                            color: AppColors.gamifyYellow.withValues(alpha: 0.2),
                                            borderRadius: AppRadii.roundedXs,
                                            border: Border.all(color: AppColors.gamifyYellowDark, width: 0.8),
                                          ),
                                          child: Text(
                                            'HOST',
                                            style: AppTypography.label.copyWith(
                                              fontSize: 8.5,
                                              color: AppColors.gamifyYellowDark,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    '${p.major} · Level ${p.level}',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Level Badge
                            LevelBadge(level: p.level),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Host Action Area or Waiting banner
                const SizedBox(height: 16),
                if (isHost) ...[
                  GameButton(
                    text: 'START TOGETHER',
                    variant: GameButtonVariant.success,
                    height: 58,
                    onPressed: _startCountdown,
                  ),
                  const SizedBox(height: 12),
                  GameButton(
                    text: 'LEAVE ROOM',
                    variant: GameButtonVariant.danger,
                    height: 48,
                    onPressed: () {
                      widget.studyService.leaveRoom();
                      Navigator.pop(context);
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF271C0C) : const Color(0xFFFEF3C7),
                      borderRadius: AppRadii.roundedLg,
                      border: Border.all(color: AppColors.gamifyYellow),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation(AppColors.gamifyYellowDark),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'WAITING FOR HOST TO START',
                          style: AppTypography.label.copyWith(
                            color: AppColors.gamifyYellowDark,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  GameButton(
                    text: 'LEAVE ROOM',
                    variant: GameButtonVariant.neutral,
                    height: 48,
                    onPressed: () {
                      widget.studyService.leaveRoom();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ],
            ),
          ),

          // 3-2-1 Countdown Overlay
          if (_countdownSeconds != null)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'STARTING IN',
                      style: AppTypography.label.copyWith(
                        color: Colors.white70,
                        fontSize: 18,
                        letterSpacing: 3.0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '$_countdownSeconds',
                      style: AppTypography.hero.copyWith(
                        fontSize: 120,
                        color: AppColors.gamifyEmerald,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
