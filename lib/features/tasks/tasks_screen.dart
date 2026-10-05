import 'package:flutter/material.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/task_item_widget.dart';
import '../../core/widgets/celebration_dialog.dart';
import 'add_edit_task_screen.dart';

class TasksScreen extends StatefulWidget {
  final AcademicService academicService;
  final void Function(TaskItem task)? onStartFocus;

  const TasksScreen({
    super.key,
    required this.academicService,
    this.onStartFocus,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _activeFilter = 'Pending';

  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  List<TaskItem> _getFilteredTasks() {
    final all = widget.academicService.tasks;
    switch (_activeFilter) {
      case 'Pending':
        return all.where((t) => !t.isCompleted).toList();
      case 'Completed':
        return all.where((t) => t.isCompleted).toList();
      case 'High Priority':
        return all.where((t) => t.priority.toLowerCase() == 'high').toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredTasks();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Tasks & Deadlines'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditTaskScreen(
                    academicService: widget.academicService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Selector
            Container(
              color: AppColors.surfaceLight,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Pending'),
                    const SizedBox(width: 8),
                    _buildFilterChip('High Priority'),
                    const SizedBox(width: 8),
                    _buildFilterChip('All'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Completed'),
                  ],
                ),
              ),
            ),

            // Smart Planner Tip Card
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accentIndigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentIndigo.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.psychology_outlined, size: 22, color: AppColors.accentIndigo),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Study Tip',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                          ),
                          Text(
                            'Break down your CENG401 Proposal into 2 Pomodoro sprints today to avoid deadline stress.',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Task List
            Expanded(
              child: filtered.isEmpty
                  ? EmptyState(
                      icon: Icons.checklist_rounded,
                      title: 'You\'re all caught up!',
                      message: _activeFilter == 'Pending'
                          ? 'Enjoy the free time, you crushed all your pending tasks.'
                          : 'No tasks match this filter.',
                      buttonText: '+ Add Task',
                      onButtonPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AddEditTaskScreen(
                              academicService: widget.academicService,
                            ),
                          ),
                        );
                      },
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return TaskItemWidget(
                          task: task,
                          onToggleComplete: (_) async {
                            if (!task.isCompleted) {
                              await widget.academicService.completeTaskAndReward(task.id);
                              if (context.mounted) {
                                CelebrationDialog.show(
                                  context: context,
                                  title: 'Task Completed!',
                                  message: task.title,
                                  earnedXp: 40,
                                  streakDays: widget.academicService.profile.studyStreakDays,
                                );
                              }
                            } else {
                              widget.academicService.toggleTaskComplete(task.id);
                            }
                          },
                          onStartFocus: () => widget.onStartFocus?.call(task),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTaskScreen(
                                  academicService: widget.academicService,
                                  existingTask: task,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _activeFilter == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _activeFilter = label),
      selectedColor: AppColors.primaryNavy,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textSecondaryLight,
        fontWeight: FontWeight.w600,
        fontSize: 12,
      ),
    );
  }
}
