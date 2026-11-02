import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'analog_card.dart';
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
    const daysOfWeek = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final currentDayIndex = (DateTime.now().weekday - 1).clamp(0, 6);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: AnalogCard(
          borderRadius: 20,
          padding: const EdgeInsets.all(24),
          shadowOffset: 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Airmail punch-card header stamp
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.cardstockSubtle,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.inkBorder, width: 1.2),
                  ),
                  child: const Text(
                    'OFFICIAL DESK LEDGER RECORD',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inkPrimary,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Main title & message
              Text(
                title.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.inkPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // Weekly Cadence Punch-Card Row (Mon to Sun)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                decoration: BoxDecoration(
                  color: AppColors.paperBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.inkBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    const Text(
                      'WEEKLY CADENCE PUNCH-CARD',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: AppColors.inkSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (i) {
                        final isCompleted = i <= currentDayIndex;
                        return Column(
                          children: [
                            Text(
                              daysOfWeek[i],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted ? AppColors.deepWorkGreen : AppColors.cardstock,
                                border: Border.all(color: AppColors.inkBorder, width: 1.2),
                              ),
                              child: isCompleted
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // XP & Streak Summary row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardstockSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.inkBorder, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'CADENCE REWARD',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.inkSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '+$earnedXp XP',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.deepWorkGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardstockSubtle,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.inkBorder, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ACTIVE STREAK',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: AppColors.inkSecondary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$streakDays DAYS',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.warmAmber),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Simple bold CTA button
              GameButton(
                text: 'RESUME CADENCE',
                variant: GameButtonVariant.primary,
                height: 48,
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
