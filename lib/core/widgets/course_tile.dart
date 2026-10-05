import 'package:flutter/material.dart';
import '../models/course.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CourseTile extends StatelessWidget {
  final Course course;
  final String? programName;
  final VoidCallback? onTap;
  final VoidCallback? onStartFocus;

  const CourseTile({
    super.key,
    required this.course,
    this.programName,
    this.onTap,
    this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    Color gradeBadgeColor = AppColors.surfaceElevatedLight;
    Color gradeTextColor = AppColors.textSecondaryLight;

    if (course.letterGrade != null) {
      if (course.letterGrade == 'AA' || course.letterGrade == 'BA') {
        gradeBadgeColor = AppColors.successEmerald.withOpacity(0.12);
        gradeTextColor = AppColors.successEmerald;
      } else if (course.letterGrade == 'BB' || course.letterGrade == 'CB') {
        gradeBadgeColor = AppColors.primaryBlue.withOpacity(0.12);
        gradeTextColor = AppColors.primaryBlue;
      } else if (course.letterGrade == 'CC' || course.letterGrade == 'DC') {
        gradeBadgeColor = AppColors.academicAmber.withOpacity(0.15);
        gradeTextColor = AppColors.academicAmber;
      } else {
        gradeBadgeColor = AppColors.errorRose.withOpacity(0.12);
        gradeTextColor = AppColors.errorRose;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Code & Accent Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryNavy.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primaryNavy.withOpacity(0.12)),
              ),
              child: Text(
                course.code,
                style: AppTypography.courseCode.copyWith(
                  color: AppColors.primaryNavy,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Course details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.name,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                      height: 1.25,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (course.instructor.isNotEmpty) ...[
                        Text(
                          course.instructor,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('•', style: TextStyle(color: AppColors.textMutedLight)),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        '${course.akts} AKTS',
                        style: AppTypography.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                      if (programName != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.purpleProgram.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            programName!,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.purpleProgram,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Grade or Focus Action
            if (course.letterGrade != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: gradeBadgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  course.letterGrade!,
                  style: AppTypography.gradeBadge.copyWith(color: gradeTextColor),
                ),
              )
            else if (onStartFocus != null)
              IconButton(
                icon: const Icon(Icons.timer_outlined, size: 20, color: AppColors.primaryBlue),
                tooltip: 'Focus on course',
                onPressed: onStartFocus,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
