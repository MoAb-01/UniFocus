import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Compact integrated Session Goal component for the Study Arena.
/// Zero Unicode emojis.
class SessionGoalWidget extends StatelessWidget {
  final String? goal;
  final bool isCompleted;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEditGoal;

  const SessionGoalWidget({
    super.key,
    required this.goal,
    required this.isCompleted,
    required this.onToggleCompleted,
    required this.onEditGoal,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasGoal = goal != null && goal!.trim().isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevatedDark.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.9),
        borderRadius: AppRadii.roundedLg,
        border: Border.all(
          color: isCompleted
              ? AppColors.gamifyEmerald
              : (isDark ? AppColors.borderDark : AppColors.borderLight),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Checkmark Interactive Toggle
          GestureDetector(
            onTap: onToggleCompleted,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.gamifyEmerald : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted ? AppColors.gamifyEmerald : AppColors.brandBlue,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      size: 17,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 10),

          // Goal Content
          Expanded(
            child: GestureDetector(
              onTap: onEditGoal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'SESSION GOAL',
                        style: AppTypography.label.copyWith(
                          fontSize: 9.5,
                          color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // +25 XP Chip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.gamifyPurple.withValues(alpha: 0.15),
                          borderRadius: AppRadii.roundedXs,
                        ),
                        child: Text(
                          '+25 XP',
                          style: AppTypography.label.copyWith(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.gamifyPurple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasGoal ? goal! : 'Tap to set what you want to achieve today...',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasGoal
                          ? (isCompleted
                              ? AppColors.gamifyEmerald
                              : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight))
                          : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),

          // Edit Action
          IconButton(
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            onPressed: onEditGoal,
          ),
        ],
      ),
    );
  }
}

typedef SessionGoal = SessionGoalWidget;
