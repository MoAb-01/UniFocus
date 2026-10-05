import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Game-like tactile Level Badge.
/// Displays user level with 3D depth, energetic purple accents, and vector star icon.
class LevelBadge extends StatelessWidget {
  final int level;
  final bool isLarge;

  const LevelBadge({
    super.key,
    required this.level,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLarge) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.gamifyPurple,
              AppColors.gamifyPurpleDark,
            ],
          ),
          borderRadius: AppRadii.roundedMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.gamifyPurpleDark.withValues(alpha: 0.4),
              offset: const Offset(0, 3),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.military_tech_rounded,
              size: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              'LEVEL $level',
              style: AppTypography.label.copyWith(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gamifyPurple,
        borderRadius: AppRadii.roundedSm,
        boxShadow: const [
          BoxShadow(
            color: AppColors.gamifyPurpleDark,
            offset: Offset(0, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bolt_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 3),
          Text(
            'LVL $level',
            style: AppTypography.label.copyWith(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
