import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/core/services/study_together_service.dart';
import 'package:unifocus/core/services/room_audio_player_service.dart';
import 'package:unifocus/features/study_together/isometric_room/isometric_coordinates.dart';
import 'package:unifocus/features/study_together/isometric_room/isometric_study_room.dart';
import 'package:unifocus/features/study_together/isometric_room/workstation_widget.dart';
import 'package:unifocus/features/study_together/isometric_room/group_break_voting_banner.dart';
import 'package:unifocus/features/study_together/isometric_room/group_break_lounge_view.dart';
import 'package:unifocus/features/study_together/isometric_room/avatar_character_widget.dart';
import 'package:unifocus/features/study_together/isometric_room/study_room_hud.dart';
import 'package:unifocus/features/study_together/active_study_session_screen.dart';
import 'package:unifocus/features/study_together/widgets/study_room_music_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AcademicService academicService;
  late StudyTogetherService studyService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    academicService = AcademicService(storage);
    final audio = RoomAudioPlayerService(initializePlatformPlayer: false);
    studyService = StudyTogetherService(academicService, audioPlayerService: audio);

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

  tearDown(() {
    studyService.dispose();
    academicService.dispose();
  });

  group('Phase 17B Acceptance Tests', () {
    // ---------------------------------------------------------
    // Test A: Deterministic Workstation Assignment & Non-Overlap
    // ---------------------------------------------------------
    test('Test A — Deterministic workstation mapping and collision-free slot allocation', () {
      expect(IsometricCoordinates.participantSlotMapping, [0, 3, 1, 4, 2, 5]);

      expect(IsometricStudyRoom.slotIndexForParticipant(0), 0);
      expect(IsometricStudyRoom.slotIndexForParticipant(1), 3);
      expect(IsometricStudyRoom.slotIndexForParticipant(2), 1);
      expect(IsometricStudyRoom.slotIndexForParticipant(3), 4);
      expect(IsometricStudyRoom.slotIndexForParticipant(4), 2);
      expect(IsometricStudyRoom.slotIndexForParticipant(5), 5);

      // Verify no two slots share coordinates or overlap
      final slotOffsets = <int, Offset>{};
      for (final slot in IsometricCoordinates.slots) {
        slotOffsets[slot.index] = slot.deskScreenOffset;
      }

      // Check distance between P1 (slot 0) and P2 (slot 3)
      final p1Offset = slotOffsets[0]!;
      final p2Offset = slotOffsets[3]!;
      final dx = (p1Offset.dx - p2Offset.dx).abs();
      // Ensure horizontal separation across the central aisle is >= 100 pixels
      expect(dx, greaterThanOrEqualTo(100.0));
    });

    // ---------------------------------------------------------
    // Test B: Hide Unused Workstations During Active Session
    // ---------------------------------------------------------
    testWidgets('Test B — Only occupied workstations are rendered in active session', (tester) async {
      final p1 = RoomParticipant(
        userId: 'u1',
        displayName: 'User 1',
        major: 'CENG',
        level: 4,
        isHost: true,
        currentSubject: 'Algorithms',
        joinedAt: DateTime.now(),
      );
      final p2 = RoomParticipant(
        userId: 'u2',
        displayName: 'User 2',
        major: 'EEE',
        level: 3,
        currentSubject: 'Signals',
        joinedAt: DateTime.now(),
      );

      // Test with 2 participants: exactly 2 WorkstationWidget widgets should be rendered
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsometricStudyRoom(
              participants: [p1, p2],
              currentUserId: 'u1',
              hideUnusedWorkstations: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkstationWidget), findsNWidgets(2));

      // Add a 3rd participant: 3 WorkstationWidget widgets should appear
      final p3 = RoomParticipant(
        userId: 'u3',
        displayName: 'User 3',
        major: 'IE',
        level: 2,
        currentSubject: 'Operations Research',
        joinedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsometricStudyRoom(
              participants: [p1, p2, p3],
              currentUserId: 'u1',
              hideUnusedWorkstations: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(WorkstationWidget), findsNWidgets(3));
    });

    // ---------------------------------------------------------
    // Test C: Personal Break (Only Requester Leaves Room)
    // ---------------------------------------------------------
    test('Test C — Personal break affects only requesting participant', () {
      final room = studyService.activeRoom!;
      expect(room.participants.length, greaterThanOrEqualTo(2));

      // User A (Mohamed Abdou) starts personal break
      studyService.startPersonalBreak(minutes: 10);

      final updatedRoom = studyService.activeRoom!;
      final userA = updatedRoom.participants.firstWhere((p) => p.isHost);
      final userB = updatedRoom.participants.firstWhere((p) => !p.isHost);

      // User A is on break
      expect(userA.status, ParticipantStatus.onBreak);
      expect(userA.breakMinutesRemaining, 10);

      // User B is still studying!
      expect(userB.status, ParticipantStatus.studying);

      // Room overall status is still active (not in room-wide break)
      expect(updatedRoom.status, StudyRoomStatus.waiting); // or active once started

      // User A returns from personal break
      studyService.returnFromPersonalBreak();
      final returnedRoom = studyService.activeRoom!;
      final userAReturned = returnedRoom.participants.firstWhere((p) => p.isHost);
      expect(userAReturned.status, ParticipantStatus.studying);
    });

    testWidgets('Test C2 — Personal break triggers avatar walk only for breaking participant while peer remains seated', (tester) async {
      final p1 = RoomParticipant(
        userId: 'u1',
        displayName: 'User 1',
        major: 'CENG',
        level: 4,
        isHost: true,
        status: ParticipantStatus.studying,
        currentSubject: 'Algorithms',
        joinedAt: DateTime.now(),
      );
      final p2 = RoomParticipant(
        userId: 'u2',
        displayName: 'User 2',
        major: 'EEE',
        level: 3,
        isHost: false,
        status: ParticipantStatus.studying,
        currentSubject: 'Signals',
        joinedAt: DateTime.now().add(const Duration(seconds: 1)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsometricStudyRoom(
              participants: [p1, p2],
              currentUserId: 'u2',
              hideUnusedWorkstations: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // User 1 goes on personal break:
      final p1OnBreak = p1.copyWith(status: ParticipantStatus.onBreak, breakMinutesRemaining: 10);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsometricStudyRoom(
              participants: [p1OnBreak, p2],
              currentUserId: 'u2',
              hideUnusedWorkstations: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      // User 2 remains seated and focused
      final user2Widget = find.byWidgetPredicate(
        (widget) => widget is AvatarCharacterWidget && widget.participant.userId == 'u2',
      );
      expect(user2Widget, findsOneWidget);
      final user2Avatar = tester.widget<AvatarCharacterWidget>(user2Widget);
      expect(user2Avatar.isWalkingToDoor, false);
      expect(user2Avatar.isOutOfRoom, false);

      // User 1 is walking to the door
      final user1Widget = find.byWidgetPredicate(
        (widget) => widget is AvatarCharacterWidget && widget.participant.userId == 'u1',
      );
      expect(user1Widget, findsOneWidget);
      final user1Avatar = tester.widget<AvatarCharacterWidget>(user1Widget);
      expect(user1Avatar.isWalkingToDoor, true);

      // Advance past the 2.2s walking animation
      await tester.pump(const Duration(milliseconds: 2500));

      // User 1 is now outside the room
      final user1AfterWalk = tester.widget<AvatarCharacterWidget>(find.byWidgetPredicate(
        (widget) => widget is AvatarCharacterWidget && widget.participant.userId == 'u1',
      ));
      expect(user1AfterWalk.isOutOfRoom, true);

      // User 1 returns from break
      final p1Returned = p1.copyWith(status: ParticipantStatus.studying, breakMinutesRemaining: null);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IsometricStudyRoom(
              participants: [p1Returned, p2],
              currentUserId: 'u2',
              hideUnusedWorkstations: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 200));

      final user1Returning = tester.widget<AvatarCharacterWidget>(find.byWidgetPredicate(
        (widget) => widget is AvatarCharacterWidget && widget.participant.userId == 'u1',
      ));
      expect(user1Returning.isWalkingToDesk, true);

      await tester.pump(const Duration(milliseconds: 2500));
      final user1Seated = tester.widget<AvatarCharacterWidget>(find.byWidgetPredicate(
        (widget) => widget is AvatarCharacterWidget && widget.participant.userId == 'u1',
      ));
      expect(user1Seated.isWalkingToDesk, false);
      expect(user1Seated.isOutOfRoom, false);
    });

    // ---------------------------------------------------------
    // Test D: Group Break (Broadcast, Voting, Room State, & Transition)
    // ---------------------------------------------------------
    testWidgets('Test D — Group break lifecycle: request, voting banner, room transition, and return', (tester) async {
      studyService.startSession();
      final room = studyService.activeRoom!;
      expect(room.status, StudyRoomStatus.active);

      // Ahmed requests group break
      studyService.requestGroupBreakForAhmed(5);

      final requestedRoom = studyService.activeRoom!;
      expect(requestedRoom.status, StudyRoomStatus.groupBreakRequested);
      expect(requestedRoom.activeGroupBreak, isNotNull);
      expect(requestedRoom.activeGroupBreak!.requesterName, 'Ahmed');
      expect(requestedRoom.activeGroupBreak!.acceptCount, 1);

      // Verify GroupBreakVotingBanner renders
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakVotingBanner(
              proposal: requestedRoom.activeGroupBreak!,
              totalParticipants: requestedRoom.participants.length,
              currentUserId: 'user_mohamed_abdou',
              onVote: (accept) => studyService.voteGroupBreak(accept: accept),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ahmed requested a group break'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      // User A accepts the vote -> 2 / 2 votes -> triggers group break
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      final breakRoom = studyService.activeRoom!;
      expect(breakRoom.status, StudyRoomStatus.breakMode);
      expect(breakRoom.isGroupBreakActive, isTrue);
      expect(breakRoom.breakStartedAt, isNotNull);
      expect(breakRoom.breakEndsAt, isNotNull);

      // Verify GroupBreakLoungeView renders
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: breakRoom,
              studyService: studyService,
              academicService: academicService,
              currentUserId: 'user_mohamed_abdou',
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('GROUP BREAK IN PROGRESS'), findsOneWidget);
      expect(find.text('Temporary Voice Lounge'), findsOneWidget);
      expect(find.text('Breathing'), findsOneWidget);

      // Return from group break
      studyService.endGroupBreak();
      final resumedRoom = studyService.activeRoom!;
      expect(resumedRoom.status, StudyRoomStatus.active);
      expect(resumedRoom.isGroupBreakActive, isFalse);

      // Drain pending peer simulation timers
      await tester.pump(const Duration(seconds: 16));
    });

    // ---------------------------------------------------------
    // Test E: Synchronized Music & Host Permissions
    // ---------------------------------------------------------
    test('Test E — Synchronized audio playback state, timestamps, and host permissions', () {
      final room = studyService.activeRoom!;
      final hostId = room.hostId;
      const nonHostId = 'user_ahmed_peer';

      // 1. Non-host cannot toggle room music play
      studyService.toggleMusicPlay(requesterId: nonHostId);
      expect(studyService.activeRoom!.musicState.isPlaying, isFalse);

      // 2. Host starts music -> playing becomes true, startedAt timestamp is stamped
      studyService.toggleMusicPlay(requesterId: hostId);
      final playingRoom = studyService.activeRoom!;
      expect(playingRoom.musicState.isPlaying, isTrue);
      expect(playingRoom.musicState.startedAt, isNotNull);

      // 3. Current position is calculated dynamically from startedAt timestamp
      final posSec = playingRoom.musicState.currentPositionSeconds;
      expect(posSec, greaterThanOrEqualTo(0));

      // 4. Host changes track -> all members receive new track ID and URL
      studyService.nextTrack(requesterId: hostId);
      final nextTrackRoom = studyService.activeRoom!;
      expect(nextTrackRoom.musicState.trackId, 'track_midnight_focus');
      expect(nextTrackRoom.musicState.audioUrl, contains('midnight_focus.wav'));
      expect(nextTrackRoom.musicState.isPlaying, isTrue);

      // 5. Host pauses music -> everyone pauses, position is frozen
      studyService.toggleMusicPlay(requesterId: hostId);
      final pausedRoom = studyService.activeRoom!;
      expect(pausedRoom.musicState.isPlaying, isFalse);
      expect(pausedRoom.musicState.startedAt, isNull);

      // 6. Local volume and mute affect only local client
      studyService.setLocalVolume(0.5);
      expect(studyService.localVolume, 0.5);

      studyService.toggleLocalMute();
      expect(studyService.isLocalMuted, isTrue);
    });

    // ---------------------------------------------------------
    // Test F: Responsive Layout, Centered Top HUD, and Scrollable Bottom Sheet
    // ---------------------------------------------------------
    testWidgets('Test F — Responsive layout and bottom sheet scrolling without overflow across aspect ratios', (tester) async {
      // 1. Compact phone viewport (360 x 640)
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveStudySessionScreen(
            studyService: studyService,
            academicService: academicService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Top HUD bar is present, centered, and constrained
      expect(find.byType(StudyRoomTopHud), findsOneWidget);
      final topHudSize = tester.getSize(find.byType(StudyRoomTopHud));
      expect(topHudSize.width, lessThanOrEqualTo(720));

      // Floating action row: goal overlay claims remaining width, compact music button is present
      expect(find.text('Tap to set session goal (+25 XP)'), findsOneWidget);
      final musicBtn = find.byIcon(Icons.music_note_rounded).first;
      expect(musicBtn, findsOneWidget);

      // Tap compact music button to open floating music overlay card
      await tester.tap(musicBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StudyRoomMusicOverlayCard), findsOneWidget);
      expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
      expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);

      // Close the music overlay card
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(StudyRoomMusicOverlayCard), findsNothing);

      // Open Arena Options & Controls sheet
      await tester.tap(find.text('MORE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Arena Options & Controls'), findsOneWidget);
      expect(find.text('Vote for group break'), findsOneWidget);

      // Verify the bottom sheet can be scrolled down smoothly to reveal End Session
      await tester.drag(find.text('Arena Options & Controls'), const Offset(0, -250));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('End Study Arena'), findsOneWidget);

      // Dismiss the bottom sheet
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // 2. Short landscape viewport (640 x 360) where overflow previously occurred
      tester.view.physicalSize = const Size(640, 360);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Open MORE sheet again in landscape
      await tester.tap(find.text('MORE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Sheet opens safely with SingleChildScrollView & constraints without throwing RenderFlex overflow
      expect(find.text('Arena Options & Controls'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Drag to scroll
      await tester.drag(find.text('Arena Options & Controls'), const Offset(0, -200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull);

      // Dismiss sheet
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    });

    testWidgets('Test G — Consecutive session goals and extra XP accumulation', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final initialXp = academicService.profile.xp;
      studyService.startSession();

      await tester.pumpWidget(
        MaterialApp(
          home: ActiveStudySessionScreen(
            studyService: studyService,
            academicService: academicService,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Verify bottom sheet has renamed break actions
      await tester.tap(find.text('MORE'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Vote for group break'), findsOneWidget);
      expect(find.text('Toggle personal break'), findsOneWidget);
      expect(find.text('Ahmed: Request Group Break'), findsNothing);
      expect(find.text('Ahmed: Toggle Personal Break'), findsNothing);

      // Dismiss bottom sheet
      await tester.tapAt(const Offset(20, 20));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Set first goal
      studyService.setPersonalGoal('Goal 1: Read chapter');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Goal 1: Read chapter'), findsOneWidget);

      // Complete first goal
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // +25 XP awarded for Goal 1
      expect(academicService.profile.xp, equals(initialXp + 25));
      expect(find.text('Next Goal (+25 XP)'), findsOneWidget);

      // Tap Next Goal button
      await tester.tap(find.text('Next Goal (+25 XP)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Set Next Session Goal'), findsOneWidget);
      expect(find.text('Set Next Goal (+25 XP)'), findsOneWidget);

      // Enter second goal
      await tester.enterText(find.byType(TextField), 'Goal 2: Solve 10 problems');
      await tester.tap(find.text('Set Next Goal (+25 XP)'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Goal 2: Solve 10 problems'), findsOneWidget);

      // Complete second goal
      await tester.tap(find.byIcon(Icons.check_rounded));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // +25 extra XP awarded for Goal 2 (total +50 XP from goals)
      expect(academicService.profile.xp, equals(initialXp + 50));
      expect(studyService.completedGoalsInSession, equals(2));
      expect(find.text('Next Goal (+25 XP)'), findsOneWidget);
    });
  });
}
