import 'package:flutter/material.dart';
import '../../core/services/study_together_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/game_button.dart';

class SessionSummaryDialog extends StatelessWidget {
  final SessionSummary summary;
  final VoidCallback onDone;
  final VoidCallback onStudyAgain;

  const SessionSummaryDialog({
    super.key,
    required this.summary,
    required this.onDone,
    required this.onStudyAgain,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Victory Trophy Badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gamifyYellow, AppColors.gamifyYellowDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gamifyYellow.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'SESSION COMPLETE',
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Productive focus recorded & XP awarded!',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Metrics Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
                borderRadius: AppRadii.roundedLg,
                border: Border.all(
                  color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                children: [
                  _buildMetricRow(
                    isDark: isDark,
                    label: 'Total Duration',
                    value: _formatDuration(summary.totalDuration),
                    icon: Icons.timer_outlined,
                  ),
                  Divider(
                    height: 16,
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  _buildMetricRow(
                    isDark: isDark,
                    label: 'Focus Time',
                    value: _formatDuration(summary.focusDuration),
                    icon: Icons.bolt_rounded,
                    valueColor: AppColors.brandBlue,
                  ),
                  Divider(
                    height: 16,
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  _buildMetricRow(
                    isDark: isDark,
                    label: 'Break Time',
                    value: _formatDuration(summary.breakDuration),
                    icon: Icons.free_breakfast_rounded,
                    valueColor: AppColors.streakOrange,
                  ),
                  Divider(
                    height: 16,
                    color: isDark ? AppColors.borderDark : const Color(0xFFE2E8F0),
                  ),
                  _buildMetricRow(
                    isDark: isDark,
                    label: 'Session Goal',
                    value: summary.isGoalCompleted ? 'Completed' : 'In Progress',
                    icon: summary.isGoalCompleted ? Icons.check_circle_rounded : Icons.flag_rounded,
                    valueColor: summary.isGoalCompleted ? AppColors.gamifyEmerald : AppColors.gamifyPurple,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // XP and Streak Badges
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.gamifyPurple,
                    borderRadius: AppRadii.roundedMd,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.gamifyPurpleDark,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, color: Colors.white, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '+${summary.earnedXp} XP',
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.streakOrange,
                    borderRadius: AppRadii.roundedMd,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.streakOrangeDark,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${summary.streakDays} Day Streak',
                        style: AppTypography.label.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Buttons: DONE and STUDY AGAIN
            GameButton(
              text: 'DONE',
              variant: GameButtonVariant.success,
              onPressed: onDone,
            ),
            const SizedBox(height: 10),
            GameButton(
              text: 'STUDY AGAIN',
              variant: GameButtonVariant.neutral,
              height: 48,
              onPressed: onStudyAgain,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow({
    required bool isDark,
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
          ),
        ),
      ],
    );
  }
}
