import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';

/// Clean, minimal floating music overlay card for the Study Room.
/// Displays track title with previous, play/pause, and next controls.
class StudyRoomMusicOverlayCard extends StatelessWidget {
  final RoomMusicState musicState;
  final bool isHost;
  final VoidCallback onTogglePlay;
  final VoidCallback onNextTrack;
  final VoidCallback onPreviousTrack;
  final VoidCallback onClose;

  const StudyRoomMusicOverlayCard({
    super.key,
    required this.musicState,
    required this.isHost,
    required this.onTogglePlay,
    required this.onNextTrack,
    required this.onPreviousTrack,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: track title and close button
              Row(
                children: [
                  const SizedBox(width: 24), // Balances the close button for true centering
                  Expanded(
                    child: Text(
                      musicState.trackTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Controls: Previous | Play / Pause | Next
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: isHost ? onPreviousTrack : null,
                    icon: Icon(
                      Icons.skip_previous_rounded,
                      size: 26,
                      color: isHost
                          ? (isDark ? Colors.white70 : const Color(0xFF475569))
                          : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                    ),
                    tooltip: isHost ? 'Previous Track' : 'Only host can change tracks',
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: isHost ? onTogglePlay : null,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.brandOrange,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandOrange.withValues(alpha: 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        musicState.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: isHost ? onNextTrack : null,
                    icon: Icon(
                      Icons.skip_next_rounded,
                      size: 26,
                      color: isHost
                          ? (isDark ? Colors.white70 : const Color(0xFF475569))
                          : (isDark ? Colors.white24 : const Color(0xFFCBD5E1)),
                    ),
                    tooltip: isHost ? 'Next Track' : 'Only host can change tracks',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
