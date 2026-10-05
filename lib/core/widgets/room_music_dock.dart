import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Compact integrated Now Playing component for the Study Arena.
/// Synchronized playback position computed locally from shared timestamps.
/// Zero Unicode emojis.
class RoomMusicDock extends StatefulWidget {
  final RoomMusicState musicState;
  final int positionSeconds;
  final bool isHost;
  final bool isLocalMuted;
  final VoidCallback onTogglePlay;
  final VoidCallback onNextTrack;
  final VoidCallback onToggleMute;

  const RoomMusicDock({
    super.key,
    required this.musicState,
    required this.positionSeconds,
    required this.isHost,
    required this.isLocalMuted,
    required this.onTogglePlay,
    required this.onNextTrack,
    required this.onToggleMute,
  });

  @override
  State<RoomMusicDock> createState() => _RoomMusicDockState();
}

class _RoomMusicDockState extends State<RoomMusicDock> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  String _formatSeconds(int totalSecs) {
    final mins = totalSecs ~/ 60;
    final secs = totalSecs % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPlaying = widget.musicState.isPlaying;
    final progress = (widget.positionSeconds / widget.musicState.totalDurationSeconds).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevatedDark.withValues(alpha: 0.85)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isPlaying
              ? AppColors.brandBlue.withValues(alpha: 0.4)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isPlaying
                ? AppColors.brandBlue.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Animated Audio Visualizer Bars
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.brandBlue.withValues(alpha: 0.15)
                      : (isDark ? AppColors.surfaceDark : const Color(0xFFF1F5F9)),
                  borderRadius: AppRadii.roundedSm,
                ),
                child: Center(
                  child: isPlaying
                      ? AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, _) {
                            final val = _waveController.value;
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildBar(8 + 8 * math.sin(val * 2 * math.pi)),
                                const SizedBox(width: 2.5),
                                _buildBar(14 + 6 * math.cos(val * 2 * math.pi)),
                                const SizedBox(width: 2.5),
                                _buildBar(10 + 7 * math.sin((val + 0.5) * 2 * math.pi)),
                              ],
                            );
                          },
                        )
                      : Icon(
                          Icons.music_note_rounded,
                          size: 16,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // Track Info + Elapsed/Total
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text(
                          'NOW PLAYING',
                          style: AppTypography.label.copyWith(
                            fontSize: 9,
                            color: isPlaying ? AppColors.brandBlue : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                            letterSpacing: 0.8,
                          ),
                        ),
                        if (widget.isLocalMuted) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0.5),
                            decoration: BoxDecoration(
                              color: AppColors.dangerRed.withValues(alpha: 0.15),
                              borderRadius: AppRadii.roundedXs,
                            ),
                            child: Text(
                              'MUTED LOCALLY',
                              style: AppTypography.label.copyWith(
                                fontSize: 8,
                                color: AppColors.dangerRed,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(
                      widget.musicState.trackTitle,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${_formatSeconds(widget.positionSeconds)} / ${_formatSeconds(widget.musicState.totalDurationSeconds)} · ${widget.musicState.artist}',
                      style: AppTypography.caption.copyWith(
                        fontSize: 10,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Controls
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Local Mute button for all participants
                  IconButton(
                    icon: Icon(
                      widget.isLocalMuted
                          ? Icons.volume_off_rounded
                          : Icons.volume_up_rounded,
                      size: 18,
                      color: widget.isLocalMuted
                          ? AppColors.dangerRed
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    onPressed: widget.onToggleMute,
                  ),

                  // Host Play/Pause toggle
                  if (widget.isHost) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                        size: 28,
                        color: AppColors.brandBlue,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: widget.onTogglePlay,
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      onPressed: widget.onNextTrack,
                    ),
                  ],
                ],
              ),
            ],
          ),

          const SizedBox(height: 6),
          // Micro progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark ? AppColors.surfaceDark : const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brandBlue),
              minHeight: 2.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height) {
    return Container(
      width: 2.8,
      height: height.clamp(4.0, 18.0),
      decoration: BoxDecoration(
        color: AppColors.brandBlue,
        borderRadius: BorderRadius.circular(1.5),
      ),
    );
  }
}

typedef RoomMusic = RoomMusicDock;
