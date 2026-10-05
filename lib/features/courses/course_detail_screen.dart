import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/course.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/task_item_widget.dart';
import '../tasks/add_edit_task_screen.dart';
import '../documents/document_scanner_sheet.dart';
import 'add_edit_course_screen.dart';

class CourseDetailScreen extends StatefulWidget {
  final Course course;
  final AcademicService academicService;

  const CourseDetailScreen({
    super.key,
    required this.course,
    required this.academicService,
  });

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  late Course _course;

  @override
  void initState() {
    super.initState();
    _course = widget.course;
    widget.academicService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (!mounted) return;
    try {
      final updated = widget.academicService.activeCourses.firstWhere((c) => c.id == _course.id);
      setState(() => _course = updated);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final tasks = widget.academicService.tasks.where((t) => t.courseId == _course.id).toList();
    final documents = widget.academicService.documents.where((d) => d.courseId == _course.id).toList();
    final sessions = widget.academicService.sessions.where((s) => s.courseId == _course.id).toList();

    int totalStudyMinutes = 0;
    for (final s in sessions) {
      totalStudyMinutes += s.durationMinutes;
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_course.code),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Course',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditCourseScreen(
                    academicService: widget.academicService,
                    existingCourse: _course,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.errorRose),
            tooltip: 'Delete Course',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Course Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _course.code,
                            style: AppTypography.courseCode.copyWith(color: AppColors.primaryNavy),
                          ),
                        ),
                        if (_course.letterGrade != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.successEmerald.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _course.letterGrade!,
                              style: AppTypography.gradeBadge.copyWith(color: AppColors.successEmerald),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _course.name,
                      style: AppTypography.displaySmall.copyWith(
                        fontSize: 18,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    if (_course.instructor.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.person_outline, size: 16, color: AppColors.textSecondaryLight),
                          const SizedBox(width: 6),
                          Text(
                            _course.instructor,
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 14),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricCol('AKTS', '${_course.akts}'),
                        _buildMetricCol('Credits', '${_course.credit}'),
                        _buildMetricCol('Focus Time', '${totalStudyMinutes}m'),
                        _buildMetricCol('Documents', '${documents.length}'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tasks Section
              SectionHeader(
                title: 'Assignments & Tasks',
                countBadge: tasks.length,
                actionText: '+ Add Task',
                onActionTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddEditTaskScreen(
                        academicService: widget.academicService,
                        initialCourse: _course,
                      ),
                    ),
                  );
                },
              ),
              if (tasks.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'No tasks created for this course yet.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                  ),
                )
              else
                ...tasks.map((t) => TaskItemWidget(
                      task: t,
                      onToggleComplete: (_) => widget.academicService.toggleTaskComplete(t.id),
                    )),

              const SizedBox(height: 20),

              // Scanned Documents Section
              SectionHeader(
                title: 'Course Notes & Documents',
                countBadge: documents.length,
                actionText: '+ Scan Document',
                onActionTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => DocumentScannerSheet(
                      academicService: widget.academicService,
                      targetCourse: _course,
                    ),
                  );
                },
              ),
              if (documents.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Text(
                    'Scan your first lecture notes or syllabus document for this course.',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                  ),
                )
              else
                ...documents.map((doc) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy.withOpacity(0.06),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.description_outlined, size: 20, color: AppColors.primaryNavy),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  doc.title,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '${doc.category} • ${doc.pageCount} pages',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textMutedLight),
                            onPressed: () => widget.academicService.deleteDocument(doc.id),
                          ),
                        ],
                      ),
                    )),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCol(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryNavy,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Course'),
        content: Text('Are you sure you want to remove ${_course.code} - ${_course.name}? Associated tasks and documents will also be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.academicService.deleteCourse(_course.id);
              Navigator.pop(context); // Pop dialog
              Navigator.pop(context); // Pop screen
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.errorRose)),
          ),
        ],
      ),
    );
  }
}
