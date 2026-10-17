import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/core/services/study_together_service.dart';
import 'package:unifocus/features/study_together/isometric_room/group_break_lounge_view.dart';
import 'package:unifocus/features/study_together/isometric_room/group_break_voting_banner.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Group Break & Resume Synchronization Tests', () {
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

    testWidgets('1 & 2: A participant can request a group break, and peers see it in real time', (tester) async {
      await studyService.createRoom(
        title: 'Algorithms Group Study',
        courseCode: 'CS301',
      );
      // Add peer Ahmed
      studyService.addParticipant(
        RoomParticipant(
          userId: 'user_ahmed_peer',
          displayName: 'Ahmed',
          major: 'CS',
          level: 3,
          currentSubject: 'CS301',
          joinedAt: DateTime.now(),
        ),
      );

      studyService.startSession();
      expect(studyService.activeRoom!.status, StudyRoomStatus.active);

      // Ahmed requests group break
      studyService.requestGroupBreakForAhmed(5);

      final requestedRoom = studyService.activeRoom!;
      expect(requestedRoom.status, StudyRoomStatus.groupBreakRequested);
      expect(requestedRoom.activeGroupBreak, isNotNull);
      expect(requestedRoom.activeGroupBreak!.requesterId, 'user_ahmed_peer');
      expect(requestedRoom.activeGroupBreak!.requesterName, 'Ahmed');
      expect(requestedRoom.activeGroupBreak!.breakMinutes, 5);
      expect(requestedRoom.activeGroupBreak!.acceptCount, 1);

      // Verify GroupBreakVotingBanner renders for Mohamed (User A)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakVotingBanner(
              proposal: requestedRoom.activeGroupBreak!,
              totalParticipants: requestedRoom.participants.length,
              currentUserId: academicService.profile.id,
              onVote: (accept) => studyService.voteGroupBreak(accept: accept),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ahmed requested a group break'), findsOneWidget);
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
      expect(find.text('1 / 2 accepted · 5 min break'), findsOneWidget);
    });

    testWidgets('3: Once group break is accepted by majority, all participants transition to the lounge together', (tester) async {
      await studyService.createRoom(
        title: 'Database Architecture',
        courseCode: 'CS401',
      );
      studyService.addParticipant(
        RoomParticipant(
          userId: 'user_ahmed_peer',
          displayName: 'Ahmed',
          major: 'CS',
          level: 3,
          currentSubject: 'CS401',
          joinedAt: DateTime.now(),
        ),
      );
      studyService.startSession();

      // Propose break
      studyService.requestGroupBreak(minutes: 5);
      expect(studyService.activeRoom!.status, StudyRoomStatus.groupBreakRequested);

      // Host votes accept (already 1 vote from requester)
      // Ahmed votes accept -> 2 / 2 votes
      studyService.simulateAhmedVote(true);

      final breakRoom = studyService.activeRoom!;
      expect(breakRoom.status, StudyRoomStatus.breakMode);
      expect(breakRoom.isGroupBreakActive, isTrue);
      expect(breakRoom.breakStartedAt, isNotNull);
      expect(breakRoom.breakEndsAt, isNotNull);
      expect(breakRoom.readyToResumeUserIds, isEmpty);

      // Verify GroupBreakLoungeView renders
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: breakRoom,
              studyService: studyService,
              academicService: academicService,
              currentUserId: academicService.profile.id,
              isHost: true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('GROUP BREAK IN PROGRESS'), findsOneWidget);
      expect(find.text('READY TO RESUME STUDY'), findsOneWidget);
    });

    testWidgets('4 & 5: If one participant presses Resume, peers see readiness without silent instant resume', (tester) async {
      await studyService.createRoom(
        title: 'Operating Systems Focus',
        courseCode: 'CS330',
      );
      studyService.addParticipant(
        RoomParticipant(
          userId: 'user_ahmed_peer',
          displayName: 'Ahmed',
          major: 'CS',
          level: 3,
          currentSubject: 'CS330',
          joinedAt: DateTime.now(),
        ),
      );
      studyService.startSession();

      // Enter break mode
      studyService.requestGroupBreak(minutes: 5);
      studyService.simulateAhmedVote(true);
      expect(studyService.activeRoom!.status, StudyRoomStatus.breakMode);

      // User A (Mohamed) presses Resume
      studyService.setReadyToResume(true);

      final roomWithOneReady = studyService.activeRoom!;
      // Requirement 5: Do NOT silently resume everyone when one person presses Resume
      expect(roomWithOneReady.status, StudyRoomStatus.breakMode);
      expect(roomWithOneReady.isGroupBreakActive, isTrue);
      // Requirement 4: Peers immediately see readiness
      expect(roomWithOneReady.readyToResumeUserIds, contains(academicService.profile.id));
      expect(roomWithOneReady.readyToResumeUserIds.length, 1);

      // Verify Lounge view updates to show 1 of 2 students ready to resume
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GroupBreakLoungeView(
              room: roomWithOneReady,
              studyService: studyService,
              academicService: academicService,
              currentUserId: 'user_ahmed_peer', // Rendered for Ahmed
              isHost: false,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Ahmed sees Mohamed is ready!
      expect(find.textContaining('1 of 2 students ready to resume'), findsOneWidget);
      expect(find.text('READY TO RESUME (1/2 READY)'), findsOneWidget);
    });

    testWidgets('6: When all participants press Resume, they transition to active room together', (tester) async {
      await studyService.createRoom(
        title: 'Compiler Construction',
        courseCode: 'CS450',
      );
      studyService.addParticipant(
        RoomParticipant(
          userId: 'user_ahmed_peer',
          displayName: 'Ahmed',
          major: 'CS',
          level: 4,
          currentSubject: 'CS450',
          joinedAt: DateTime.now(),
        ),
      );
      studyService.startSession();

      // Enter break mode
      studyService.requestGroupBreak(minutes: 5);
      studyService.simulateAhmedVote(true);
      expect(studyService.activeRoom!.status, StudyRoomStatus.breakMode);

      // Participant 1 presses Resume
      studyService.setReadyToResume(true);
      expect(studyService.activeRoom!.status, StudyRoomStatus.breakMode);
      expect(studyService.activeRoom!.readyToResumeUserIds.length, 1);

      // Participant 2 (Ahmed) presses Resume
      studyService.simulateAhmedResume(true);

      // All participants are ready -> Transitions back to active study room together
      final resumedRoom = studyService.activeRoom!;
      expect(resumedRoom.status, StudyRoomStatus.active);
      expect(resumedRoom.isGroupBreakActive, isFalse);
      expect(resumedRoom.readyToResumeUserIds, isEmpty);
    });

    test('7: Solo participant pressing resume immediately resumes', () async {
      await studyService.createRoom(
        title: 'Solo Deep Work',
        courseCode: 'CS101',
      );
      studyService.startSession();

      studyService.requestGroupBreak(minutes: 5);
      expect(studyService.activeRoom!.status, StudyRoomStatus.breakMode);

      // Solo user presses resume
      studyService.toggleReadyToResume();
      expect(studyService.activeRoom!.status, StudyRoomStatus.active);
      expect(studyService.activeRoom!.isGroupBreakActive, isFalse);
    });

    test('8: StudyRoom model serializes and deserializes readyToResumeUserIds correctly', () {
      final room = StudyRoom(
        id: '123-456-789',
        title: 'Test Room',
        courseCode: 'CS101',
        hostId: 'host_1',
        hostName: 'Host User',
        status: StudyRoomStatus.breakMode,
        createdAt: DateTime.now(),
        readyToResumeUserIds: const ['user_1', 'user_2'],
      );

      final json = room.toJson();
      expect(json['readyToResumeUserIds'], equals(['user_1', 'user_2']));

      final deserialized = StudyRoom.fromJson(json);
      expect(deserialized.readyToResumeUserIds, equals(['user_1', 'user_2']));
    });
  });
}
