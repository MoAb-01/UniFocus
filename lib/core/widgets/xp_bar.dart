import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'level_badge.dart';

/// Energetic, game-style XP Bar for UniFocus.
/// Features smooth animated progress bar, shiny highlight, and Level badge.
class XpBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int maxXp;
  final bool showLabel;
  final bool isCompact;

  const XpBar({
    super.key,
    required this.level,
    required this.currentXp,
    required this.maxXp,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = (currentXp / maxXp).clamp(0.0, 1.0);

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LEVEL $level',
                style: AppTypography.label.copyWith(
                  color: AppColors.gamifyPurple,
                  fontSize: 10,
                ),
              ),
              Text(
                '$currentXp / $maxXp XP',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _buildProgressTrack(progress, height: 7),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.borderDark
              : AppColors.borderLight,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LevelBadge(level: level),
              Row(
                children: [
                  const Icon(
                    Icons.auto_awesome_rounded,
                    size: 14,
                    color: AppColors.gamifyPurple,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$currentXp / $maxXp XP',
                    style: AppTypography.label.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProgressTrack(progress, height: 12),
        ],
      ),
    );
  }

  Widget _buildProgressTrack(double progress, {required double height}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.surfaceElevatedDark
                : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(height / 2),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                width: totalWidth * progress,
                height: height,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFA855F7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gamifyPurple.withValues(alpha: 0.45),
                      blurRadius: 6,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

typedef XPBar = XpBar;
