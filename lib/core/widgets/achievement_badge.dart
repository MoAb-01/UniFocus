import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Game-like Achievement Badge widget.
/// Shows unlocked/locked status, shiny vector icons, and title without emojis.
class AchievementBadge extends StatelessWidget {
  final String title;
  final bool isUnlocked;
  final IconData? customIcon;

  const AchievementBadge({
    super.key,
    required this.title,
    this.isUnlocked = true,
    this.customIcon,
  });

  IconData _resolveIcon() {
    if (customIcon != null) return customIcon!;
    final lower = title.toLowerCase();
    if (lower.contains('first') || lower.contains('together')) {
      return Icons.groups_rounded;
    } else if (lower.contains('streak') || lower.contains('session')) {
      return Icons.local_fire_department_rounded;
    } else if (lower.contains('goal')) {
      return Icons.flag_rounded;
    } else if (lower.contains('honor') || lower.contains('gpa')) {
      return Icons.workspace_premium_rounded;
    }
    return Icons.emoji_events_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final icon = _resolveIcon();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? (isDark ? AppColors.surfaceElevatedDark : AppColors.surfaceLight)
            : (isDark ? const Color(0xFF131A29) : const Color(0xFFF1F5F9)),
        borderRadius: AppRadii.roundedMd,
        border: Border.all(
          color: isUnlocked
              ? AppColors.gamifyYellow.withValues(alpha: 0.6)
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: AppColors.gamifyYellow.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? const LinearGradient(
                      colors: [AppColors.gamifyYellow, AppColors.gamifyYellowDark],
                    )
                  : null,
              color: isUnlocked ? null : Colors.grey.shade400,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 15,
              color: isUnlocked ? Colors.white : Colors.grey.shade700,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w700,
                color: isUnlocked
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
