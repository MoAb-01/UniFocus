import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/app_localizations.dart';
import 'core/services/academic_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/firebase_service.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase backend services (Auth, Firestore, Storage)
  await FirebaseService.instance.init();

  final storage = StorageService();
  await storage.init();

  final authService = AuthService();
  await authService.init();

  final academicService = AcademicService(storage);
  if (authService.currentUserId != null) {
    await academicService.loadUserData(authService.currentUserId!);
  }

  runApp(
    DevicePreview(
      enabled: kIsWeb || !kReleaseMode,
      builder: (context) => UniFocusApp(
        storage: storage,
        academicService: academicService,
        authService: authService,
      ),
    ),
  );
}

class UniFocusApp extends StatefulWidget {
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
  State<UniFocusApp> createState() => _UniFocusAppState();
}

class _UniFocusAppState extends State<UniFocusApp> {
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
    final languageCode = widget.academicService.profile.preferredLanguage;
    final currentLocale = Locale(languageCode.isNotEmpty ? languageCode : 'en');

    return MaterialApp(
      title: 'UniFocus',
      debugShowCheckedModeBanner: false,
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      home: SplashScreen(
        storage: widget.storage,
        academicService: widget.academicService,
        authService: widget.authService,
      ),
    );
  }
}
