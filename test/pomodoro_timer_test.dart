import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/pomodoro_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/features/pomodoro/pomodoro_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AcademicService academicService;
  late PomodoroService pomodoroService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    academicService = AcademicService(storage);
    pomodoroService = PomodoroService(academicService);
  });

  tearDown(() {
    pomodoroService.dispose();
    academicService.dispose();
  });

  group('Pomodoro Timer Slot Switching Tests', () {
    test('Switching duration slot after pausing a 50m session resets timer to 25m and unfreezes', () {
      // 1. Initial 50m duration
      expect(pomodoroService.workMinutes, 50);
      expect(pomodoroService.remainingSeconds, 50 * 60);

      // 2. Start the timer
      pomodoroService.startOrResume();
      expect(pomodoroService.isRunning, isTrue);

      // 3. Pause the timer
      pomodoroService.pause();
      expect(pomodoroService.state, PomodoroState.paused);
      expect(pomodoroService.isRunning, isFalse);

      // 4. Switch to 25m slot while paused
      pomodoroService.setDurations(workMinutes: 25, breakMinutes: 5);

      // 5. Verify timer is reset to 25 mins and state is idle (ready to start)
      expect(pomodoroService.workMinutes, 25);
      expect(pomodoroService.breakMinutes, 5);
      expect(pomodoroService.remainingSeconds, 25 * 60);
      expect(pomodoroService.state, PomodoroState.idle);

      // 6. Starting now counts down from 25 mins cleanly
      pomodoroService.startOrResume();
      expect(pomodoroService.isRunning, isTrue);
    });

    testWidgets('PomodoroScreen: UI updates to 25:00 and unfreezes when slot changed from paused 50m', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PomodoroScreen(
            pomodoroService: pomodoroService,
            academicService: academicService,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Starts at 50:00
      expect(find.text('50:00'), findsOneWidget);

      // Tap play to start 50m timer
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(seconds: 2));
      expect(pomodoroService.isRunning, isTrue);

      // Pause the timer
      await tester.tap(find.byIcon(Icons.pause_rounded));
      await tester.pump();
      expect(pomodoroService.state, PomodoroState.paused);

      // Switch to 25m slot
      await tester.tap(find.text('25m Focus / 5m Break'));
      await tester.pump();

      // Display now shows 25:00 and is not frozen
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Ready to focus'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Starting counts down from 25:00
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(seconds: 1));
      expect(pomodoroService.isRunning, isTrue);
      expect(find.text('24:59'), findsOneWidget);

      pomodoroService.reset();
      await tester.pump();
    });
  });
}
