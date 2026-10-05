import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Compact floating Break Request notification for the host.
/// Contextual interaction with Accept and Decline buttons.
/// Zero Unicode emojis.
class BreakRequestBanner extends StatelessWidget {
  final BreakRequest request;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const BreakRequestBanner({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF271C0C) : const Color(0xFFFFFBEB),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: AppColors.streakOrange.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.streakOrange.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.streakOrange.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.free_breakfast_rounded,
              size: 18,
              color: AppColors.streakOrange,
            ),
          ),
          const SizedBox(width: 10),

          // Request Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${request.userName} requested a break',
                  style: AppTypography.title.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  '${request.requestedMinutes} MIN Break Request',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.streakOrangeDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.dangerRed.withValues(alpha: 0.15),
                  padding: const EdgeInsets.all(6),
                ),
                icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.dangerRed),
                onPressed: onDecline,
              ),
              const SizedBox(width: 6),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gamifyEmerald,
                  padding: const EdgeInsets.all(6),
                ),
                icon: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
                onPressed: onAccept,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
