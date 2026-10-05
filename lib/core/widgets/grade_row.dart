import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class GradeRow extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const GradeRow({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor = AppColors.surfaceElevatedLight;
    Color textColor = AppColors.textSecondaryLight;

    if (course.letterGrade != null) {
      if (course.letterGrade == 'AA' || course.letterGrade == 'BA') {
        badgeColor = AppColors.successEmerald.withOpacity(0.12);
        textColor = AppColors.successEmerald;
      } else if (course.letterGrade == 'BB' || course.letterGrade == 'CB') {
        badgeColor = AppColors.primaryBlue.withOpacity(0.12);
        textColor = AppColors.primaryBlue;
      } else if (course.letterGrade == 'CC' || course.letterGrade == 'DC') {
        badgeColor = AppColors.academicAmber.withOpacity(0.15);
        textColor = AppColors.academicAmber;
      } else {
        badgeColor = AppColors.errorRose.withOpacity(0.12);
        textColor = AppColors.errorRose;
      }
    }

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            // Course code
            SizedBox(
              width: 75,
              child: Text(
                course.code,
                style: AppTypography.courseCode.copyWith(
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
            // Course Name
            Expanded(
              child: Text(
                course.name,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimaryLight,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // AKTS
            SizedBox(
              width: 50,
              child: Text(
                '${course.akts} AKTS',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Grade badge
            Container(
              width: 44,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(6),
              ),
              alignment: Alignment.center,
              child: Text(
                course.letterGrade ?? '—',
                style: AppTypography.gradeBadge.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
