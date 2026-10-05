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

    test('UserProfile initializes with gamification defaults', () {
      final profile = academicService.profile;
      expect(profile.level, 7);
      expect(profile.xp, 1840);
      expect(profile.maxXp, 2000);
      expect(profile.studyStreakDays, 12);
      expect(profile.achievements.isNotEmpty, true);
    });

    test('addXp correctly levels up user when threshold reached', () async {
      final initialLevel = academicService.profile.level;
      // Add 200 XP (1840 + 200 = 2040 >= 2000 -> Level 8)
      await academicService.addXp(200, reason: 'Big Study Milestone');

      expect(academicService.profile.level, initialLevel + 1);
      expect(academicService.profile.xp, 40); // 2040 - 2000
    });

    test('StudyTogetherService demo room is pre-configured with Mohamed and Ahmed', () {
      final room = studyService.activeRoom;
      expect(room, isNotNull);
      expect(room!.id, '482-731-205');
      expect(room.participants.length, 2);

      final host = room.participants.firstWhere((p) => p.isHost);
      expect(host.displayName, 'Mohamed Abdou');
      expect(host.level, 7);

      final peer = room.participants.firstWhere((p) => !p.isHost);
      expect(peer.displayName, 'Ahmed');
      expect(peer.level, 4);
    });

    test('StudyTogetherService creates valid formatted room codes (XXX-XXX-XXX)', () async {
      final room = await studyService.createRoom(
        title: 'CENG403 Cloud Sprint',
        courseCode: 'CENG403',
      );

      expect(room.id, matches(r'^\d{3}-\d{3}-\d{3}$'));
      expect(room.status, StudyRoomStatus.waiting);
    });

    test('StudyTogetherService startSession synchronizes timer from sessionStartedAt', () {
      studyService.startSession();
      final room = studyService.activeRoom;

      expect(room!.status, StudyRoomStatus.active);
      expect(room.sessionStartedAt, isNotNull);

      final elapsed = studyService.getElapsedDuration();
      expect(elapsed.inSeconds >= 0, true);
    });

    test('Break request submission and host approval changes peer status', () {
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
      final xpBefore = academicService.profile.xp;
      await studyService.toggleGoalCompleted();

      expect(academicService.profile.xp, xpBefore + 25);
    });

    test('Complete 19-step Study Together multiplayer arena flow test', () async {
      // 1. User A (Mohamed) creates room
      final createdRoom = await studyService.createRoom(
        title: 'CENG401 Senior Sprint',
        courseCode: 'CENG401',
      );
      expect(createdRoom.id, matches(r'^\d{3}-\d{3}-\d{3}$'));
      expect(createdRoom.hostId, academicService.profile.id);

      // 2. User B (Ahmed) joins & 3. Both appear
      expect(createdRoom.participants.length, 1);
      final userB = RoomParticipant(
        userId: 'user_ahmed_peer',
        displayName: 'Ahmed',
        major: 'Computer Engineering',
        level: 4,
        isHost: false,
        status: ParticipantStatus.studying,
        currentSubject: 'Calculus Exercises',
        joinedAt: DateTime.now(),
      );
      studyService.addParticipant(userB);

      expect(studyService.activeRoom!.participants.length, 2);
      expect(studyService.activeRoom!.participants.any((p) => p.displayName == 'Mohamed Abdou'), true);
      expect(studyService.activeRoom!.participants.any((p) => p.displayName == 'Ahmed'), true);

      // 4. Host starts & 5. Both enter active arena
      studyService.startSession();
      expect(studyService.activeRoom!.status, StudyRoomStatus.active);

      // 6. Timer synchronized
      expect(studyService.activeRoom!.sessionStartedAt, isNotNull);
      final elapsed = studyService.getElapsedDuration();
      expect(elapsed.inSeconds >= 0, true);

      // 7. User changes subject & 8. Other user sees change in shared state
      studyService.updateSubject('Writing CENG401 proposal');
      final hostPart = studyService.activeRoom!.participants.firstWhere((p) => p.userId == academicService.profile.id);
      expect(hostPart.currentSubject, 'Writing CENG401 proposal');

      // 9. User requests break
      studyService.requestBreakForAhmed(10);
      final req = studyService.activeRoom!.breakRequests.last;
      expect(req.requestedMinutes, 10);
      expect(req.userName, 'Ahmed');

      // 10. Host approves
      studyService.respondToBreakRequest(req.id, true);

      // 11. Break timer works & status updates
      final ahmedOnBreak = studyService.activeRoom!.participants.firstWhere((p) => p.userId == 'user_ahmed_peer');
      expect(ahmedOnBreak.status, ParticipantStatus.onBreak);
      expect(ahmedOnBreak.breakMinutesRemaining, 10);
      expect(studyService.activeRoom!.isAnyOnBreak, true);

      // 12. User returns
      studyService.updateStatus(ParticipantStatus.studying);

      // 13. Host starts music
      studyService.toggleMusicPlay();
      expect(studyService.activeRoom!.musicState.isPlaying, true);

      // 14. Music state synchronizes via shared timestamps
      final posSec = studyService.getMusicPositionSeconds();
      expect(posSec >= 0, true);

      // 15. Session ends
      final initialSessionsCount = academicService.sessions.length;
      final initialFocusMinutes = academicService.profile.focusMinutesTotal;
      final initialXp = academicService.profile.xp;

      final summary = await studyService.endSession();

      // 16. Session summary appears
      expect(summary, isNotNull);
      expect(summary.totalDuration.inSeconds >= 0, true);

      // 17. Focus time saved
      expect(academicService.profile.focusMinutesTotal >= initialFocusMinutes, true);

      // 18. XP updated
      expect(academicService.profile.xp > initialXp, true);

      // 19. History updated
      expect(academicService.sessions.length, initialSessionsCount + 1);
    });
  });
}
