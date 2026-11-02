import 'package:flutter/material.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/analog_card.dart';
import '../../core/widgets/tactile_press.dart';
import '../../core/widgets/task_item_widget.dart';
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
      backgroundColor: AppColors.paperBg,
      appBar: AppBar(
        title: const Text('STUDY DOCKET & TASKS'),
        centerTitle: false,
        backgroundColor: AppColors.paperBg,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TactilePress(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditTaskScreen(
                      academicService: widget.academicService,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.deepWorkGreen,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.inkBorder, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.inkBorder,
                      offset: Offset(0, 2),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'ADD TASK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Selector Chips
            Container(
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
            const Divider(color: AppColors.inkDivider, height: 1),
            // Task List
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: AnalogCard(
                          borderRadius: 16,
                          padding: const EdgeInsets.all(24),
                          shadowOffset: 2.5,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.task_alt_rounded,
                                size: 36,
                                color: AppColors.deepWorkGreen,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _activeFilter == 'Completed'
                                    ? 'No completed tasks recorded yet.'
                                    : 'Docket is completely clear.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.inkPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Maintain your cadence by logging upcoming assignment goals.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final task = filtered[index];
                        return TaskItemWidget(
                          task: task,
                          onToggleComplete: (_) {
                            widget.academicService.completeTaskAndReward(task.id);
                          },
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
                          onStartFocus: () {
                            if (widget.onStartFocus != null) {
                              widget.onStartFocus!(task);
                            }
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

    return TactilePress(
      onTap: () => setState(() => _activeFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.deepWorkGreen : AppColors.cardstock,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.inkBorder, width: 1.2),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.inkBorder,
                    offset: Offset(0, 2),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
            color: isSelected ? Colors.white : AppColors.inkPrimary,
          ),
        ),
      ),
    );
  }
}
