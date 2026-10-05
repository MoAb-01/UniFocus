import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'game_button.dart';

class CelebrationDialog extends StatelessWidget {
  final String title;
  final String message;
  final int earnedXp;
  final int streakDays;
  final String? extraSubtitle;
  final VoidCallback onDismiss;

  const CelebrationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.earnedXp,
    required this.streakDays,
    this.extraSubtitle,
    required this.onDismiss,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String message,
    required int earnedXp,
    required int streakDays,
    String? extraSubtitle,
    VoidCallback? onDismiss,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => CelebrationDialog(
        title: title,
        message: message,
        earnedXp: earnedXp,
        streakDays: streakDays,
        extraSubtitle: extraSubtitle,
        onDismiss: () {
          Navigator.of(ctx).pop();
          onDismiss?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedXl),
      elevation: 16,
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Celebratory Icon with halo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.gamifyYellow, AppColors.gamifyYellowDark],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gamifyYellow.withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.emoji_events_rounded,
                  size: 42,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.headline.copyWith(
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 20),

            // Reward Badges Box
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                              '+$earnedXp XP',
                              style: AppTypography.label.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                              '$streakDays Day Streak',
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
                  if (extraSubtitle != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      extraSubtitle!,
                      textAlign: TextAlign.center,
                      style: AppTypography.caption.copyWith(
                        fontSize: 12.5,
                        color: AppColors.gamifyEmeraldDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            GameButton(
              text: 'CONTINUE',
              variant: GameButtonVariant.success,
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
