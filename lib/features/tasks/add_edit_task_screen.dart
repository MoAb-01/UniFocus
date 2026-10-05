import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/course.dart';
import '../../core/models/task_item.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class AddEditTaskScreen extends StatefulWidget {
  final AcademicService academicService;
  final TaskItem? existingTask;
  final Course? initialCourse;

  const AddEditTaskScreen({
    super.key,
    required this.academicService,
    this.existingTask,
    this.initialCourse,
  });

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _studyTimeController;

  late String _selectedCourseId;
  late String _selectedCourseCode;
  late DateTime _selectedDueDate;
  String _selectedPriority = 'Medium';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    final t = widget.existingTask;
    _titleController = TextEditingController(text: t?.title ?? '');
    _descController = TextEditingController(text: t?.description ?? '');
    _studyTimeController = TextEditingController(text: '${t?.estimatedStudyMinutes ?? 60}');

    final courses = widget.academicService.activeCourses;
    if (t != null) {
      _selectedCourseId = t.courseId;
      _selectedCourseCode = t.courseCode;
      _selectedDueDate = t.dueDate;
      _selectedPriority = t.priority;
      _progress = t.progress;
    } else if (widget.initialCourse != null) {
      _selectedCourseId = widget.initialCourse!.id;
      _selectedCourseCode = widget.initialCourse!.code;
      _selectedDueDate = DateTime.now().add(const Duration(days: 3));
    } else if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
      _selectedCourseCode = courses.first.code;
      _selectedDueDate = DateTime.now().add(const Duration(days: 3));
    } else {
      _selectedCourseId = '';
      _selectedCourseCode = '';
      _selectedDueDate = DateTime.now().add(const Duration(days: 3));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _studyTimeController.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final studyMins = int.tryParse(_studyTimeController.text.trim()) ?? 60;

    if (widget.existingTask != null) {
      final updated = widget.existingTask!.copyWith(
        courseId: _selectedCourseId,
        courseCode: _selectedCourseCode,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        progress: _progress,
        isCompleted: _progress >= 1.0,
        estimatedStudyMinutes: studyMins,
      );
      final list = List<TaskItem>.from(widget.academicService.tasks);
      final idx = list.indexWhere((t) => t.id == updated.id);
      if (idx != -1) {
        list[idx] = updated;
        widget.academicService.deleteTask(updated.id);
        widget.academicService.addTask(
          courseId: updated.courseId,
          courseCode: updated.courseCode,
          title: updated.title,
          description: updated.description,
          dueDate: updated.dueDate,
          priority: updated.priority,
          estimatedStudyMinutes: updated.estimatedStudyMinutes,
        );
      }
    } else {
      widget.academicService.addTask(
        courseId: _selectedCourseId,
        courseCode: _selectedCourseCode,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        estimatedStudyMinutes: studyMins,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.academicService.activeCourses;
    final isEditing = widget.existingTask != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Create Task / Deadline'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Associated Course
                const Text('Course', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedCourseId.isNotEmpty ? _selectedCourseId : null,
                  decoration: const InputDecoration(),
                  items: courses.map((c) {
                    return DropdownMenuItem(
                      value: c.id,
                      child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 13.5)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _selectedCourseId = val;
                        _selectedCourseCode = courses.firstWhere((c) => c.id == val).code;
                      });
                    }
                  },
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Task Title',
                  controller: _titleController,
                  hint: 'e.g. Wireshark Packet Analysis Lab 2',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Description / Instructions',
                  controller: _descController,
                  hint: 'Requirements, reference chapters, submission rubric...',
                  maxLines: 3,
                ),
                const SizedBox(height: 14),

                // Due Date & Priority
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDueDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.borderLight),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Due Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Text('${_selectedDueDate.day}/${_selectedDueDate.month}/${_selectedDueDate.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedPriority,
                            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                            items: AppConstants.priorities.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 13.5)))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedPriority = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Estimated Required Study (Minutes)',
                  controller: _studyTimeController,
                  hint: '60',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),

                if (isEditing) ...[
                  Text(
                    'Progress: ${(_progress * 100).toInt()}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                  ),
                  Slider(
                    value: _progress,
                    onChanged: (v) => setState(() => _progress = v),
                    activeColor: AppColors.primaryNavy,
                  ),
                  const SizedBox(height: 14),
                ],

                const SizedBox(height: 20),
                AppButton(
                  text: isEditing ? 'Save Changes' : 'Create Task',
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
