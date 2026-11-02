import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Analog, tactile cardstock XP Bar for UniFocus.
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
    final double safeMax = maxXp > 0 ? maxXp.toDouble() : 100.0;
    final double progress = (currentXp / safeMax).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LVL $level CADENCE',
                style: const TextStyle(
                  color: AppColors.inkPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '$currentXp / $maxXp XP',
                style: const TextStyle(
                  color: AppColors.inkSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
        Container(
          height: isCompact ? 8 : 10,
          decoration: BoxDecoration(
            color: AppColors.cardstockSubtle,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.inkBorder, width: 1.2),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    width: constraints.maxWidth * progress,
                    decoration: BoxDecoration(
                      color: AppColors.deepWorkGreen,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
