import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/calendar_event.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class AddCalendarEventScreen extends StatefulWidget {
  final AcademicService academicService;

  const AddCalendarEventScreen({
    super.key,
    required this.academicService,
  });

  @override
  State<AddCalendarEventScreen> createState() => _AddCalendarEventScreenState();
}

class _AddCalendarEventScreenState extends State<AddCalendarEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedType = 'Assignment';
  String? _selectedCourseId;
  String? _selectedCourseCode;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 2));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 23, minute: 59);
  String _selectedPriority = 'Medium';

  @override
  void initState() {
    super.initState();
    final courses = widget.academicService.activeCourses;
    if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
      _selectedCourseCode = courses.first.code;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) return;

    final eventDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final event = CalendarEvent(
      id: 'event_${DateTime.now().millisecondsSinceEpoch}',
      courseId: _selectedCourseId,
      courseCode: _selectedCourseCode,
      title: _titleController.text.trim(),
      type: _selectedType,
      dateTime: eventDateTime,
      priority: _selectedPriority,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    widget.academicService.addEvent(event);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.academicService.activeCourses;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Add Calendar Event'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppTextField(
                  label: 'Event Title',
                  controller: _titleController,
                  hint: 'e.g. Midterm Exam, Project Submission',
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 14),

                // Event Type
                const Text('Event Type', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(),
                  items: AppConstants.eventTypes.map((type) {
                    return DropdownMenuItem(value: type, child: Text(type, style: const TextStyle(fontSize: 14)));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
                const SizedBox(height: 14),

                // Associated Course
                const Text('Associated Course', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String?>(
                  value: _selectedCourseId,
                  decoration: const InputDecoration(),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('None (General / Personal)', style: TextStyle(fontSize: 14, color: AppColors.textMutedLight)),
                    ),
                    ...courses.map((c) => DropdownMenuItem<String?>(
                          value: c.id,
                          child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 14)),
                        )),
                  ],
                  onChanged: (val) {
                    setState(() {
                      _selectedCourseId = val;
                      if (val != null) {
                        _selectedCourseCode = courses.firstWhere((c) => c.id == val).code;
                      } else {
                        _selectedCourseCode = null;
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),

                // Date & Time pickers
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
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
                              const Text('Date', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
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
                              const Text('Time', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                              const SizedBox(height: 4),
                              Text('${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Priority
                const Text('Priority', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _selectedPriority,
                  decoration: const InputDecoration(),
                  items: AppConstants.priorities.map((p) => DropdownMenuItem(value: p, child: Text(p, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPriority = val);
                  },
                ),
                const SizedBox(height: 14),

                AppTextField(
                  label: 'Notes (Optional)',
                  controller: _notesController,
                  hint: 'Location, syllabus chapters, slides, etc.',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: 'Save Calendar Event',
                  onPressed: _saveEvent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
