import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Tactile, analog Streak Indicator badge.
/// Zero Unicode emojis: uses typographic formatting and a clean vector icon with zero-blur border styling.
class StreakBadge extends StatelessWidget {
  final int streakDays;
  final bool isLarge;

  const StreakBadge({
    super.key,
    required this.streakDays,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isLarge ? 12 : 8,
        vertical: isLarge ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: AppColors.cardstock,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inkBorder, width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.inkBorder,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: isLarge ? 16 : 13,
            color: AppColors.warmAmber,
          ),
          const SizedBox(width: 4),
          Text(
            '$streakDays ${streakDays == 1 ? 'DAY' : 'DAYS'} STREAK',
            style: TextStyle(
              color: AppColors.inkPrimary,
              fontWeight: FontWeight.w800,
              fontSize: isLarge ? 12 : 10,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
