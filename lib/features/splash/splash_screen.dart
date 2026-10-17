import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../core/services/academic_service.dart';
import '../onboarding/academic_onboarding_screen.dart';
import '../dashboard/dashboard_shell.dart';

import '../authentication/login_screen.dart';
import '../../core/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final StorageService storage;
  final AcademicService academicService;
  final AuthService authService;

  const SplashScreen({
    super.key,
    required this.storage,
    required this.academicService,
    required this.authService,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Perform initialization & brand presentation
    await Future.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;

    if (!widget.authService.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => LoginScreen(
            authService: widget.authService,
            academicService: widget.academicService,
            storage: widget.storage,
          ),
        ),
      );
      return;
    }

    if (widget.authService.currentUserId != null) {
      await widget.academicService.loadUserData(widget.authService.currentUserId!);
    }

    if (!mounted) return;

    final profile = widget.academicService.profile;
    if (profile.isOnboardingCompleted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardShell(
            academicService: widget.academicService,
            storage: widget.storage,
            authService: widget.authService,
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => AcademicOnboardingScreen(
            academicService: widget.academicService,
            storage: widget.storage,
            authService: widget.authService,
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Signature UniFocus vibrant focus orange gradient
    const splashGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFB923C), // Warm focus orange
        Color(0xFFF97316), // Signature brand orange
        Color(0xFFEA580C), // Deep focus orange
      ],
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: splashGradient),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    // Crisp white UNiFocus rectangular logo & tagline
                    Expanded(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Image.asset(
                            'assets/images/unifocus_logo_white.png',
                            width: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    // Creator Credit
                    Padding(
                      padding: const EdgeInsets.only(bottom: 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppConstants.developerCredit,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'v${AppConstants.appVersion}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.60),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
