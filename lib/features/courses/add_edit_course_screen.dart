import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/course.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class AddEditCourseScreen extends StatefulWidget {
  final AcademicService academicService;
  final Course? existingCourse;

  const AddEditCourseScreen({
    super.key,
    required this.academicService,
    this.existingCourse,
  });

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _codeController;
  late TextEditingController _nameController;
  late TextEditingController _instructorController;
  late TextEditingController _creditController;
  late TextEditingController _aktsController;

  late String _selectedSemesterId;
  late String _selectedProgramId;
  String? _selectedGrade;

  @override
  void initState() {
    super.initState();
    final c = widget.existingCourse;
    _codeController = TextEditingController(text: c?.code ?? '');
    _nameController = TextEditingController(text: c?.name ?? '');
    _instructorController = TextEditingController(text: c?.instructor ?? '');
    _creditController = TextEditingController(text: c != null ? '${c.credit}' : '3');
    _aktsController = TextEditingController(text: c != null ? '${c.akts}' : '5');

    final semesters = widget.academicService.semesters;
    _selectedSemesterId = c?.semesterId ?? (semesters.isNotEmpty ? semesters.first.id : '');

    final programs = widget.academicService.programs;
    _selectedProgramId = c?.programId ?? (programs.isNotEmpty ? programs.first.id : 'main_prog');
    _selectedGrade = c?.letterGrade;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _instructorController.dispose();
    _creditController.dispose();
    _aktsController.dispose();
    super.dispose();
  }

  void _saveCourse() {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final instructor = _instructorController.text.trim();
    final credit = int.tryParse(_creditController.text.trim()) ?? 3;
    final akts = int.tryParse(_aktsController.text.trim()) ?? 5;

    if (widget.existingCourse != null) {
      final updated = widget.existingCourse!.copyWith(
        code: code,
        name: name,
        instructor: instructor,
        credit: credit,
        akts: akts,
        programId: _selectedProgramId,
        semesterId: _selectedSemesterId,
        letterGrade: _selectedGrade,
        gradePoints: _selectedGrade != null ? AppConstants.gradeScale[_selectedGrade] : null,
        isCompleted: _selectedGrade != null,
      );
      widget.academicService.updateCourse(updated);
    } else {
      widget.academicService.addCourse(
        semesterId: _selectedSemesterId,
        code: code,
        name: name,
        instructor: instructor,
        credit: credit,
        akts: akts,
        programId: _selectedProgramId,
        letterGrade: _selectedGrade,
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final semesters = widget.academicService.semesters;
    final programs = widget.academicService.programs;
    final isEditing = widget.existingCourse != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Course' : 'Add New Course'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Program Selection
                const Text(
                  'Degree Program',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedProgramId,
                  decoration: const InputDecoration(),
                  items: programs.map((p) {
                    return DropdownMenuItem(
                      value: p.id,
                      child: Text(
                        p.name,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedProgramId = val);
                  },
                ),
                const SizedBox(height: 14),

                // Semester Selection
                const Text(
                  'Semester',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedSemesterId.isNotEmpty ? _selectedSemesterId : null,
                  decoration: const InputDecoration(),
                  items: semesters.map((s) {
                    return DropdownMenuItem(
                      value: s.id,
                      child: Text(
                        s.displayName,
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSemesterId = val);
                  },
                ),
                const SizedBox(height: 14),

                // Code and Name
                AppTextField(
                  label: 'Course Code',
                  controller: _codeController,
                  hint: 'e.g. CENG401',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter course code' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Course Name',
                  controller: _nameController,
                  hint: 'e.g. Undergraduate Final Thesis I',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter course name' : null,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Instructor (Optional)',
                  controller: _instructorController,
                  hint: 'e.g. Prof. Dr. Ayşe Yılmaz',
                ),
                const SizedBox(height: 14),

                // AKTS and Credits
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'AKTS (ECTS)',
                        controller: _aktsController,
                        hint: '5',
                        keyboardType: TextInputType.number,
                        validator: (v) => int.tryParse(v ?? '') == null ? 'Invalid' : null,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: AppTextField(
                        label: 'Local Credit',
                        controller: _creditController,
                        hint: '3',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Letter Grade Dropdown
                const Text(
                  'Letter Grade (Optional / Completed)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  value: _selectedGrade,
                  decoration: const InputDecoration(
                    hintText: 'Currently taking / In progress',
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('In progress (Not graded yet)', style: TextStyle(fontSize: 14, color: AppColors.textMutedLight)),
                    ),
                    ...AppConstants.gradeScale.keys.map((grade) {
                      final pts = AppConstants.gradeScale[grade]!;
                      return DropdownMenuItem<String?>(
                        value: grade,
                        child: Text(
                          '$grade ($pts points)',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedGrade = val);
                  },
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: isEditing ? 'Save Changes' : 'Create Course',
                  onPressed: _saveCourse,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
