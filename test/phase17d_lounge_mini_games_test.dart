import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/room_audio_player_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/core/services/study_together_service.dart';
import 'package:unifocus/features/study_together/isometric_room/group_break_lounge_view.dart';
import 'package:unifocus/features/study_together/isometric_room/participant_voice_panel.dart';
import 'package:unifocus/features/study_together/mini_games/synchronized_mini_games_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 17D Acceptance Tests — Lounge Social Layer & Shared Mini Games', () {
    late StorageService storage;
    late AcademicService academicService;
    late StudyTogetherService studyService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      storage = StorageService();
      await storage.init();
      academicService = AcademicService(storage);
      studyService = StudyTogetherService(
        academicService,
        audioPlayerService: RoomAudioPlayerService(initializePlatformPlayer: false),
      );

      await studyService.createRoom(
        title: 'Study Arena',
        courseCode: 'CS101',
      );
      final p2 = RoomParticipant(
        userId: 'user_ahmed_peer',
        displayName: 'Ahmed',
        major: 'Computer Engineering',
        level: 4,
        isHost: false,
        status: ParticipantStatus.studying,
        currentSubject: 'Calculus',
        joinedAt: DateTime.now(),
      );
      studyService.addParticipant(p2);
    });

    testWidgets('10-Step Acceptance Test: Lounge Voice Panel, Live Waveform, and Synchronized Mini Games', (tester) async {
      // Step 1: Both enter the lounge
      studyService.startSession();
      studyService.requestGroupBreak(minutes: 5);
      // Host and Ahmed vote to approve break
      studyService.voteGroupBreak(accept: true);
      studyService.simulateAhmedVote(true);

      final room = studyService.activeRoom!;
      expect(room.status, StudyRoomStatus.breakMode);
      expect(room.isGroupBreakActive, isTrue);

      // Render the GroupBreakLoungeView
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Step 2: Both appear in the participant list
      expect(find.byType(ParticipantVoicePanel), findsOneWidget);
      expect(find.text(academicService.profile.name), findsOneWidget);
      expect(find.text('Ahmed'), findsOneWidget);
      expect(find.text('(You)'), findsOneWidget);

      // Initially both microphones are muted
      final initialAhmed = studyService.activeRoom!.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
      expect(initialAhmed.isMicMuted, isTrue);
      expect(initialAhmed.isSpeaking, isFalse);
      expect(find.byType(VoiceEqualizerBars), findsNothing);

      // Step 3: User Ahmed unmutes -> Voice panel shows Ahmed's microphone active
      studyService.simulateAhmedMic(true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final unmutedAhmed = studyService.activeRoom!.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
      expect(unmutedAhmed.isMicMuted, isFalse);

      // Step 4: Ahmed speaks -> animated sound-wave equalizer waveform appears
      studyService.simulateAhmedSpeaking(true);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final speakingAhmed = studyService.activeRoom!.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
      expect(speakingAhmed.isSpeaking, isTrue);
      expect(find.byType(VoiceEqualizerBars), findsOneWidget);
      expect(find.text('Speaking'), findsWidgets);

      // Step 5: Ahmed stops speaking -> waveform stops
      studyService.simulateAhmedSpeaking(false);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final silentAhmed = studyService.activeRoom!.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
      expect(silentAhmed.isSpeaking, isFalse);
      expect(find.byType(VoiceEqualizerBars), findsNothing);

      // Step 6: Any user (Ahmed) selects Mini Games -> Room state updates with countdown
      // Navigation tabs check: Breathing | Mini Games | Recharge
      expect(find.text('Breathing'), findsOneWidget);
      expect(find.text('Mini Games'), findsOneWidget);
      expect(find.text('Recharge (+XP)'), findsOneWidget);
      expect(find.text('Brain Teaser'), findsNothing); // Renamed per requirement 2

      studyService.startMiniGame(
        MiniGameType.quickQuiz,
        userId: 'user_ahmed_peer',
        userName: 'Ahmed',
      );

      final gameRoom = studyService.activeRoom!;
      expect(gameRoom.activeMiniGame, isNotNull);
      final activeGame = gameRoom.activeMiniGame!;
      expect(activeGame.gameType, MiniGameType.quickQuiz);
      expect(activeGame.status, MiniGameStatus.countdown);
      expect(activeGame.startedByUserName, 'Ahmed');

      // Step 7: Both see the same countdown
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(SynchronizedMiniGamesView), findsOneWidget);
      expect(find.text('AHMED SELECTED QUICK QUIZ'), findsOneWidget);

      // Step 8: Countdown finishes -> both enter Round 1 with identical question
      // Advance countdown to inRound
      studyService.startRoundFromCountdown(); // ensure inRound
      final roundRoom = studyService.activeRoom!;
      expect(roundRoom.activeMiniGame!.status, MiniGameStatus.inRound);
      expect(roundRoom.activeMiniGame!.currentRound, 1);
      final currentQuestion = roundRoom.activeMiniGame!.currentQuestion;
      expect(currentQuestion.options.length, 4);

      // Verify concurrent selection guard:
      // While a game is currently inRound, starting another game is rejected
      studyService.startMiniGame(MiniGameType.fastMath, userId: 'user_ahmed_peer');
      expect(studyService.activeRoom!.activeMiniGame!.gameType, MiniGameType.quickQuiz);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('ROUND 1 / 3'), findsOneWidget);
      expect(find.text(currentQuestion.prompt), findsOneWidget);

      // Step 9: Individual answers and individual scores
      // User Mohamed answers correct option (0)
      studyService.submitMiniGameAnswer(
        userId: academicService.profile.id,
        optionIndex: currentQuestion.correctIndex,
      );

      // Ahmed answers incorrect option
      final wrongOption = (currentQuestion.correctIndex + 1) % 4;
      studyService.submitMiniGameAnswer(
        userId: 'user_ahmed_peer',
        optionIndex: wrongOption,
      );

      final answeredGame = studyService.activeRoom!.activeMiniGame!;
      expect(answeredGame.answers[academicService.profile.id], currentQuestion.correctIndex);
      expect(answeredGame.answers['user_ahmed_peer'], wrongOption);
      expect(answeredGame.scores[academicService.profile.id], 10);
      expect(answeredGame.scores['user_ahmed_peer'], 0);

      // Step 10: Game ends for everyone simultaneously
      // Advance through Round 2 and Round 3
      studyService.advanceMiniGameRound(); // Round 2
      expect(studyService.activeRoom!.activeMiniGame!.currentRound, 2);

      studyService.advanceMiniGameRound(); // Round 3
      expect(studyService.activeRoom!.activeMiniGame!.currentRound, 3);

      studyService.advanceMiniGameRound(); // Completed
      final completedGame = studyService.activeRoom!.activeMiniGame!;
      expect(completedGame.status, MiniGameStatus.completed);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: studyService.activeRoom!,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('CHALLENGE COMPLETE!'), findsOneWidget);
      expect(find.text('Play Another Game'), findsOneWidget);

      // Clean up all active timers before test finishes
      studyService.dispose();
    });
  });
}
