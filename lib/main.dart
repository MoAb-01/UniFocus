import 'package:flutter/material.dart';
import 'core/services/academic_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = StorageService();
  await storage.init();

  final authService = AuthService();
  await authService.init();

  final academicService = AcademicService(storage);

  runApp(UniFocusApp(
    storage: storage,
    academicService: academicService,
    authService: authService,
  ));
}

class UniFocusApp extends StatelessWidget {
  final StorageService storage;
  final AcademicService academicService;
  final AuthService authService;

  const UniFocusApp({
    super.key,
    required this.storage,
    required this.academicService,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UniFocus',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: SplashScreen(
        storage: storage,
        academicService: academicService,
        authService: authService,
      ),
    );
  }
}
