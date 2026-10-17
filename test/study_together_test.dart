import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifocus/core/models/study_room.dart';
import 'package:unifocus/core/services/academic_service.dart';
import 'package:unifocus/core/services/storage_service.dart';
import 'package:unifocus/core/services/study_together_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Gamification & Study Together Tests', () {
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

    test('UserProfile initializes with clean user defaults (0 XP, Level 1, 0 streak)', () {
      final profile = academicService.profile;
      expect(profile.level, 1);
      expect(profile.xp, 0);
      expect(profile.studyStreakDays, 0);
      expect(profile.focusMinutesTotal, 0);
      expect(profile.displayGpa, 'GPA NOT SET');
    });

    test('New user starts with no active rooms', () {
      expect(studyService.activeRoom, isNull);
    });

    test('addXp correctly levels up user when progressive threshold reached', () async {
      final initialLevel = academicService.profile.level;
      expect(initialLevel, 1);

      // Add 100 XP (0 + 100 = 100 >= 100 -> Level 2)
      await academicService.addXp(100, reason: 'Initial Study Milestone', idempotencyKey: 'test_milestone_1');

      expect(academicService.profile.level, 2);
      expect(academicService.profile.xp, 100);
      expect(academicService.profile.maxXp, 250); // Level 3 threshold
    });

    test('StudyTogetherService creates valid formatted room codes (XXX-XXX-XXX)', () async {
      final room = await studyService.createRoom(
        title: 'Algorithms Sprint',
        courseCode: 'CS201',
      );

      expect(room.id, matches(r'^\d{3}-\d{3}-\d{3}$'));
      expect(room.status, StudyRoomStatus.waiting);
    });

    test('StudyTogetherService startSession synchronizes timer from sessionStartedAt', () async {
      await studyService.createRoom(
        title: 'Focus Arena',
        courseCode: 'MATH101',
      );
      studyService.startSession();
      final room = studyService.activeRoom;

      expect(room!.status, StudyRoomStatus.active);
      expect(room.sessionStartedAt, isNotNull);

      final elapsed = studyService.getElapsedDuration();
      expect(elapsed.inSeconds >= 0, true);
    });

    test('Break request submission and host approval changes peer status', () async {
      await studyService.createRoom(
        title: 'Study Arena',
        courseCode: 'PHYS101',
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
      studyService.requestBreakForAhmed(10);
      final roomBefore = studyService.activeRoom!;
      expect(roomBefore.breakRequests.isNotEmpty, true);

      final req = roomBefore.breakRequests.last;
      expect(req.userName, 'Ahmed');
      expect(req.requestedMinutes, 10);

      studyService.respondToBreakRequest(req.id, true);
      final roomAfter = studyService.activeRoom!;
      final ahmed = roomAfter.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');

      expect(ahmed.status, ParticipantStatus.onBreak);
      expect(ahmed.breakMinutesRemaining, 10);
    });

    test('toggleGoalCompleted awards +25 XP', () async {
      await studyService.createRoom(
        title: 'Goal Arena',
        courseCode: 'CS101',
      );
      final xpBefore = academicService.profile.xp;
      await studyService.toggleGoalCompleted();

      expect(academicService.profile.xp, xpBefore + 25);
    });

    test('Complete multiplayer arena lifecycle test', () async {
      // 1. User A creates room
      final createdRoom = await studyService.createRoom(
        title: 'Senior Project Sprint',
        courseCode: 'CS401',
      );
      expect(createdRoom.id, matches(r'^\d{3}-\d{3}-\d{3}$'));
      expect(createdRoom.hostId, academicService.profile.id);

      // 2. User B joins & both appear in shared state
      expect(createdRoom.participants.length, 1);
      final userB = RoomParticipant(
        userId: 'user_peer_alex',
        displayName: 'Alex',
        major: 'Computer Engineering',
        level: 3,
        isHost: false,
        status: ParticipantStatus.studying,
        currentSubject: 'Data Structures Problem Set',
        joinedAt: DateTime.now(),
      );
      studyService.addParticipant(userB);

      expect(studyService.activeRoom!.participants.length, 2);
      expect(studyService.activeRoom!.participants.any((p) => p.displayName == 'Alex'), true);

      // 3. Host starts & session enters active mode
      studyService.startSession();
      expect(studyService.activeRoom!.status, StudyRoomStatus.active);

      // 4. Timer synchronized via server timestamps
      expect(studyService.activeRoom!.sessionStartedAt, isNotNull);
      final elapsed = studyService.getElapsedDuration();
      expect(elapsed.inSeconds >= 0, true);

      // 5. User changes subject
      studyService.updateSubject('Writing system architecture');
      final hostPart = studyService.activeRoom!.participants.firstWhere((p) => p.userId == academicService.profile.id);
      expect(hostPart.currentSubject, 'Writing system architecture');

      // 6. User takes personal break
      studyService.updateStatus(ParticipantStatus.onBreak);
      final meOnBreak = studyService.activeRoom!.participants.firstWhere((p) => p.userId == academicService.profile.id);
      expect(meOnBreak.status, ParticipantStatus.onBreak);

      // 7. User returns
      studyService.updateStatus(ParticipantStatus.studying);

      // 8. Host starts music
      studyService.toggleMusicPlay();
      expect(studyService.activeRoom!.musicState.isPlaying, true);

      // 9. Session ends & awards persistent summary
      final initialSessionsCount = academicService.sessions.length;
      final initialXp = academicService.profile.xp;

      final summary = await studyService.endSession();

      expect(summary, isNotNull);
      expect(summary.totalDuration.inSeconds >= 0, true);
      expect(academicService.profile.xp > initialXp, true);
      expect(academicService.sessions.length, initialSessionsCount + 1);
    });

    test('Authoritative 3-2-1 countdown synchronization calculates deterministic values', () async {
      await studyService.createRoom(
        title: 'Countdown Arena',
        courseCode: 'CS301',
      );
      studyService.startSession();
      final room = studyService.activeRoom!;

      expect(room.status, StudyRoomStatus.active);
      expect(room.countdownStartedAt, isNotNull);
      expect(room.sessionStartedAt, isNotNull);

      final start = room.countdownStartedAt!;
      final end = room.sessionStartedAt!;
      expect(end.difference(start).inSeconds, 3);

      // Verify client calculation at various simulated arrival offsets
      int calcSeconds(DateTime simulatedNow) {
        final elapsed = simulatedNow.difference(start).inMilliseconds;
        return (3 - (elapsed ~/ 1000)).clamp(1, 3);
      }

      expect(calcSeconds(start), 3);
      expect(calcSeconds(start.add(const Duration(milliseconds: 500))), 3);
      expect(calcSeconds(start.add(const Duration(milliseconds: 1500))), 2);
      expect(calcSeconds(start.add(const Duration(milliseconds: 2500))), 1);
      expect(start.add(const Duration(milliseconds: 3000)).isBefore(end), false);
    });

    test('StudyRoom parses Firestore Timestamp objects and derives 3 -> 2 -> 1 -> START', () {
      final now = DateTime.utc(2026, 10, 5, 12, 0, 0);
      final rawJson = {
        'id': '123-456-789',
        'title': 'Sync Study Room',
        'courseCode': 'CS101',
        'hostId': 'host_user_1',
        'hostName': 'Host User',
        'status': 'active',
        'createdAt': _MockTimestamp(now),
        'countdownStartedAt': _MockTimestamp(now),
      };

      final room = StudyRoom.fromJson(rawJson);
      expect(room.createdAt, now);
      expect(room.countdownStartedAt, now);
      expect(room.sessionStartedAt, now.add(const Duration(seconds: 3)));

      // Test derivation of 3 -> 2 -> 1 -> START -> Active
      String deriveStep(DateTime simulatedNow) {
        final elapsedMs = simulatedNow.difference(room.countdownStartedAt!).inMilliseconds;
        if (elapsedMs >= 3800) return 'ACTIVE';
        if (elapsedMs < 1000) return '3';
        if (elapsedMs < 2000) return '2';
        if (elapsedMs < 3000) return '1';
        return 'START';
      }

      // Both clients derive identical values
      expect(deriveStep(now), '3');
      expect(deriveStep(now.add(const Duration(milliseconds: 800))), '3');
      expect(deriveStep(now.add(const Duration(milliseconds: 1000))), '2');
      expect(deriveStep(now.add(const Duration(milliseconds: 1900))), '2');
      expect(deriveStep(now.add(const Duration(milliseconds: 2000))), '1');
      expect(deriveStep(now.add(const Duration(milliseconds: 2900))), '1');
      expect(deriveStep(now.add(const Duration(milliseconds: 3000))), 'START');
      expect(deriveStep(now.add(const Duration(milliseconds: 3700))), 'START');
      expect(deriveStep(now.add(const Duration(milliseconds: 3800))), 'ACTIVE');
      expect(deriveStep(now.add(const Duration(milliseconds: 5000))), 'ACTIVE');
    });
  });
}

class _MockTimestamp {
  final DateTime _dateTime;
  _MockTimestamp(this._dateTime);
  DateTime toDate() => _dateTime;
}

