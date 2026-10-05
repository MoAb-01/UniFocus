import 'package:flutter/material.dart';
import '../models/semester.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class SemesterCard extends StatelessWidget {
  final Semester semester;
  final VoidCallback? onTap;

  const SemesterCard({
    super.key,
    required this.semester,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        semester.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      if (semester.isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'CURRENT',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryNavy,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${semester.courses.length} courses • ${semester.totalAkts} AKTS',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // GPA Display
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'GPA',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedLight,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  semester.semesterGpa.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: semester.semesterGpa >= 3.0
                        ? AppColors.primaryNavy
                        : (semester.semesterGpa >= 2.0
                            ? AppColors.academicAmber
                            : AppColors.errorRose),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.textMutedLight),
          ],
        ),
      ),
    );
  }
}
