import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/academic_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/grade_calculator.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/section_header.dart';

class WhatIfGpaScreen extends StatefulWidget {
  final AcademicService academicService;

  const WhatIfGpaScreen({
    super.key,
    required this.academicService,
  });

  @override
  State<WhatIfGpaScreen> createState() => _WhatIfGpaScreenState();
}

class _WhatIfGpaScreenState extends State<WhatIfGpaScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Simulator State
  final Map<String, String> _simulatedGrades = {};

  // Target GPA Planner State
  final _targetGpaController = TextEditingController(text: '3.50');
  final _remainingAktsController = TextEditingController(text: '30');
  double? _requiredGpaResult;
  bool _targetCalculated = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    final courses = widget.academicService.currentSemesterCourses;
    for (final c in courses) {
      _simulatedGrades[c.id] = c.letterGrade ?? 'AA';
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _targetGpaController.dispose();
    _remainingAktsController.dispose();
    super.dispose();
  }

  double _calculateProjectedSemesterGpa() {
    final courses = widget.academicService.currentSemesterCourses;
    final simulatedList = courses.map((c) {
      final grade = _simulatedGrades[c.id];
      return c.copyWith(letterGrade: grade);
    }).toList();

    return GradeCalculator.calculateSemesterGpa(simulatedList);
  }

  void _calculateTargetRequirement() {
    final target = double.tryParse(_targetGpaController.text.trim()) ?? 3.50;
    final remainingAkts = int.tryParse(_remainingAktsController.text.trim()) ?? 30;
    final currentProg = widget.academicService.currentProgram;

    final currentGano = currentProg?.gano ?? 0.0;
    final completedAkts = currentProg?.completedAkts ?? 0;

    final res = GradeCalculator.calculateRequiredGpaForTarget(
      currentGano: currentGano,
      completedAkts: completedAkts,
      remainingAkts: remainingAkts,
      targetGano: target,
    );

    setState(() {
      _requiredGpaResult = res;
      _targetCalculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('What-If? GPA Planner'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryNavy,
          unselectedLabelColor: AppColors.textSecondaryLight,
          indicatorColor: AppColors.primaryNavy,
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Grade Simulation'),
            Tab(text: 'Target Planner'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSimulatorTab(),
          _buildTargetPlannerTab(),
        ],
      ),
    );
  }

  Widget _buildSimulatorTab() {
    final courses = widget.academicService.currentSemesterCourses;
    final projectedGpa = _calculateProjectedSemesterGpa();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Projected Result Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.primaryNavy.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'PROJECTED SEMESTER GPA',
                      style: AppTypography.labelUppercase,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.academicAmber.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'ESTIMATE ONLY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.academicAmber,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      projectedGpa.toStringAsFixed(2),
                      style: AppTypography.gpaValue.copyWith(color: AppColors.primaryNavy),
                    ),
                    const SizedBox(width: 8),
                    const Text('/ 4.00', style: TextStyle(fontSize: 15, color: AppColors.textSecondaryLight)),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'This simulation does not overwrite your actual transcripts or GPA history.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SectionHeader(
            title: 'Current Courses',
            subtitle: 'Change grades to see immediate GPA impact',
          ),

          ...courses.map((c) {
            final currentSim = _simulatedGrades[c.id] ?? 'AA';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.code,
                          style: AppTypography.courseCode.copyWith(color: AppColors.primaryNavy),
                        ),
                        Text(
                          '${c.name} (${c.akts} AKTS)',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  DropdownButton<String>(
                    value: currentSim,
                    underline: const SizedBox(),
                    items: AppConstants.gradeScale.keys.map((g) {
                      return DropdownMenuItem(
                        value: g,
                        child: Text(
                          '$g (${AppConstants.gradeScale[g]})',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _simulatedGrades[c.id] = val);
                      }
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTargetPlannerTab() {
    final currentProg = widget.academicService.currentProgram;
    final currentGano = currentProg?.gano ?? 3.42;
    final completedAkts = currentProg?.completedAkts ?? 120;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('Current GANO', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 4),
                    Text(
                      currentGano > 0
                          ? currentGano.toStringAsFixed(2)
                          : (widget.academicService.profile.previousGpa != null
                              ? widget.academicService.profile.previousGpa!.toStringAsFixed(2)
                              : 'GPA NOT SET'),
                      style: TextStyle(
                        fontSize: (currentGano == 0 && widget.academicService.profile.previousGpa == null) ? 16 : 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryNavy,
                      ),
                    ),
                  ],
                ),
                Container(height: 36, width: 1, color: AppColors.borderLight),
                Column(
                  children: [
                    const Text('Completed AKTS', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                    const SizedBox(height: 4),
                    Text(
                      '$completedAkts',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          const SectionHeader(
            title: 'Set Target Goal',
            subtitle: 'Calculate average GPA needed over your next courses',
          ),

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  label: 'Target GANO',
                  controller: _targetGpaController,
                  hint: '3.50',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppTextField(
                  label: 'Remaining AKTS',
                  controller: _remainingAktsController,
                  hint: '30',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          AppButton(
            text: 'Calculate Required GPA',
            onPressed: _calculateTargetRequirement,
          ),

          const SizedBox(height: 24),

          if (_targetCalculated) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _requiredGpaResult != null ? AppColors.surfaceLight : AppColors.errorRose.withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _requiredGpaResult != null ? AppColors.primaryBlue.withOpacity(0.3) : AppColors.errorRose.withOpacity(0.4),
                ),
              ),
              child: _requiredGpaResult != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'REQUIRED AVERAGE GPA',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _requiredGpaResult!.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: AppColors.primaryNavy),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'To reach your target of ${_targetGpaController.text.trim()} GANO, you must maintain an average of ${_requiredGpaResult!.toStringAsFixed(2)} across your next ${_remainingAktsController.text.trim()} AKTS credits.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondaryLight),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TARGET UNATTAINABLE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.errorRose),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Even with straight AAs (4.00), you cannot reach ${_targetGpaController.text.trim()} GANO with only ${_remainingAktsController.text.trim()} remaining AKTS credits.',
                          style: AppTypography.bodySmall.copyWith(color: AppColors.errorRose),
                        ),
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}
