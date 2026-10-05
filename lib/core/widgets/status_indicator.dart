import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Clean, vector-driven status badge.
/// Zero Unicode emojis: uses Material Symbols and colored status dot.
class StatusIndicator extends StatelessWidget {
  final ParticipantStatus status;
  final bool isCompact;
  final bool showIcon;

  const StatusIndicator({
    super.key,
    required this.status,
    this.isCompact = false,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = status.color;

    if (isCompact) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadii.roundedPill,
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          if (showIcon) ...[
            const SizedBox(width: 5),
            Icon(
              status.icon,
              size: 13,
              color: color,
            ),
          ],
          const SizedBox(width: 5),
          Text(
            status.label.toUpperCase(),
            style: AppTypography.label.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
