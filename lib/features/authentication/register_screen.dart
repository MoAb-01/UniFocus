import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/academic_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../onboarding/academic_onboarding_screen.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService authService;
  final AcademicService academicService;
  final StorageService storage;

  const RegisterScreen({
    super.key,
    required this.authService,
    required this.academicService,
    required this.storage,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.authService.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      // Update profile name
      final currentProfile = widget.academicService.profile;
      widget.academicService.updateProfile(
        currentProfile.copyWith(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          isOnboardingCompleted: false,
        ),
      );

      // Navigate to academic onboarding
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AcademicOnboardingScreen(
            academicService: widget.academicService,
            storage: widget.storage,
          ),
        ),
      );
    } else {
      setState(() => _errorMessage = 'Registration failed. Please check inputs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Join ${AppConstants.appName}',
                  style: AppTypography.displayMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter your credentials to start organizing your university journey.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.errorRose.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.errorRose.withOpacity(0.3)),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.errorRose),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                AppTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'e.g. Mohamed Abdou',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'University Email',
                  controller: _emailController,
                  hint: 'student@university.edu.tr',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter email';
                    if (!v.contains('@')) return 'Enter valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Password',
                  controller: _passwordController,
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) => v == null || v.length < 6 ? 'Minimum 6 characters' : null,
                ),
                const SizedBox(height: 16),

                AppTextField(
                  label: 'Confirm Password',
                  controller: _confirmPasswordController,
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline,
                  validator: (v) => v == null || v.isEmpty ? 'Confirm your password' : null,
                ),
                const SizedBox(height: 28),

                AppButton(
                  text: 'Create Account & Continue',
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
