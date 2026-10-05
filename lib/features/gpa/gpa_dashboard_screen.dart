import 'package:flutter/material.dart';
import '../../core/models/program.dart';
import '../../core/models/semester.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/grade_row.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_card.dart';
import 'what_if_gpa_screen.dart';

class GpaDashboardScreen extends StatefulWidget {
  final AcademicService academicService;

  const GpaDashboardScreen({
    super.key,
    required this.academicService,
  });

  @override
  State<GpaDashboardScreen> createState() => _GpaDashboardScreenState();
}

class _GpaDashboardScreenState extends State<GpaDashboardScreen> {
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

  @override
  Widget build(BuildContext context) {
    final currentProg = widget.academicService.currentProgram;
    final semesters = widget.academicService.activeProgramSemesters;
    final programs = widget.academicService.programs;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('GPA / GANO Academic Record'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calculate_outlined),
            tooltip: 'What-If Calculator',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WhatIfGpaScreen(
                    academicService: widget.academicService,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Program Selection Switcher (Main vs ÇAP)
              if (programs.length > 1) ...[
                Row(
                  children: programs.map((p) {
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
                  }).toList(),
                ),
                const SizedBox(height: 14),
              ],

              // Cumulative GANO Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
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
                      children: [
                        Text(
                          currentProg != null ? currentProg.name.toUpperCase() : 'MAIN PROGRAM',
                          style: AppTypography.labelUppercase.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryNavy.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            currentProg?.typeLabel ?? 'Degree',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryNavy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          (currentProg?.gano ?? 0.0).toStringAsFixed(2),
                          style: AppTypography.gpaValue.copyWith(
                            color: AppColors.primaryNavy,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          '/ 4.00 GANO',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${currentProg?.completedAkts ?? 0} Completed AKTS credits across ${semesters.length} semesters',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // What-If Banner Button
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WhatIfGpaScreen(
                        academicService: widget.academicService,
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accentIndigo.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.accentIndigo.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calculate_outlined, size: 22, color: AppColors.accentIndigo),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What-If GPA Simulator',
                              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.primaryNavy),
                            ),
                            Text(
                              'Test projected grades & calculate target GPA requirements',
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondaryLight),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, size: 20, color: AppColors.accentIndigo),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Academic History by Semester
              SectionHeader(
                title: 'Academic History & Transcripts',
                subtitle: '${semesters.length} semesters recorded',
              ),

              ...semesters.map((sem) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Column(
                    children: [
                      // Semester Header
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sem.displayName,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  '${sem.courses.length} courses • ${sem.totalAkts} AKTS',
                                  style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'SEMESTER GPA',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.textMutedLight),
                                ),
                                Text(
                                  sem.semesterGpa.toStringAsFixed(2),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: sem.semesterGpa >= 3.0 ? AppColors.primaryNavy : AppColors.academicAmber,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      // Course list
                      ...sem.courses.map((course) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: GradeRow(course: course),
                        );
                      }),
                      const SizedBox(height: 6),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
