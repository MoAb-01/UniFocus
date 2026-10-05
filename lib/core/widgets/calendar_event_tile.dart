import 'package:flutter/material.dart';
import '../models/calendar_event.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatters.dart';

class CalendarEventTile extends StatelessWidget {
  final CalendarEvent event;
  final VoidCallback? onTap;

  const CalendarEventTile({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color typeBgColor;
    Color typeTextColor;
    IconData typeIcon;

    switch (event.type.toLowerCase()) {
      case 'exam':
      case 'quiz':
        typeBgColor = AppColors.errorRose.withOpacity(0.12);
        typeTextColor = AppColors.errorRose;
        typeIcon = Icons.quiz_outlined;
        break;
      case 'class':
        typeBgColor = AppColors.primaryNavy.withOpacity(0.08);
        typeTextColor = AppColors.primaryNavy;
        typeIcon = Icons.school_outlined;
        break;
      case 'assignment':
      case 'project':
      case 'presentation':
        typeBgColor = AppColors.academicAmber.withOpacity(0.12);
        typeTextColor = AppColors.academicAmber;
        typeIcon = Icons.assignment_outlined;
        break;
      case 'study session':
        typeBgColor = AppColors.accentIndigo.withOpacity(0.12);
        typeTextColor = AppColors.accentIndigo;
        typeIcon = Icons.timer_outlined;
        break;
      default:
        typeBgColor = AppColors.surfaceElevatedLight;
        typeTextColor = AppColors.textSecondaryLight;
        typeIcon = Icons.event_outlined;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time box
            Container(
              width: 56,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    DateFormatters.time24.format(event.dateTime),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatters.shortDate.format(event.dateTime),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Event Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: typeBgColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(typeIcon, size: 12, color: typeTextColor),
                            const SizedBox(width: 4),
                            Text(
                              event.type,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: typeTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (event.courseCode != null && event.courseCode!.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            event.courseCode!,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  if (event.notes != null && event.notes!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      event.notes!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
