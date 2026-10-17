import 'package:flutter/material.dart';
import '../../core/constants/turkish_universities_data.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/models/user_profile.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../dashboard/dashboard_shell.dart';
import '../../core/services/auth_service.dart';

class AcademicOnboardingScreen extends StatefulWidget {
  final AcademicService academicService;
  final StorageService storage;
  final AuthService? authService;

  const AcademicOnboardingScreen({
    super.key,
    required this.academicService,
    required this.storage,
    this.authService,
  });

  @override
  State<AcademicOnboardingScreen> createState() => _AcademicOnboardingScreenState();
}

class _AcademicOnboardingScreenState extends State<AcademicOnboardingScreen> {
  int _currentStep = 0;

  late final TextEditingController _nameController;
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _aktsController = TextEditingController();
  final TextEditingController _semesterController =
      TextEditingController(text: '2026–2027 Fall');

  String _selectedUniversity = 'İzmir Kâtip Çelebi University';
  String _selectedDepartment = 'Computer Engineering';
  AcademicYear _selectedYear = AcademicYear.year1;
  bool _noExistingGpa = false;

  bool _hasCap = false;
  String _capDepartment = 'Electrical & Electronics Engineering';

  bool _hasMinor = false;
  String _minorDepartment = 'Business Administration';

  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.academicService.profile.name,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gpaController.dispose();
    _aktsController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 5) {
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

  Future<void> _finishOnboarding() async {
    final name = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : (widget.academicService.profile.name.isNotEmpty
            ? widget.academicService.profile.name
            : 'UniFocus Student');

    final double? gpa = _noExistingGpa
        ? null
        : double.tryParse(_gpaController.text.trim());
    final int akts = _noExistingGpa
        ? 0
        : (int.tryParse(_aktsController.text.trim()) ?? 0);

    final secondType = _hasCap ? 'CAP' : (_hasMinor ? 'MINOR' : 'NONE');
    final secondName = _hasCap
        ? _capDepartment
        : (_hasMinor ? _minorDepartment : null);

    final uid = widget.authService?.currentUserId ??
        (widget.academicService.profile.id != 'user_initial'
            ? widget.academicService.profile.id
            : null);

    final updatedProfile = widget.academicService.profile.copyWith(
      id: uid ?? widget.academicService.profile.id,
      name: name,
      email: widget.authService?.currentUserEmail ?? widget.academicService.profile.email,
      university: _selectedUniversity,
      department: _selectedDepartment,
      academicYear: _selectedYear.value,
      academicYearEnum: _selectedYear,
      currentSemester: _semesterController.text.trim().isNotEmpty
          ? _semesterController.text.trim()
          : '2026–2027 Fall',
      previousGpa: gpa,
      previousCompletedAKTS: akts,
      secondProgramType: secondType,
      secondProgramName: secondName,
      hasDoubleMajor: _hasCap,
      doubleMajorDepartment: _hasCap ? _capDepartment : null,
      hasMinor: _hasMinor,
      minorDepartment: _hasMinor ? _minorDepartment : null,
      preferredLanguage: _selectedLanguage,
      isOnboardingCompleted: true,
      xp: 0,
      level: 1,
      studyStreakDays: 0,
      focusMinutesTotal: 0,
      currentGano: gpa ?? 0.0,
      completedAkts: akts,
    );

    await AppLocalizations.persistLanguage(_selectedLanguage);
    await widget.academicService.resetToCleanUser(updatedProfile);

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DashboardShell(
          academicService: widget.academicService,
          storage: widget.storage,
          authService: widget.authService,
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
              // Progress Bar (6 steps)
              Row(
                children: List.generate(6, (index) {
                  final isActive = index <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 5 ? 6 : 0),
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
                text: _currentStep == 5 ? 'Save Academic Profile' : 'Continue',
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
        return _buildStep5AcademicBaseline();
      case 5:
        return _buildStep6ProgramAndLanguage();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1Personal() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 1 of 6', style: AppTypography.labelUppercase),
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
          hint: 'e.g. Alex Morgan',
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
        const Text('Step 2 of 6', style: AppTypography.labelUppercase),
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
        const Text('Step 3 of 6', style: AppTypography.labelUppercase),
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
    final years = AcademicYear.values;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 4 of 6', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Academic Standing', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Select your current academic standing.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        ...years.map((year) {
          final isSelected = _selectedYear == year;
          return InkWell(
            onTap: () {
              setState(() {
                _selectedYear = year;
                if (year == AcademicYear.prep) {
                  _noExistingGpa = true;
                }
              });
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
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
                      year.displayName,
                      style: TextStyle(
                        fontSize: 14,
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

  Widget _buildStep5AcademicBaseline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 5 of 6', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Academic Baseline', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Enter your previous university record so your cumulative GPA (GANO) is accurate without needing to enter past courses one by one.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text(
            'I have no GPA yet (Freshman or Preparatory)',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          subtitle: const Text(
            'Your profile will display "GPA NOT SET" until graded courses are completed.',
            style: TextStyle(fontSize: 12),
          ),
          value: _noExistingGpa,
          onChanged: (val) {
            setState(() => _noExistingGpa = val ?? false);
          },
        ),
        const SizedBox(height: 16),
        if (!_noExistingGpa) ...[
          AppTextField(
            label: 'Current Cumulative GPA / GANO (0.00 - 4.00)',
            controller: _gpaController,
            hint: 'e.g. 3.30',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Icons.grade_outlined,
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Completed AKTS / ECTS',
            controller: _aktsController,
            hint: 'e.g. 126',
            keyboardType: TextInputType.number,
            prefixIcon: Icons.fact_check_outlined,
          ),
          const SizedBox(height: 16),
        ],
        AppTextField(
          label: 'Current Semester',
          controller: _semesterController,
          hint: 'e.g. 2026–2027 Fall',
          prefixIcon: Icons.calendar_today_outlined,
        ),
      ],
    );
  }

  Widget _buildStep6ProgramAndLanguage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Step 6 of 6', style: AppTypography.labelUppercase),
        const SizedBox(height: 4),
        Text('Programs & Language', style: AppTypography.displayMedium),
        const SizedBox(height: 8),
        Text(
          'Customize double major (ÇAP), minor (Yandal), and preferred interface language.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        ),
        const SizedBox(height: 20),
        // ÇAP
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Double Major (ÇAP)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: const Text('Enrolled in a secondary Bachelor program', style: TextStyle(fontSize: 12)),
          value: _hasCap,
          onChanged: (val) => setState(() {
            _hasCap = val;
            if (val) _hasMinor = false;
          }),
        ),
        if (_hasCap) ...[
          const SizedBox(height: 8),
          AppTextField(
            label: 'ÇAP Department Name',
            controller: TextEditingController(text: _capDepartment),
            onChanged: (v) => _capDepartment = v,
            hint: 'e.g. Electrical & Electronics Engineering',
          ),
          const SizedBox(height: 16),
        ],
        // Minor
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Minor Program (Yandal)', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: const Text('Enrolled in an academic minor certification program', style: TextStyle(fontSize: 12)),
          value: _hasMinor,
          onChanged: (val) => setState(() {
            _hasMinor = val;
            if (val) _hasCap = false;
          }),
        ),
        if (_hasMinor) ...[
          const SizedBox(height: 8),
          AppTextField(
            label: 'Minor Department Name',
            controller: TextEditingController(text: _minorDepartment),
            onChanged: (v) => _minorDepartment = v,
            hint: 'e.g. Business Administration',
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 20),
        const Text(
          'Application Language',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Text('English'),
                selected: _selectedLanguage == 'en',
                onSelected: (_) => setState(() => _selectedLanguage = 'en'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('Türkçe'),
                selected: _selectedLanguage == 'tr',
                onSelected: (_) => setState(() => _selectedLanguage = 'tr'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ChoiceChip(
                label: const Text('العربية'),
                selected: _selectedLanguage == 'ar',
                onSelected: (_) => setState(() => _selectedLanguage = 'ar'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
