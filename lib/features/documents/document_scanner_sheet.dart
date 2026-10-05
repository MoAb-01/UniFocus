import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/models/course.dart';
import '../../core/models/scanned_document.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

class DocumentScannerSheet extends StatefulWidget {
  final AcademicService academicService;
  final Course? targetCourse;

  const DocumentScannerSheet({
    super.key,
    required this.academicService,
    this.targetCourse,
  });

  @override
  State<DocumentScannerSheet> createState() => _DocumentScannerSheetState();
}

class _DocumentScannerSheetState extends State<DocumentScannerSheet> {
  final _titleController = TextEditingController();
  final _ocrController = TextEditingController();

  late String _selectedCourseId;
  late String _selectedCourseCode;
  String _selectedCategory = 'Lecture Notes';
  int _pageCount = 1;
  bool _isScanning = false;
  bool _captureCompleted = false;

  @override
  void initState() {
    super.initState();
    final courses = widget.academicService.activeCourses;
    if (widget.targetCourse != null) {
      _selectedCourseId = widget.targetCourse!.id;
      _selectedCourseCode = widget.targetCourse!.code;
      _titleController.text = '${widget.targetCourse!.code} Lecture Notes';
    } else if (courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
      _selectedCourseCode = courses.first.code;
      _titleController.text = '${courses.first.code} Notes';
    } else {
      _selectedCourseId = '';
      _selectedCourseCode = '';
      _titleController.text = 'Study Document';
    }

    _ocrController.text = 'Key concepts, definitions, formulas, and textbook references.';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _ocrController.dispose();
    super.dispose();
  }

  void _simulateCapture() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _captureCompleted = true;
      _ocrController.text =
          'Extracted OCR text: Chapter 4 summary, key formulas, theorem 3.2, and homework solution steps.';
    });
  }

  void _saveDocument() {
    if (_titleController.text.trim().isEmpty) return;

    final doc = ScannedDocument(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      courseId: _selectedCourseId,
      courseCode: _selectedCourseCode,
      title: _titleController.text.trim(),
      category: _selectedCategory,
      pageCount: _pageCount,
      ocrText: _ocrController.text.trim(),
      createdAt: DateTime.now(),
    );

    widget.academicService.addDocument(doc);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final courses = widget.academicService.activeCourses;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Scan Course Document',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Camera Capture Viewfinder Preview
                  Container(
                    height: 170,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _captureCompleted ? AppColors.successEmerald : AppColors.borderLight,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: _isScanning
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(strokeWidth: 2),
                                SizedBox(height: 12),
                                Text('Scanning and running OCR perspective alignment...', style: TextStyle(fontSize: 12)),
                              ],
                            )
                          : _captureCompleted
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.check_circle_outline, size: 38, color: AppColors.successEmerald),
                                    const SizedBox(height: 6),
                                    const Text('Document Captured & Text Extracted', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    TextButton(
                                      onPressed: _simulateCapture,
                                      child: const Text('Retake Scan', style: TextStyle(fontSize: 12)),
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.primaryNavy),
                                    const SizedBox(height: 8),
                                    const Text('Align page within frame', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    const SizedBox(height: 8),
                                    AppButton(
                                      text: 'Capture Document',
                                      onPressed: _simulateCapture,
                                      isFullWidth: false,
                                      height: 36,
                                    ),
                                  ],
                                ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Course Selector
                  const Text('Course', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCourseId.isNotEmpty ? _selectedCourseId : null,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: courses.map((c) => DropdownMenuItem(value: c.id, child: Text('${c.code} - ${c.name}', style: const TextStyle(fontSize: 13.5)))).toList(),
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
                    label: 'Document Title',
                    controller: _titleController,
                    hint: 'e.g. Chapter 4 Lecture Notes',
                  ),

                  const SizedBox(height: 14),

                  // Category
                  const Text('Category', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                    items: AppConstants.documentCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13.5)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCategory = val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // OCR Extracted Text Preview
                  AppTextField(
                    label: 'OCR Extracted Text (Searchable)',
                    controller: _ocrController,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          AppButton(
            text: 'Save Scanned Document',
            onPressed: _saveDocument,
          ),
        ],
      ),
    );
  }
}
