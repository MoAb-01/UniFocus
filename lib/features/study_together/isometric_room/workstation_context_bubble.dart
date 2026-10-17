import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_typography.dart';
import 'isometric_coordinates.dart';

/// Lightweight, floating contextual status indicator above each workstation.
/// Replaces oversized cards with game-like spatial status flags.
class WorkstationContextBubble extends StatelessWidget {
  final WorkstationSlot slot;
  final RoomParticipant? participant;
  final bool isSelf;
  final bool isDark;
  final VoidCallback? onTap;

  const WorkstationContextBubble({
    super.key,
    required this.slot,
    this.participant,
    this.isSelf = false,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deskPos = slot.deskScreenOffset;
    final isOccupied = participant != null;
    final status = participant?.status ?? ParticipantStatus.studying;
    final isOnBreak = status == ParticipantStatus.onBreak;

    final leftOffset = slot.isLeftWing ? deskPos.dx - 62 : deskPos.dx - 42;

    return Positioned(
      left: leftOffset,
      top: deskPos.dy - 68,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 104,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isOccupied
                ? (isDark
                    ? AppColors.surfaceElevatedDark.withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.95))
                : (isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.45)
                    : Colors.white.withValues(alpha: 0.55)),
            borderRadius: AppRadii.roundedPill,
            border: Border.all(
              color: isOccupied
                  ? (isSelf ? AppColors.brandOrange : status.color.withValues(alpha: 0.6))
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelf ? 1.8 : 1.2,
            ),
            boxShadow: isOccupied
                ? [
                    BoxShadow(
                      color: (isSelf ? AppColors.brandOrange : Colors.black)
                          .withValues(alpha: isSelf ? 0.25 : 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: isOccupied
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Live status indicator dot
                        Container(
                          width: 6.5,
                          height: 6.5,
                          decoration: BoxDecoration(
                            color: status.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),

                        // Name
                        Flexible(
                          child: Text(
                            isSelf ? '${participant!.displayName} (You)' : participant!.displayName,
                            style: AppTypography.label.copyWith(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w900,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // Level badge
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.gamifyPurple.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'L${participant!.level}',
                            style: AppTypography.label.copyWith(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gamifyPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),

                    // Current subject or break countdown
                    Text(
                      isOnBreak
                          ? 'Break · ${participant?.breakMinutesRemaining ?? 5}m'
                          : participant!.currentSubject,
                      style: AppTypography.caption.copyWith(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                        color: isOnBreak
                            ? AppColors.streakOrange
                            : (isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_rounded,
                        size: 11,
                        color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        'Desk ${slot.index + 1}',
                        style: AppTypography.label.copyWith(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w700,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
