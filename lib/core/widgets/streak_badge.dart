import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Tactile, game-style Streak Indicator badge.
/// Zero Unicode emojis: uses vector Icons.local_fire_department_rounded with flame glow.
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
        horizontal: isLarge ? 14 : 9,
        vertical: isLarge ? 7 : 4,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.streakOrange,
            AppColors.streakOrangeDark,
          ],
        ),
        borderRadius: isLarge ? AppRadii.roundedLg : AppRadii.roundedMd,
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFC2410C),
            offset: Offset(0, 2.5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: isLarge ? 19 : 14,
            color: Colors.white,
          ),
          const SizedBox(width: 5),
          Text(
            '$streakDays DAY STREAK',
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontSize: isLarge ? 13 : 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Alias for naming consistency
typedef StreakIndicator = StreakBadge;
