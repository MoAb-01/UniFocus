import 'package:flutter/material.dart';
import '../models/task_item.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatters.dart';
import 'analog_card.dart';
import 'tactile_press.dart';

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
    final relativeDue = DateFormatters.formatRelativeDue(task.dueDate);
    final isOverdue = task.dueDate.isBefore(DateTime.now()) && !task.isCompleted;

    String priorityLabel = '[NORMAL]';
    Color priorityBorderColor = AppColors.inkBorderLight;
    Color priorityTextColor = AppColors.inkSecondary;

    if (task.priority.toLowerCase() == 'high') {
      priorityLabel = '[URGENT]';
      priorityBorderColor = AppColors.terracottaBreak;
      priorityTextColor = AppColors.terracottaBreak;
    } else if (task.priority.toLowerCase() == 'medium') {
      priorityLabel = '[PRIORITY]';
      priorityBorderColor = AppColors.warmAmber;
      priorityTextColor = AppColors.warmAmber;
    }

    final durationMins = task.estimatedStudyMinutes > 0 ? task.estimatedStudyMinutes : 25;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnalogCard(
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        borderColor: isOverdue ? AppColors.terracottaBreak : AppColors.inkBorder,
        shadowOffset: 2.0,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Clean square checkbox
            TactilePress(
              onTap: onToggleComplete != null ? () => onToggleComplete!(!task.isCompleted) : null,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: task.isCompleted ? AppColors.deepWorkGreen : AppColors.cardstock,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.inkBorder,
                    width: 1.5,
                  ),
                ),
                child: task.isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 10),
            // Task info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      if (task.courseCode.isNotEmpty) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.cardstockSubtle,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.inkBorder, width: 1),
                          ),
                          child: Text(
                            task.courseCode.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.inkPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                      ],
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.cardstock,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: priorityBorderColor, width: 1),
                        ),
                        child: Text(
                          priorityLabel,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: priorityTextColor,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.cardstockSubtle,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.inkBorderLight, width: 1),
                        ),
                        child: Text(
                          '[$durationMins m]',
                          style: const TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.inkSecondary,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: task.isCompleted ? AppColors.inkTertiary : AppColors.inkPrimary,
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      decorationColor: AppColors.inkTertiary,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    isOverdue ? 'Overdue • $relativeDue' : relativeDue,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                      color: isOverdue ? AppColors.terracottaBreak : AppColors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Start focus button
            if (onStartFocus != null && !task.isCompleted) ...[
              const SizedBox(width: 8),
              TactilePress(
                onTap: onStartFocus,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.deepWorkGreen,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.inkBorder, width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.inkBorder,
                        offset: Offset(0, 1.5),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_outlined, size: 12, color: Colors.white),
                      SizedBox(width: 3),
                      Text(
                        'FOCUS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
