import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';

class BreakRecommendationDialog extends StatelessWidget {
  final String recommendation;
  final VoidCallback onDismiss;

  const BreakRecommendationDialog({
    super.key,
    required this.recommendation,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.surfaceLight,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successEmerald.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.spa_outlined,
                size: 32,
                color: AppColors.successEmerald,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Time for a Restorative Break',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              recommendation,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            // Quick Break Activity Icons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActivity(Icons.water_drop_outlined, 'Hydrate'),
                _buildActivity(Icons.directions_walk_rounded, 'Walk'),
                _buildActivity(Icons.visibility_off_outlined, 'Rest Eyes'),
                _buildActivity(Icons.accessibility_new_rounded, 'Stretch'),
              ],
            ),
            const SizedBox(height: 22),
            AppButton(
              text: 'Start Break',
              onPressed: () {
                Navigator.pop(context);
                onDismiss();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivity(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryNavy),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondaryLight),
        ),
      ],
    );
  }
}
