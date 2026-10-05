import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/study_room.dart';
import '../models/study_session.dart';
import 'academic_service.dart';

class SessionSummary {
  final Duration totalDuration;
  final Duration focusDuration;
  final Duration breakDuration;
  final bool isGoalCompleted;
  final String? goal;
  final int earnedXp;
  final int streakDays;

  const SessionSummary({
    required this.totalDuration,
    required this.focusDuration,
    required this.breakDuration,
    required this.isGoalCompleted,
    this.goal,
    required this.earnedXp,
    required this.streakDays,
  });
}

class StudyTogetherService extends ChangeNotifier {
  final AcademicService _academicService;

  StudyRoom? _activeRoom;
  bool _isLocalMuted = false;
  double _localVolume = 0.8;
  Timer? _tickerTimer;
  Timer? _peerSimTimer;

  static const List<Map<String, String>> availableTracks = [
    {
      'id': 'track_lofi_1',
      'title': 'Lo-fi Study Beats',
      'artist': 'UniFocus Chill',
    },
    {
      'id': 'track_lofi_2',
      'title': 'Midnight Library',
      'artist': 'Cozy Scholar',
    },
    {
      'id': 'track_lofi_3',
      'title': 'Rainy Coffee Shop',
      'artist': 'Acoustic Calm',
    },
  ];

  StudyTogetherService(this._academicService) {
    // Start local 1-second ticker to update listeners for UI clocks
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeRoom != null && _activeRoom!.status == StudyRoomStatus.active) {
        notifyListeners();
      }
    });

    // Initialize with default demo room available for immediate joining or hosting
    _initializeDemoRoom();
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _peerSimTimer?.cancel();
    super.dispose();
  }

  // Getters
  StudyRoom? get activeRoom => _activeRoom;
  bool get isInRoom => _activeRoom != null;
  bool get isLocalMuted => _isLocalMuted;
  double get localVolume => _localVolume;

  void _initializeDemoRoom() {
    // If not in a room, we keep the demo room ready
    if (_activeRoom == null) {
      _activeRoom = StudyRoom(
        id: '482-731-205',
        title: 'CENG401 Focus Session',
        courseCode: 'CENG401',
        hostId: 'user_mohamed_abdou',
        hostName: 'Mohamed Abdou',
        status: StudyRoomStatus.waiting,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        participants: [
          RoomParticipant(
            userId: 'user_mohamed_abdou',
            displayName: 'Mohamed Abdou',
            major: 'Computer Engineering',
            level: 7,
            isHost: true,
            status: ParticipantStatus.studying,
            currentSubject: 'Writing CENG401 proposal',
            personalGoal: 'Complete introduction & system architecture',
            joinedAt: DateTime.now().subtract(const Duration(minutes: 5)),
          ),
          RoomParticipant(
            userId: 'user_ahmed_peer',
            displayName: 'Ahmed',
            major: 'Computer Engineering',
            level: 4,
            isHost: false,
            status: ParticipantStatus.studying,
            currentSubject: 'Chapter 4 — Calculus & Review',
            joinedAt: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
        ],
      );
    }
  }

  // Generate a random room code like "482-731-205"
  String _generateRoomCode() {
    final rng = Random();
    final p1 = rng.nextInt(900) + 100;
    final p2 = rng.nextInt(900) + 100;
    final p3 = rng.nextInt(900) + 100;
    return '$p1-$p2-$p3';
  }

  // Create a new room
  Future<StudyRoom> createRoom({
    required String title,
    required String courseCode,
  }) async {
    final profile = _academicService.profile;
    final code = _generateRoomCode();

    final room = StudyRoom(
      id: code,
      title: title.isEmpty ? '$courseCode Study Session' : title,
      courseCode: courseCode,
      hostId: profile.id,
      hostName: profile.name,
      status: StudyRoomStatus.waiting,
      createdAt: DateTime.now(),
      participants: [
        RoomParticipant(
          userId: profile.id,
          displayName: profile.name,
          major: profile.department,
          level: profile.level,
          isHost: true,
          status: ParticipantStatus.studying,
          currentSubject: 'Studying $courseCode',
          joinedAt: DateTime.now(),
        ),
      ],
    );

    _activeRoom = room;
    notifyListeners();
    return room;
  }

  // Join existing room by code
  Future<bool> joinRoom(String rawCode) async {
    final cleanCode = rawCode.trim().replaceAll(' ', '');
    // In our prototype / demo, code 482-731-205 connects to the demo room
    if (cleanCode == '482-731-205' || cleanCode == '482731205' || (_activeRoom != null && _activeRoom!.id == cleanCode)) {
      if (_activeRoom == null || _activeRoom!.id != '482-731-205') {
        _initializeDemoRoom();
      }
      notifyListeners();
      return true;
    }

    // Generic matching
    if (_activeRoom != null && _activeRoom!.id.replaceAll('-', '') == cleanCode.replaceAll('-', '')) {
      return true;
    }

    return false;
  }

  // Add a participant to the active room
  void addParticipant(RoomParticipant participant) {
    if (_activeRoom == null) return;
    if (_activeRoom!.participants.any((p) => p.userId == participant.userId)) return;
    final updated = List<RoomParticipant>.from(_activeRoom!.participants)..add(participant);
    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }

  // Host starts the session
  void startSession() {
    if (_activeRoom == null) return;
    final now = DateTime.now();

    _activeRoom = _activeRoom!.copyWith(
      status: StudyRoomStatus.active,
      sessionStartedAt: now,
    );
    notifyListeners();

    // Spawn a simulated peer event in the demo scenario (Ahmed asks for break or updates subject)
    _startPeerSimulation();
  }

  void _startPeerSimulation() {
    _peerSimTimer?.cancel();
    // After 15 seconds, Ahmed sends a break request for demonstration
    _peerSimTimer = Timer(const Duration(seconds: 15), () {
      if (_activeRoom != null && _activeRoom!.status == StudyRoomStatus.active) {
        requestBreakForAhmed(10);
      }
    });
  }

  // Calculate synchronized elapsed duration
  Duration getElapsedDuration() {
    if (_activeRoom == null || _activeRoom!.sessionStartedAt == null) {
      return Duration.zero;
    }
    return DateTime.now().difference(_activeRoom!.sessionStartedAt!);
  }

  // Update current user's status
  void updateStatus(ParticipantStatus newStatus) {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(status: newStatus);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }

  // Update current user's study subject
  void updateSubject(String subject) {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(currentSubject: subject);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }

  // Set or update personal goal
  void setPersonalGoal(String goal) {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(personalGoal: goal, isGoalCompleted: false);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }

  // Toggle goal completed
  Future<void> toggleGoalCompleted() async {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        final nextState = !p.isGoalCompleted;
        return p.copyWith(isGoalCompleted: nextState);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    await _academicService.addXp(25, reason: 'Personal Study Goal Completed');
    notifyListeners();
  }

  // User requests a break
  void requestBreak(int minutes) {
    if (_activeRoom == null) return;
    final profile = _academicService.profile;

    final req = BreakRequest(
      id: 'req_${DateTime.now().millisecondsSinceEpoch}',
      userId: profile.id,
      userName: profile.name,
      requestedMinutes: minutes,
      createdAt: DateTime.now(),
    );

    final reqs = List<BreakRequest>.from(_activeRoom!.breakRequests)..add(req);
    _activeRoom = _activeRoom!.copyWith(breakRequests: reqs);
    notifyListeners();
  }

  // Ahmed simulator break request
  void requestBreakForAhmed(int minutes) {
    if (_activeRoom == null) return;
    final req = BreakRequest(
      id: 'req_ahmed_${DateTime.now().millisecondsSinceEpoch}',
      userId: 'user_ahmed_peer',
      userName: 'Ahmed',
      requestedMinutes: minutes,
      createdAt: DateTime.now(),
    );

    final reqs = List<BreakRequest>.from(_activeRoom!.breakRequests)..add(req);
    _activeRoom = _activeRoom!.copyWith(breakRequests: reqs);
    notifyListeners();
  }

  // Host approves or declines break request
  void respondToBreakRequest(String requestId, bool approve) {
    if (_activeRoom == null) return;

    final reqIndex = _activeRoom!.breakRequests.indexWhere((r) => r.id == requestId);
    if (reqIndex == -1) return;

    final req = _activeRoom!.breakRequests[reqIndex];
    final updatedReq = req.copyWith(isApproved: approve);

    final updatedReqs = List<BreakRequest>.from(_activeRoom!.breakRequests)
      ..[reqIndex] = updatedReq;

    // If approved, update that participant's status to onBreak
    List<RoomParticipant> updatedParts = _activeRoom!.participants;
    if (approve) {
      updatedParts = _activeRoom!.participants.map((p) {
        if (p.userId == req.userId) {
          return p.copyWith(
            status: ParticipantStatus.onBreak,
            breakMinutesRemaining: req.requestedMinutes,
          );
        }
        return p;
      }).toList();
    }

    _activeRoom = _activeRoom!.copyWith(
      breakRequests: updatedReqs,
      participants: updatedParts,
    );
    notifyListeners();
  }

  // --- Music Synchronization ---
  void toggleMusicPlay() {
    if (_activeRoom == null) return;
    final cur = _activeRoom!.musicState;
    final nextPlay = !cur.isPlaying;

    final nextMusic = cur.copyWith(
      isPlaying: nextPlay,
      startedAt: nextPlay ? DateTime.now() : null,
    );

    _activeRoom = _activeRoom!.copyWith(musicState: nextMusic);
    notifyListeners();
  }

  void nextTrack() {
    if (_activeRoom == null) return;
    final cur = _activeRoom!.musicState;
    final curIdx = availableTracks.indexWhere((t) => t['id'] == cur.trackId);
    final nextIdx = (curIdx + 1) % availableTracks.length;
    final track = availableTracks[nextIdx];

    final nextMusic = cur.copyWith(
      trackId: track['id']!,
      trackTitle: track['title']!,
      artist: track['artist']!,
      isPlaying: true,
      startedAt: DateTime.now(),
    );

    _activeRoom = _activeRoom!.copyWith(musicState: nextMusic);
    notifyListeners();
  }

  int getMusicPositionSeconds() {
    if (_activeRoom == null || !_activeRoom!.musicState.isPlaying || _activeRoom!.musicState.startedAt == null) {
      return 151; // 02:31 default
    }
    final elapsed = DateTime.now().difference(_activeRoom!.musicState.startedAt!).inSeconds;
    return (151 + elapsed) % _activeRoom!.musicState.totalDurationSeconds;
  }

  void toggleLocalMute() {
    _isLocalMuted = !_isLocalMuted;
    notifyListeners();
  }

  void setLocalVolume(double vol) {
    _localVolume = vol.clamp(0.0, 1.0);
    notifyListeners();
  }

  // End session and produce summary
  Future<SessionSummary> endSession() async {
    final now = DateTime.now();
    final elapsed = getElapsedDuration();
    final focusMinutes = (elapsed.inSeconds / 60).ceil().clamp(1, 480);

    // Calculate XP reward: +40 base + focus minutes + goal bonus
    final myId = _academicService.profile.id;
    final me = _activeRoom?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => _activeRoom!.participants.first,
    );

    int earnedXp = 50 + (focusMinutes * 2);
    if (me != null && me.isGoalCompleted) {
      earnedXp += 25;
    }

    // Save study session to personal academic stats
    final studySession = StudySession(
      id: 'together_${now.millisecondsSinceEpoch}',
      courseId: _activeRoom?.courseCode ?? 'CENG401',
      courseCode: _activeRoom?.courseCode ?? 'CENG401',
      taskTitle: _activeRoom?.title ?? 'Study Together Session',
      durationMinutes: focusMinutes,
      timestamp: now,
      completed: true,
    );

    await _academicService.recordStudySessionAndReward(studySession, earnedXp: earnedXp);

    final summary = SessionSummary(
      totalDuration: elapsed,
      focusDuration: elapsed,
      breakDuration: const Duration(minutes: 10),
      isGoalCompleted: me?.isGoalCompleted ?? false,
      goal: me?.personalGoal,
      earnedXp: earnedXp,
      streakDays: _academicService.profile.studyStreakDays,
    );

    _activeRoom = _activeRoom?.copyWith(
      status: StudyRoomStatus.ended,
      sessionEndedAt: now,
    );
    notifyListeners();

    return summary;
  }

  void leaveRoom() {
    _peerSimTimer?.cancel();
    _activeRoom = null;
    notifyListeners();
  }
}
