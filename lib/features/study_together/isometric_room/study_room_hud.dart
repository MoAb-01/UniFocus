import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';

/// Strategy/Game HUD: Top Bar
/// Overlays the active study office with compact, integrated session telemetry:
/// - Exit / Leave button
/// - Room Code pill with tap-to-copy
/// - Synchronized Focus Timer in monospace tabular digits with live pulsing beacon
/// - Course indicator
/// - Live participant count (e.g. 2/6)
/// - Audio mute / unmute toggle
class StudyRoomTopHud extends StatelessWidget {
  final StudyRoom room;
  final Duration elapsed;
  final bool isHost;
  final bool isLocalMuted;
  final VoidCallback onExit;
  final VoidCallback onToggleMute;

  const StudyRoomTopHud({
    super.key,
    required this.room,
    required this.elapsed,
    required this.isHost,
    required this.isLocalMuted,
    required this.onExit,
    required this.onToggleMute,
  });

  String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  void _copyRoomCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: room.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room code ${room.id} copied!'),
        backgroundColor: AppColors.brandOrange,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRoomOnBreak = room.isGroupBreakActive;

    final borderColor = isRoomOnBreak
        ? AppColors.brandOrange.withValues(alpha: 0.6)
        : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0));

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row 1: Back  |  Room Code  ──────────  Participants  |  Mute ──
              Row(
                children: [
                  // Back / Exit Button
                  InkWell(
                    onTap: onExit,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Room Code Badge – expands to fill row 1 gap
                  Expanded(
                    child: InkWell(
                      onTap: () => _copyRoomCode(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.brandOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.brandOrange.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.copy_rounded, size: 11, color: AppColors.brandOrangeDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                room.id,
                                style: AppTypography.label.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.brandOrangeDark,
                                  letterSpacing: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // Participants Count Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person_rounded, size: 13, color: AppColors.brandOrange),
                        const SizedBox(width: 3),
                        Text(
                          '${room.participants.length}/6',
                          style: AppTypography.label.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Audio Mute Toggle
                  InkWell(
                    onTap: onToggleMute,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: isLocalMuted
                            ? AppColors.dangerRed.withValues(alpha: 0.12)
                            : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isLocalMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        size: 18,
                        color: isLocalMuted
                            ? AppColors.dangerRed
                            : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 7),

              // ── Row 2: Pulsing dot  ●  HH:MM:SS  [Course Tag] ────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Status pulsing dot
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: isRoomOnBreak ? AppColors.streakOrange : AppColors.gamifyEmerald,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isRoomOnBreak ? AppColors.streakOrange : AppColors.gamifyEmerald)
                              .withValues(alpha: 0.65),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Timer – large, monospace
                  Text(
                    _formatDuration(elapsed),
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                  ),

                  if (room.courseCode.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 90),
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                        border: Border.all(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                        ),
                      ),
                      child: Text(
                        room.courseCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.label.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Strategy/Game HUD: Session Goal Contextual Floating Chip
class StudyRoomGoalOverlay extends StatelessWidget {
  final String? goal;
  final bool isCompleted;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEditGoal;

  const StudyRoomGoalOverlay({
    super.key,
    required this.goal,
    required this.isCompleted,
    required this.onToggleCompleted,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasGoal = goal != null && goal!.isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCompleted
                  ? AppColors.gamifyEmerald.withValues(alpha: 0.6)
                  : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.flag_rounded,
                size: 14,
                color: isCompleted ? AppColors.gamifyEmerald : AppColors.gamifyPurple,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: GestureDetector(
                  onTap: onEditGoal,
                  child: Text(
                    hasGoal ? goal! : 'Tap to set session goal (+25 XP)',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted
                          ? AppColors.gamifyEmerald
                          : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (hasGoal) ...[
                const SizedBox(width: 6),
                InkWell(
                  onTap: onToggleCompleted,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.gamifyEmerald
                          : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: isCompleted ? Colors.white : Colors.transparent,
                    ),
                  ),
                ),
              ],
              if (isCompleted) ...[
                const SizedBox(width: 8),
                InkWell(
                  onTap: onEditGoal,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                    decoration: BoxDecoration(
                      color: AppColors.gamifyPurple,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gamifyPurple.withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_rounded, size: 12, color: Colors.white),
                        SizedBox(width: 3),
                        Text(
                          'Next Goal (+25 XP)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Strategy/Game HUD: Ambient Room Music Mini-Pill
class StudyRoomMusicPill extends StatelessWidget {
  final RoomMusicState musicState;
  final bool isHost;
  final VoidCallback onTogglePlay;
  final VoidCallback onNextTrack;

  const StudyRoomMusicPill({
    super.key,
    required this.musicState,
    required this.isHost,
    required this.onTogglePlay,
    required this.onNextTrack,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceDark : Colors.white).withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: musicState.isPlaying
                  ? AppColors.brandOrange.withValues(alpha: 0.5)
                  : (isDark ? AppColors.borderDark : const Color(0xFFE2E8F0)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                musicState.isPlaying ? Icons.music_note_rounded : Icons.music_off_rounded,
                size: 14,
                color: musicState.isPlaying ? AppColors.brandOrange : Colors.grey,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  musicState.trackTitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isHost) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onTogglePlay,
                  child: Icon(
                    musicState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 16,
                    color: AppColors.brandOrange,
                  ),
                ),
                InkWell(
                  onTap: onNextTrack,
                  child: const Icon(
                    Icons.skip_next_rounded,
                    size: 16,
                    color: AppColors.brandOrange,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Strategy/Game HUD: Bottom Floating Control Dock
/// Compact capsule bar anchored near bottom of viewport:
/// BREAK, SUBJECT, GOAL, MUSIC, MORE
class StudyRoomBottomDock extends StatelessWidget {
  final VoidCallback onBreakPressed;
  final VoidCallback onSubjectPressed;
  final VoidCallback onGoalPressed;
  final VoidCallback onMusicPressed;
  final VoidCallback onMorePressed;
  final bool isBreakActive;
  final bool isMusicPlaying;

  const StudyRoomBottomDock({
    super.key,
    required this.onBreakPressed,
    required this.onSubjectPressed,
    required this.onGoalPressed,
    required this.onMusicPressed,
    required this.onMorePressed,
    this.isBreakActive = false,
    this.isMusicPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: AppRadii.roundedPill,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: (isDark ? AppColors.surfaceElevatedDark : Colors.white).withValues(alpha: 0.90),
            borderRadius: AppRadii.roundedPill,
            border: Border.all(
              color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHudButton(
                  icon: Icons.free_breakfast_rounded,
                  label: 'BREAK',
                  isActive: isBreakActive,
                  activeColor: AppColors.brandOrange,
                  onTap: onBreakPressed,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHudButton(
                  icon: Icons.auto_stories_rounded,
                  label: 'SUBJECT',
                  isActive: false,
                  activeColor: AppColors.brandBlue,
                  onTap: onSubjectPressed,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHudButton(
                  icon: Icons.flag_rounded,
                  label: 'GOAL',
                  isActive: false,
                  activeColor: AppColors.gamifyPurple,
                  onTap: onGoalPressed,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHudButton(
                  icon: Icons.music_note_rounded,
                  label: 'MUSIC',
                  isActive: isMusicPlaying,
                  activeColor: AppColors.brandOrange,
                  onTap: onMusicPressed,
                  isDark: isDark,
                ),
                _buildDivider(isDark),
                _buildHudButton(
                  icon: Icons.tune_rounded,
                  label: 'MORE',
                  isActive: false,
                  activeColor: AppColors.textSecondaryLight,
                  onTap: onMorePressed,
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      color: (isDark ? Colors.white12 : Colors.black12),
    );
  }

  Widget _buildHudButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.18) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: isActive
                  ? activeColor
                  : (isDark ? Colors.white70 : AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isActive
                    ? activeColor
                    : (isDark ? Colors.white60 : AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
