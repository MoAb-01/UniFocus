import 'package:flutter/material.dart';
import '../../core/models/course.dart';
import '../../core/models/program.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/course_tile.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/section_header.dart';
import 'course_detail_screen.dart';
import 'add_edit_course_screen.dart';

class CoursesScreen extends StatefulWidget {
  final AcademicService academicService;
  final void Function(Course course)? onStartFocus;

  const CoursesScreen({
    super.key,
    required this.academicService,
    this.onStartFocus,
  });

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  @override
  void initState() {
    super.initState();
    widget.academicService.addListener(_onUpdate);
  }

  @override
  void dispose() {
    widget.academicService.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final programs = widget.academicService.programs;
    final semesters = widget.academicService.activeProgramSemesters;
    final selectedProg = widget.academicService.currentProgram;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Courses & Academics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: 'Add Semester',
            onPressed: () => _showAddSemesterDialog(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Course',
            onPressed: () => _openAddCourseModal(context),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Program Tabs (Main vs ÇAP)
            if (programs.length > 1)
              Container(
                color: AppColors.surfaceLight,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All Programs'),
                      selected: widget.academicService.selectedProgramId == null,
                      onSelected: (_) => widget.academicService.selectProgram(null),
                      selectedColor: AppColors.primaryNavy,
                      labelStyle: TextStyle(
                        color: widget.academicService.selectedProgramId == null
                            ? Colors.white
                            : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ...programs.map((p) {
                      final isSelected = widget.academicService.selectedProgramId == p.id;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(p.type == ProgramType.cap ? 'ÇAP: ${p.name}' : p.name),
                          selected: isSelected,
                          onSelected: (_) => widget.academicService.selectProgram(p.id),
                          selectedColor: p.type == ProgramType.cap
                              ? AppColors.purpleProgram
                              : AppColors.primaryNavy,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // Courses Grouped by Semester
            Expanded(
              child: semesters.isEmpty
                  ? EmptyState(
                      icon: Icons.menu_book_outlined,
                      title: 'No courses registered',
                      message: 'Add courses to your semester to start organizing assignments, notes, and study plans.',
                      buttonText: '+ Add Course',
                      onButtonPressed: () => _openAddCourseModal(context),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      itemCount: semesters.length,
                      itemBuilder: (context, index) {
                        final sem = semesters[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionHeader(
                              title: sem.displayName,
                              subtitle: '${sem.totalAkts} AKTS • GPA ${sem.semesterGpa.toStringAsFixed(2)}',
                              countBadge: sem.courses.length,
                            ),
                            if (sem.courses.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.borderLight),
                                ),
                                child: Text(
                                  'Your semester is empty. Tap + above to add courses.',
                                  style: AppTypography.bodySmall.copyWith(
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ),
                              )
                            else
                              ...sem.courses.map((course) {
                                return CourseTile(
                                  course: course,
                                  programName: course.programId.contains('cap') ? 'ÇAP' : null,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CourseDetailScreen(
                                          course: course,
                                          academicService: widget.academicService,
                                        ),
                                      ),
                                    );
                                  },
                                  onStartFocus: () => widget.onStartFocus?.call(course),
                                );
                              }),
                            const SizedBox(height: 12),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openAddCourseModal(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCourseScreen(
          academicService: widget.academicService,
        ),
      ),
    );
  }

  void _showAddSemesterDialog(BuildContext context) {
    final yearController = TextEditingController(text: '2026–2027');
    String selectedTerm = 'Fall';
    bool isCurrent = true;
    final progId = widget.academicService.selectedProgramId ??
        (widget.academicService.programs.isNotEmpty ? widget.academicService.programs.first.id : 'main_prog');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add New Semester', style: TextStyle(fontWeight: FontWeight.w900)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Academic Year', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              TextField(
                controller: yearController,
                decoration: InputDecoration(
                  hintText: 'e.g. 2026–2027',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Term / Dönem', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedTerm,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                items: const [
                  DropdownMenuItem(value: 'Fall', child: Text('Fall (Güz)')),
                  DropdownMenuItem(value: 'Spring', child: Text('Spring (Bahar)')),
                  DropdownMenuItem(value: 'Summer', child: Text('Summer (Yaz)')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => selectedTerm = val);
                },
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active Current Semester', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                value: isCurrent,
                onChanged: (val) => setDlgState(() => isCurrent = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandBlue,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final year = yearController.text.trim();
                if (year.isNotEmpty) {
                  widget.academicService.addSemester(
                    academicYear: year,
                    term: selectedTerm,
                    programId: progId,
                    isCurrent: isCurrent,
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Create', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
