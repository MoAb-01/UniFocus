import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../utils/date_formatters.dart';

class TaskItemWidget extends StatelessWidget {
  final TaskItem task;
  final ValueChanged<bool?>? onToggleComplete;
  final VoidCallback? onTap;
  final VoidCallback? onStartFocus;

  const TaskItemWidget({
    super.key,
    required this.task,
    this.onToggleComplete,
    this.onTap,
    this.onStartFocus,
  });

  @override
  Widget build(BuildContext context) {
    Color priorityColor;
    switch (task.priority.toLowerCase()) {
      case 'high':
        priorityColor = AppColors.errorRose;
        break;
      case 'medium':
        priorityColor = AppColors.warningOrange;
        break;
      default:
        priorityColor = AppColors.textSecondaryLight;
    }

    final relativeDue = DateFormatters.formatRelativeDue(task.dueDate);
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOverdue ? AppColors.errorRose.withOpacity(0.4) : AppColors.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Checkbox
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: task.isCompleted,
                    onChanged: onToggleComplete,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primaryNavy,
                  ),
                ),
                const SizedBox(width: 10),
                // Title and course code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (task.courseCode.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                task.courseCode,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryNavy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: priorityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              task.priority,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: priorityColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: task.isCompleted
                              ? AppColors.textMutedLight
                              : AppColors.textPrimaryLight,
                          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                ),
                // Focus launcher
                if (onStartFocus != null && !task.isCompleted)
                  IconButton(
                    icon: const Icon(Icons.timer_outlined, size: 20, color: AppColors.primaryBlue),
                    tooltip: 'Focus on this task',
                    onPressed: onStartFocus,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Progress Bar if in progress
            if (task.progress > 0 && !task.isCompleted) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: task.progress,
                  backgroundColor: AppColors.surfaceElevatedLight,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentIndigo),
                  minHeight: 5,
                ),
              ),
              const SizedBox(height: 6),
            ],
            // Footer: Due date & estimated study time
            Padding(
              padding: const EdgeInsets.only(left: 34),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13,
                    color: isOverdue ? AppColors.errorRose : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    relativeDue,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                      color: isOverdue ? AppColors.errorRose : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('•', style: TextStyle(color: AppColors.textMutedLight)),
                  const SizedBox(width: 12),
                  Icon(Icons.bolt_outlined, size: 13, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 3),
                  Text(
                    DateFormatters.formatDurationMinutes(task.estimatedStudyMinutes),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
