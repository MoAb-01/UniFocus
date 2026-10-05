import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/turkish_universities_data.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../dashboard/dashboard_shell.dart';

class AcademicOnboardingScreen extends StatefulWidget {
  final AcademicService academicService;
  final StorageService storage;

  const AcademicOnboardingScreen({
    super.key,
    required this.academicService,
    required this.storage,
  });

  @override
  State<AcademicOnboardingScreen> createState() => _AcademicOnboardingScreenState();
}

class _AcademicOnboardingScreenState extends State<AcademicOnboardingScreen> {
  int _currentStep = 0;

  final _nameController = TextEditingController(text: 'Mohamed Abdou');
  String _selectedUniversity = 'İzmir Kâtip Çelebi University';
  String _selectedDepartment = 'Computer Engineering';
  String _selectedYear = AppConstants.academicYears[3]; // 4th Year

  bool _hasCap = true;
  String _capDepartment = 'Electrical & Electronics Engineering';

  bool _hasMinor = false;
  String _minorDepartment = 'Business Administration';

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _finishOnboarding();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _finishOnboarding() {
    final updatedProfile = widget.academicService.profile.copyWith(
      name: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Mohamed Abdou',
      university: _selectedUniversity,
      department: _selectedDepartment,
      academicYear: _selectedYear,
      hasDoubleMajor: _hasCap,
      doubleMajorDepartment: _hasCap ? _capDepartment : null,
      hasMinor: _hasMinor,
      minorDepartment: _hasMinor ? _minorDepartment : null,
      isOnboardingCompleted: true,
    );

    widget.academicService.updateProfile(updatedProfile);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardShell(
          academicService: widget.academicService,
          storage: widget.storage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Academic Setup'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _prevStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              Row(
                children: List.generate(5, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryNavy : AppColors.borderLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Step Content
              Expanded(
                child: SingleChildScrollView(
                  child: _buildCurrentStepContent(),
                ),
              ),
              const SizedBox(height: 16),
              // Next/Complete Button
              AppButton(
                text: _currentStep == 4 ? 'Save Academic Profile' : 'Continue',
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Personal();
      case 1:
        return _buildStep2University();
      case 2:
        return _buildStep3Department();
      case 3:
        return _buildStep4Year();
      case 4:
        return _buildStep5ProgramStructure();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 1 of 5', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Personal Information', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Please enter your name as it appears on your student transcript.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'Full Name',
          controller: _nameController,
          hint: 'e.g. Mohamed Abdou',
          prefixIcon: Icons.person_outline,
        ),
      ],
    );
  }

  Widget _buildStep2University() {
    final universities = TurkishUniversitiesData.seedUniversities;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 2 of 5', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Select University', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Choose your university from the Turkish higher education directory.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        ...universities.map((uni) {
          final isSelected = _selectedUniversity == uni.name;
          return InkWell(
            onTap: () => setState(() => _selectedUniversity = uni.name),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy.withOpacity(0.04) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.account_balance_outlined,
                    size: 22,
                    color: isSelected ? AppColors.primaryNavy : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          uni.name,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          '${uni.city} • ${uni.type}',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, size: 20, color: AppColors.primaryNavy),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep3Department() {
    final departments = [
      'Computer Engineering',
      'Electrical & Electronics Engineering',
      'Mechanical Engineering',
      'Industrial Engineering',
      'Biomedical Engineering',
      'Civil Engineering',
      'Medicine',
      'Business Administration',
      'Economics',
      'Architecture',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 3 of 5', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Main Department', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Select your primary degree department at $_selectedUniversity.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        ...departments.map((dept) {
          final isSelected = _selectedDepartment == dept;
          return InkWell(
            onTap: () => setState(() => _selectedDepartment = dept),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy.withOpacity(0.04) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      dept,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, size: 18, color: AppColors.primaryNavy),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep4Year() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4 of 5', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Academic Standing', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Select your current academic year.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 24),
        ...AppConstants.academicYears.map((year) {
          final isSelected = _selectedYear == year;
          return InkWell(
            onTap: () => setState(() => _selectedYear = year),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryNavy.withOpacity(0.04) : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primaryNavy : AppColors.borderLight,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 20,
                    color: isSelected ? AppColors.primaryNavy : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      year,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, size: 20, color: AppColors.primaryNavy),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep5ProgramStructure() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 5 of 5', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Program Structure', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'UniFocus customizes GPA tracking and course grouping for students doing ÇAP (Double Major) or Yandal (Minor).',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 24),
        // ÇAP Question Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Are you studying a Double Major (ÇAP)?',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: _hasCap,
                    activeColor: AppColors.primaryNavy,
                    onChanged: (val) => setState(() => _hasCap = val),
                  ),
                ],
              ),
              if (_hasCap) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Double Major Department',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _capDepartment,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    'Electrical & Electronics Engineering',
                    'Industrial Engineering',
                    'Mechanical Engineering',
                    'Biomedical Engineering',
                    'Economics',
                  ].map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontSize: 13.5)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _capDepartment = val);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Yandal Question Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Are you studying a Minor (Yandal)?',
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
                  ),
                  Switch(
                    value: _hasMinor,
                    activeColor: AppColors.primaryNavy,
                    onChanged: (val) => setState(() => _hasMinor = val),
                  ),
                ],
              ),
              if (_hasMinor) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Minor Department',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _minorDepartment,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: [
                    'Business Administration',
                    'Economics',
                    'Artificial Intelligence',
                    'Psychology',
                  ].map((dept) => DropdownMenuItem(value: dept, child: Text(dept, style: const TextStyle(fontSize: 13.5)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _minorDepartment = val);
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
