import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/models/study_session.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/core/services/study_together_service.dart';
import 'package:unifocus/features/study_together/mini_games/synchronized_mini_games_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mini-Game, Music, and Session Ending Synchronization Tests', () {
    late StorageService storage;
    late AcademicService academicService;
    late StudyTogetherService studyService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
      await storage.init();
      academicService = AcademicService(storage);
      studyService = StudyTogetherService(academicService);
    });

    tearDown(() {
      studyService.dispose();
    });

    // -------------------------------------------------------------------------
    // 3. Mini-Game Synchronization Tests
    // -------------------------------------------------------------------------
    testWidgets('3. Mini-Game: Same game, questions, shared timer, UID answers, reveal, and winner result', (tester) async {
      await studyService.createRoom(title: 'CS Trivia Session', courseCode: 'CS101');
      studyService.addParticipant(
        RoomParticipant(
          userId: 'user_ahmed_peer',
          displayName: 'Ahmed',
          major: 'CS',
          level: 2,
          currentSubject: 'CS101',
          joinedAt: DateTime.now(),
        ),
      );
      studyService.startSession();

      // Enter break mode
      studyService.requestGroupBreak(minutes: 5);
      studyService.simulateAhmedVote(true);
      expect(studyService.activeRoom!.status, StudyRoomStatus.breakMode);

      // Start Quick Quiz
      studyService.startMiniGame(MiniGameType.quickQuiz);
      final room = studyService.activeRoom!;
      expect(room.activeMiniGame, isNotNull);
      final game = room.activeMiniGame!;
      expect(game.gameType, MiniGameType.quickQuiz);
      expect(game.status, MiniGameStatus.countdown);
      expect(game.totalRounds, 3);
      expect(game.currentRound, 1);
      expect(game.allQuestions.length, 3);

      // Verify same question is present for everyone
      final q1 = game.currentQuestion;
      expect(q1.prompt, isNotEmpty);
      expect(q1.options.length, 4);

      // Countdown timer completes -> inRound
      studyService.startRoundFromCountdown();
      final inRoundGame = studyService.activeRoom!.activeMiniGame!;
      expect(inRoundGame.status, MiniGameStatus.inRound);
      expect(inRoundGame.roundEndsAt.isAfter(DateTime.now()), isTrue);

      // UID-based answers and scores
      final myId = academicService.profile.id;
      // Mohamed answers correctly
      studyService.submitMiniGameAnswer(userId: myId, optionIndex: q1.correctIndex);
      // Ahmed answers incorrectly
      final wrongIndex = (q1.correctIndex + 1) % 4;
      studyService.submitMiniGameAnswer(userId: 'user_ahmed_peer', optionIndex: wrongIndex);

      final answeredGame = studyService.activeRoom!.activeMiniGame!;
      expect(answeredGame.answers[myId], q1.correctIndex);
      expect(answeredGame.answers['user_ahmed_peer'], wrongIndex);
      expect(answeredGame.scores[myId], 10);
      expect(answeredGame.scores['user_ahmed_peer'], 0);

      // Reveal mode
      studyService.revealMiniGameRound();
      final reviewGame = studyService.activeRoom!.activeMiniGame!;
      expect(reviewGame.status, MiniGameStatus.roundReview);

      // Render the review view to verify reveal UI
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SynchronizedMiniGamesView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: myId,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Verify reveal indicator and answered tags are shown
      expect(find.text('REVEAL'), findsOneWidget);
      expect(find.textContaining('Score: 10 pts'), findsOneWidget);

      // Advance rounds until completed
      studyService.advanceMiniGameRound(); // Round 2
      expect(studyService.activeRoom!.activeMiniGame!.currentRound, 2);
      studyService.advanceMiniGameRound(); // Round 3
      expect(studyService.activeRoom!.activeMiniGame!.currentRound, 3);
      studyService.advanceMiniGameRound(); // Completed

      final completedGame = studyService.activeRoom!.activeMiniGame!;
      expect(completedGame.status, MiniGameStatus.completed);

      // Render scoreboard to verify winner
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SynchronizedMiniGamesView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: myId,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CHALLENGE COMPLETE!'), findsOneWidget);
      expect(find.text('+20 XP Champion'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // 4. Music Synchronization Tests
    // -------------------------------------------------------------------------
    test('4. Music: Real bundled tracks, synchronized play/pause and position', () {
      const available = StudyTogetherService.availableTracks;
      expect(available.length, 3);
      expect(available[0]['url'], 'asset://assets/audio/ambient_study.wav');
      expect(available[1]['url'], 'asset://assets/audio/midnight_focus.wav');
      expect(available[2]['url'], 'asset://assets/audio/deep_piano.wav');

      final defaultRoom = StudyRoom(
        id: '123-456-789',
        title: 'Study Room',
        courseCode: 'CS101',
        hostId: 'host_id',
        hostName: 'Host',
        createdAt: DateTime.now(),
      );
      expect(defaultRoom.musicState.audioUrl, 'asset://assets/audio/ambient_study.wav');

      // Test host play/pause toggle
      final myId = academicService.profile.id;
      final roomWithHost = defaultRoom.copyWith(hostId: myId);

      // Toggle play
      final now = DateTime.now();
      final playingMusic = roomWithHost.musicState.copyWith(
        isPlaying: true,
        startedAt: now,
      );
      expect(playingMusic.isPlaying, isTrue);
      expect(playingMusic.currentPositionSeconds, 0);

      // Position synchronization from timestamp
      final elapsedMusic = playingMusic.copyWith(
        startedAt: now.subtract(const Duration(seconds: 45)),
      );
      expect(elapsedMusic.currentPositionSeconds, greaterThanOrEqualTo(45));
    });

    // -------------------------------------------------------------------------
    // 5. Session Ending + XP & Streak Tests
    // -------------------------------------------------------------------------
    test('5. Session ending: Focus minutes, XP, Level, and Streak progression', () async {
      final initialLevel = academicService.profile.level;
      final initialXp = academicService.profile.xp;
      final initialStreak = academicService.profile.studyStreakDays;

      expect(initialLevel, 1);
      expect(initialXp, 0);
      expect(initialStreak, 0);

      final session = StudySession(
        id: 'test_session_1',
        courseId: 'CS101',
        courseCode: 'CS101',
        taskTitle: 'Algorithm Analysis',
        durationMinutes: 50,
        timestamp: DateTime.now(),
        completed: true,
      );

      // Record 50-minute study session with 150 earned XP
      await academicService.recordStudySessionAndReward(session, earnedXp: 150);

      final updatedProfile = academicService.profile;
      expect(updatedProfile.focusMinutesTotal, 50);
      expect(updatedProfile.xp, 150);
      expect(updatedProfile.level, greaterThanOrEqualTo(2));
      // First completed session initializes streak to 1
      expect(updatedProfile.studyStreakDays, 1);

      // Simulate consecutive day session (+1 streak continuation)
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final sessionDay2 = StudySession(
        id: 'test_session_2',
        courseId: 'CS101',
        courseCode: 'CS101',
        taskTitle: 'Data Structures Sprint',
        durationMinutes: 30,
        timestamp: tomorrow,
        completed: true,
      );
      await academicService.recordStudySessionAndReward(sessionDay2, earnedXp: 100);

      expect(academicService.profile.focusMinutesTotal, 80);
      expect(academicService.profile.studyStreakDays, 2);
    });
  });
}
