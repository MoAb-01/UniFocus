import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/study_room.dart';
import '../models/study_session.dart';
import 'academic_service.dart';
import 'firestore_room_repository.dart';
import 'livekit_voice_service.dart';
import 'room_audio_player_service.dart';
import '../../features/study_together/mini_games/mini_game_questions.dart';

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
  final RoomAudioPlayerService audioPlayer;
  final FirestoreRoomRepository _roomRepository;
  final LiveKitVoiceService liveKitVoice;

  StudyRoom? _activeRoom;
  int _completedGoalsInSession = 0;
  bool _isLocalMuted = false;
  double _localVolume = 0.8;
  Timer? _tickerTimer;
  Timer? _peerSimTimer;
  Timer? _groupBreakVoteTimer;
  Timer? _miniGameCountdownTimer;
  Timer? _miniGameAutoAdvanceTimer;

  StreamSubscription<StudyRoom?>? _roomSubscription;
  StreamSubscription<List<RoomParticipant>>? _membersSubscription;
  VoidCallback? _voiceListener;

  static const List<Map<String, String>> availableTracks = [
    {
      'id': 'track_ambient_study',
      'title': 'Ambient Study Harmonic Flow',
      'artist': 'UniFocus Royalty-Free Lo-Fi',
      'url': 'asset://assets/audio/ambient_study.wav',
      'duration': '360',
    },
    {
      'id': 'track_midnight_focus',
      'title': 'Midnight Library Calm & Focus',
      'artist': 'UniFocus Royalty-Free Lo-Fi',
      'url': 'asset://assets/audio/midnight_focus.wav',
      'duration': '360',
    },
    {
      'id': 'track_deep_piano',
      'title': 'Deep Study Piano & Synth',
      'artist': 'UniFocus Royalty-Free Lo-Fi',
      'url': 'asset://assets/audio/deep_piano.wav',
      'duration': '360',
    },
  ];

  StudyTogetherService(
    this._academicService, {
    RoomAudioPlayerService? audioPlayerService,
    FirestoreRoomRepository? roomRepository,
    LiveKitVoiceService? liveKitVoiceService,
  })  : audioPlayer = audioPlayerService ?? RoomAudioPlayerService(),
        _roomRepository = roomRepository ?? FirestoreRoomRepository(),
        liveKitVoice = liveKitVoiceService ?? LiveKitVoiceService() {
    // Start local 1-second ticker to update UI clocks and countdowns
    // (Never writes to Firestore every second; uses timestamps)
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_activeRoom == null) return;

      if (_activeRoom!.status == StudyRoomStatus.active) {
        notifyListeners();
      } else if (_activeRoom!.status == StudyRoomStatus.breakMode) {
        notifyListeners();
        // Check if group break timer has expired locally
        if (_activeRoom!.breakEndsAt != null &&
            DateTime.now().isAfter(_activeRoom!.breakEndsAt!)) {
          endGroupBreak();
        }
        // Synchronized mini-game timer progression
        final miniGame = _activeRoom!.activeMiniGame;
        if (miniGame != null) {
          final now = DateTime.now();
          if (miniGame.status == MiniGameStatus.countdown && now.isAfter(miniGame.countdownEndsAt)) {
            startRoundFromCountdown();
          } else if (miniGame.status == MiniGameStatus.inRound && now.isAfter(miniGame.roundEndsAt)) {
            revealMiniGameRound();
          } else if (miniGame.status == MiniGameStatus.roundReview && now.isAfter(miniGame.roundEndsAt)) {
            advanceMiniGameRound();
          }
        }
      }
    });

    // Listen to LiveKit voice state changes (e.g. active speaker updates)
    _voiceListener = () {
      if (_activeRoom != null && _activeRoom!.status == StudyRoomStatus.breakMode) {
        _syncLiveSpeakingState();
      }
    };
    liveKitVoice.addListener(_voiceListener!);
  }

  @override
  void dispose() {
    _tickerTimer?.cancel();
    _peerSimTimer?.cancel();
    _groupBreakVoteTimer?.cancel();
    _miniGameCountdownTimer?.cancel();
    _miniGameAutoAdvanceTimer?.cancel();
    _roomSubscription?.cancel();
    _membersSubscription?.cancel();
    if (_voiceListener != null) {
      liveKitVoice.removeListener(_voiceListener!);
    }
    audioPlayer.dispose();
    liveKitVoice.dispose();
    super.dispose();
  }

  // Getters
  StudyRoom? get activeRoom => _activeRoom;
  bool get isInRoom => _activeRoom != null;
  int get completedGoalsInSession => _completedGoalsInSession;
  bool get isLocalMuted => _isLocalMuted;
  double get localVolume => _localVolume;

  // Generate a random room code like "123-456-789"
  String _generateRoomCode() => _roomRepository.generateRoomCode();

  // Create a new real room in Cloud Firestore
  Future<StudyRoom> createRoom({
    required String title,
    required String courseCode,
  }) async {
    final profile = _academicService.profile;
    final code = _generateRoomCode();

    StudyRoom? remoteRoom;
    try {
      remoteRoom = await _roomRepository.createRoom(
        roomId: code,
        title: title,
        courseCode: courseCode,
        hostId: profile.id,
        hostName: profile.name,
        hostMajor: profile.department,
        hostLevel: profile.level,
      );
    } catch (e) {
      debugPrint('[StudyTogetherService] createRoom remote fallback: $e');
    }

    final room = remoteRoom ??
        StudyRoom(
          id: code,
          title: title.isEmpty ? '$courseCode Focus Session' : title,
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
    _subscribeToRoom(code);
    notifyListeners();
    return room;
  }

  // Join existing room by code
  Future<bool> joinRoom(String rawCode) async {
    final cleanCode = rawCode.trim().replaceAll(' ', '');
    final profile = _academicService.profile;

    final myParticipant = RoomParticipant(
      userId: profile.id,
      displayName: profile.name,
      major: profile.department,
      level: profile.level,
      isHost: false,
      status: ParticipantStatus.studying,
      currentSubject: 'Studying with peers',
      joinedAt: DateTime.now(),
    );

    // Try joining via Firestore repository
    try {
      final joined = await _roomRepository.joinRoom(
        roomId: cleanCode,
        participant: myParticipant,
      );
      if (joined) {
        _subscribeToRoom(cleanCode);
        return true;
      }
    } catch (e) {
      debugPrint('[StudyTogetherService] joinRoom firestore fallback: $e');
    }

    // Local / in-memory matching (for tests and offline mode)
    if (_activeRoom != null &&
        _activeRoom!.id.replaceAll('-', '') == cleanCode.replaceAll('-', '')) {
      addParticipant(myParticipant);
      return true;
    }

    return false;
  }

  void _subscribeToRoom(String roomId) {
    _roomSubscription?.cancel();
    _membersSubscription?.cancel();

    _roomSubscription = _roomRepository.streamRoom(roomId).listen((roomUpdate) {
      if (roomUpdate != null) {
        if (roomUpdate.status == StudyRoomStatus.ended) {
          _handleRoomEndedByHost();
          return;
        }

        // LiveKit Break Voice Room Lifecycle
        if (_activeRoom?.status != StudyRoomStatus.breakMode &&
            roomUpdate.status == StudyRoomStatus.breakMode) {
          liveKitVoice.joinBreakVoiceRoom(
            roomId: roomId,
            userId: _academicService.profile.id,
            displayName: _academicService.profile.name,
          );
        } else if (_activeRoom?.status == StudyRoomStatus.breakMode &&
            roomUpdate.status != StudyRoomStatus.breakMode) {
          liveKitVoice.leaveVoiceRoom();
        }

        // Synchronize music with backend
        _handleSynchronizedMusicUpdate(roomUpdate.musicState);

        final currentParts = _activeRoom?.participants ?? roomUpdate.participants;
        _activeRoom = roomUpdate.copyWith(participants: currentParts);
        notifyListeners();
      }
    });

    _membersSubscription = _roomRepository.streamMembers(roomId).listen((members) {
      if (_activeRoom != null && members.isNotEmpty) {
        _activeRoom = _activeRoom!.copyWith(participants: members);
        notifyListeners();
      }
    });
  }

  void _handleRoomEndedByHost() {
    liveKitVoice.leaveVoiceRoom();
    audioPlayer.stop();
    _activeRoom = _activeRoom?.copyWith(status: StudyRoomStatus.ended);
    notifyListeners();
  }

  void _handleSynchronizedMusicUpdate(RoomMusicState remoteMusic) {
    if (_activeRoom == null) return;
    if (_activeRoom!.musicState.trackId != remoteMusic.trackId ||
        _activeRoom!.musicState.isPlaying != remoteMusic.isPlaying ||
        (_activeRoom!.musicState.startedAt != remoteMusic.startedAt && remoteMusic.isPlaying)) {
      audioPlayer.syncWithRoomMusic(
        musicState: remoteMusic,
        isLocalMuted: _isLocalMuted,
        localVolume: _localVolume,
      );
    }
  }

  void _syncLiveSpeakingState() {
    if (_activeRoom == null) return;
    final speakingIds = liveKitVoice.activeSpeakingUserIds;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      final isNowSpeaking = speakingIds.contains(p.userId);
      final isMicMuted = p.userId == myId ? liveKitVoice.isMicMuted : p.isMicMuted;
      if (p.isSpeaking != isNowSpeaking || p.isMicMuted != isMicMuted) {
        return p.copyWith(
          isSpeaking: isNowSpeaking,
          isMicMuted: isMicMuted,
        );
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
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
    final sessionStart = now.add(const Duration(seconds: 3));

    if (_roomRepository.isAvailable) {
      _roomRepository.startSession(_activeRoom!.id);
    } else {
      _activeRoom = _activeRoom!.copyWith(
        status: StudyRoomStatus.active,
        countdownStartedAt: now,
        sessionStartedAt: sessionStart,
      );
      notifyListeners();
    }
  }

  // Calculate synchronized elapsed duration
  Duration getElapsedDuration() {
    if (_activeRoom == null || _activeRoom!.sessionStartedAt == null) {
      return Duration.zero;
    }
    final diff = DateTime.now().difference(_activeRoom!.sessionStartedAt!);
    return diff.isNegative ? Duration.zero : diff;
  }

  // Update current user's status
  void updateStatus(ParticipantStatus newStatus) {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(
          status: newStatus,
          breakMinutesRemaining: newStatus == ParticipantStatus.onBreak ? (p.breakMinutesRemaining ?? 10) : null,
        );
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();

    _roomRepository.updateMemberStatus(_activeRoom!.id, myId, newStatus);
  }

  // Take a personal break (triggers 2.5D walking-to-door physical exit)
  void startPersonalBreak({int minutes = 10}) {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(
          status: ParticipantStatus.onBreak,
          breakMinutesRemaining: minutes,
        );
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();

    _roomRepository.updateMemberStatus(
      _activeRoom!.id,
      myId,
      ParticipantStatus.onBreak,
      breakMinutesRemaining: minutes,
    );
  }

  // Return from personal break to desk
  void returnFromPersonalBreak() {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        return p.copyWith(
          status: ParticipantStatus.studying,
          breakMinutesRemaining: null,
        );
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();

    _roomRepository.updateMemberStatus(
      _activeRoom!.id,
      myId,
      ParticipantStatus.studying,
      breakMinutesRemaining: null,
    );
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

    _roomRepository.updateMemberStatus(
      _activeRoom!.id,
      myId,
      ParticipantStatus.studying,
      currentSubject: subject,
    );
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

    _roomRepository.updateMemberStatus(
      _activeRoom!.id,
      myId,
      ParticipantStatus.studying,
      personalGoal: goal,
    );
  }

  // Toggle goal completed
  Future<void> toggleGoalCompleted() async {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;

    bool newlyCompleted = false;
    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == myId) {
        final nextState = !p.isGoalCompleted;
        if (nextState) newlyCompleted = true;
        return p.copyWith(isGoalCompleted: nextState);
      }
      return p;
    }).toList();

    _activeRoom = _activeRoom!.copyWith(participants: updated);
    if (newlyCompleted) {
      _completedGoalsInSession++;
      await _academicService.addXp(25, reason: 'Personal Study Goal Completed');
    }
    notifyListeners();
  }

  // --- Group Break System (Multiplayer Room-Wide Pause) ---
  void requestGroupBreak({int minutes = 5, String? requesterId, String? requesterName}) {
    if (_activeRoom == null) return;
    final profile = _academicService.profile;
    final rId = requesterId ?? profile.id;
    final rName = requesterName ?? profile.name;

    final proposal = GroupBreakProposal(
      id: 'grp_brk_${DateTime.now().millisecondsSinceEpoch}',
      requesterId: rId,
      requesterName: rName,
      breakMinutes: minutes,
      votes: {rId: true}, // Requester votes accept
      createdAt: DateTime.now(),
    );

    final legacyReq = BreakRequest(
      id: proposal.id,
      userId: rId,
      userName: rName,
      requestedMinutes: minutes,
      isApproved: null,
      createdAt: DateTime.now(),
    );
    final updatedBreakRequests = [..._activeRoom!.breakRequests, legacyReq];

    if (proposal.isApproved(_activeRoom!.participants.length)) {
      _activeRoom = _activeRoom!.copyWith(breakRequests: updatedBreakRequests);
      _startGroupBreak(minutes: minutes, proposal: proposal);
      if (_roomRepository.isAvailable) {
        _roomRepository.startGroupBreakImmediately(
          roomId: _activeRoom!.id,
          proposal: proposal,
        );
      }
      return;
    }

    _activeRoom = _activeRoom!.copyWith(
      status: StudyRoomStatus.groupBreakRequested,
      activeGroupBreak: proposal,
      breakRequests: updatedBreakRequests,
    );
    notifyListeners();

    _roomRepository.proposeGroupBreak(_activeRoom!.id, proposal);
  }

  void voteGroupBreak({required bool accept, String? voterId}) {
    if (_activeRoom == null || _activeRoom!.activeGroupBreak == null) return;
    final vId = voterId ?? _academicService.profile.id;

    final currentProposal = _activeRoom!.activeGroupBreak!;
    final isRequester = currentProposal.requesterId == vId ||
        (currentProposal.requesterName.isNotEmpty &&
            currentProposal.requesterName.trim().toLowerCase() ==
                _academicService.profile.name.trim().toLowerCase());

    if (isRequester && accept) {
      debugPrint('[voteGroupBreak] Requester accept vote is already permanently registered.');
      return;
    }

    if (currentProposal.votes[vId] == accept) {
      debugPrint('[voteGroupBreak] User $vId already cast vote $accept.');
      return;
    }

    final updatedVotes = Map<String, bool>.from(currentProposal.votes)..[vId] = accept;
    final updatedProposal = currentProposal.copyWith(votes: updatedVotes);
    final totalParticipants = _activeRoom!.participants.length;

    _roomRepository.recordBreakVote(
      roomId: _activeRoom!.id,
      proposal: currentProposal,
      voterId: vId,
      accept: accept,
      totalParticipants: totalParticipants,
    );

    if (updatedProposal.isApproved(totalParticipants)) {
      _startGroupBreak(
        minutes: updatedProposal.breakMinutes,
        proposal: updatedProposal,
      );
    } else if (updatedProposal.isDeclined(totalParticipants)) {
      _activeRoom = _activeRoom!.copyWith(
        status: StudyRoomStatus.active,
        clearActiveGroupBreak: true,
      );
      notifyListeners();
    } else {
      _activeRoom = _activeRoom!.copyWith(
        activeGroupBreak: updatedProposal,
      );
      notifyListeners();
    }
  }

  void _startGroupBreak({
    required int minutes,
    required GroupBreakProposal proposal,
  }) {
    final now = DateTime.now();
    final endsAt = now.add(Duration(minutes: minutes));

    final updatedParticipants = _activeRoom!.participants.map((p) {
      return p.copyWith(
        status: ParticipantStatus.onBreak,
        breakMinutesRemaining: minutes,
      );
    }).toList();

    _activeRoom = _activeRoom!.copyWith(
      status: StudyRoomStatus.breakMode,
      participants: updatedParticipants,
      activeGroupBreak: proposal,
      clearReadyToResumeUserIds: true,
      breakStartedAt: now,
      breakEndsAt: endsAt,
      breakDurationMinutes: minutes,
    );
    notifyListeners();

    // Join LiveKit break voice room
    liveKitVoice.joinBreakVoiceRoom(
      roomId: _activeRoom!.id,
      userId: _academicService.profile.id,
      displayName: _academicService.profile.name,
    );
  }

  void endGroupBreak() {
    if (_activeRoom == null) return;

    final updatedParticipants = _activeRoom!.participants.map((p) {
      return p.copyWith(
        status: ParticipantStatus.studying,
        breakMinutesRemaining: 0,
      );
    }).toList();

    _activeRoom = _activeRoom!.copyWith(
      status: StudyRoomStatus.active,
      participants: updatedParticipants,
      clearActiveGroupBreak: true,
      clearReadyToResumeUserIds: true,
      breakStartedAt: null,
      breakEndsAt: null,
    );
    notifyListeners();

    // Disconnect LiveKit break voice room
    liveKitVoice.leaveVoiceRoom();

    _roomRepository.endGroupBreak(_activeRoom!.id);
  }

  // Synchronized Resume Readiness
  void toggleReadyToResume() {
    if (_activeRoom == null) return;
    final myId = _academicService.profile.id;
    final isCurrentlyReady = _activeRoom!.readyToResumeUserIds.contains(myId);
    setReadyToResume(!isCurrentlyReady);
  }

  void setReadyToResume(bool isReady, {String? userId}) {
    if (_activeRoom == null) return;
    final uId = userId ?? _academicService.profile.id;
    final currentReady = List<String>.from(_activeRoom!.readyToResumeUserIds);

    if (isReady) {
      if (!currentReady.contains(uId)) {
        currentReady.add(uId);
      }
    } else {
      currentReady.remove(uId);
    }

    final total = _activeRoom!.participants.length;

    // Check if everyone is ready
    if (total > 0 && currentReady.length >= total) {
      _activeRoom = _activeRoom!.copyWith(
        readyToResumeUserIds: currentReady,
      );
      notifyListeners();
      endGroupBreak();
      return;
    } else {
      _activeRoom = _activeRoom!.copyWith(
        readyToResumeUserIds: currentReady,
      );
      notifyListeners();
    }

    if (_roomRepository.isAvailable) {
      _roomRepository.setReadyToResume(
        roomId: _activeRoom!.id,
        userId: uId,
        isReady: isReady,
        totalParticipants: total,
      );
    }
  }

  void requestGroupBreakForAhmed(int minutes) {
    requestGroupBreak(
      minutes: minutes,
      requesterId: 'user_ahmed_peer',
      requesterName: 'Ahmed',
    );
  }

  void requestBreakForAhmed(int minutes) => requestGroupBreakForAhmed(minutes);
  void requestBreak(int minutes) => requestGroupBreak(minutes: minutes);

  void respondToBreakRequest(String requestId, bool approve) {
    if (_activeRoom != null) {
      final updatedReqs = _activeRoom!.breakRequests.map((r) {
        if (r.id == requestId) {
          return r.copyWith(isApproved: approve);
        }
        return r;
      }).toList();
      _activeRoom = _activeRoom!.copyWith(breakRequests: updatedReqs);
    }
    voteGroupBreak(accept: approve);
  }

  // --- Voice Layer ---
  void updateParticipantVoice({
    required String userId,
    required bool isMicMuted,
    required bool isSpeaking,
  }) {
    if (_activeRoom == null) return;
    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == userId) {
        return p.copyWith(
          isMicMuted: isMicMuted,
          isSpeaking: isSpeaking,
        );
      }
      return p;
    }).toList();
    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();

    _roomRepository.updateMemberAudio(
      _activeRoom!.id,
      userId,
      isMicMuted: isMicMuted,
      isSpeaking: isSpeaking,
    );
  }

  Future<void> toggleLocalMic({String? userId}) async {
    if (_activeRoom == null) return;
    final myId = userId ?? _academicService.profile.id;
    final me = _activeRoom!.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => _activeRoom!.participants.first,
    );
    final nextMuted = !me.isMicMuted;

    // If lounge voice is not connected yet, connect first
    if (!liveKitVoice.isConnected && !nextMuted) {
      final connected = await liveKitVoice.joinBreakVoiceRoom(
        roomId: _activeRoom!.id,
        userId: myId,
        displayName: me.displayName,
      );
      if (!connected) return;
    }

    final success = await liveKitVoice.setMicrophoneEnabled(!nextMuted);
    // If enabling mic failed (e.g. permission denied), keep muted
    final effectiveMuted = (!nextMuted && !success) ? true : nextMuted;

    updateParticipantVoice(
      userId: myId,
      isMicMuted: effectiveMuted,
      isSpeaking: effectiveMuted ? false : me.isSpeaking,
    );
  }

  void setLocalSpeaking(bool isSpeaking, {String? userId}) {
    if (_activeRoom == null) return;
    final myId = userId ?? _academicService.profile.id;
    final me = _activeRoom!.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => _activeRoom!.participants.first,
    );
    if (me.isMicMuted && isSpeaking) return;
    updateParticipantVoice(
      userId: myId,
      isMicMuted: me.isMicMuted,
      isSpeaking: isSpeaking,
    );
  }

  // Unit Test / Acceptance Helpers
  void simulateAhmedVote(bool accept) => voteGroupBreak(accept: accept, voterId: 'user_ahmed_peer');
  void simulateAhmedResume(bool isReady) => setReadyToResume(isReady, userId: 'user_ahmed_peer');
  void simulateAhmedMic(bool unmuted) => updateParticipantVoice(userId: 'user_ahmed_peer', isMicMuted: !unmuted, isSpeaking: false);
  void simulateAhmedSpeaking(bool speaking) => updateParticipantVoice(userId: 'user_ahmed_peer', isMicMuted: !speaking, isSpeaking: speaking);
  void simulateAhmedPersonalBreak(bool startBreak) {
    if (_activeRoom == null) return;
    final updated = _activeRoom!.participants.map((p) {
      if (p.userId == 'user_ahmed_peer') {
        return p.copyWith(
          status: startBreak ? ParticipantStatus.onBreak : ParticipantStatus.studying,
          breakMinutesRemaining: startBreak ? 10 : null,
        );
      }
      return p;
    }).toList();
    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }
  void simulatePeerAdd({required String name, required String major, required int level}) {
    if (_activeRoom == null || _activeRoom!.participants.length >= 6) return;
    final id = 'user_sim_${DateTime.now().millisecondsSinceEpoch}';
    final participant = RoomParticipant(
      userId: id,
      displayName: name,
      major: major,
      level: level,
      isHost: false,
      status: ParticipantStatus.studying,
      currentSubject: 'Calculus & Linear Algebra',
      joinedAt: DateTime.now(),
    );
    addParticipant(participant);
  }
  void simulatePeerRemove(String userId) {
    if (_activeRoom == null) return;
    final updated = _activeRoom!.participants.where((p) => p.userId != userId).toList();
    _activeRoom = _activeRoom!.copyWith(participants: updated);
    notifyListeners();
  }

  // --- Multiplayer Mini Games System ---
  void startMiniGame(
    MiniGameType gameType, {
    String? userId,
    String? userName,
    String? requesterId,
    String? requesterName,
  }) {
    if (_activeRoom == null) return;
    if (_activeRoom!.activeMiniGame != null &&
        _activeRoom!.activeMiniGame!.status != MiniGameStatus.completed) {
      debugPrint('[MiniGame] Concurrency conflict: A mini-game is already active in the room.');
      return;
    }

    final profile = _academicService.profile;
    final starterId = userId ?? requesterId ?? profile.id;
    final starterName = userName ?? requesterName ??
        (starterId == 'user_ahmed_peer'
            ? 'Ahmed'
            : (starterId == profile.id ? profile.name : 'Peer'));

    final questions = MiniGameQuestions.getQuestionsForGame(gameType);
    final now = DateTime.now();

    final game = RoomMiniGameState(
      gameId: 'game_${now.millisecondsSinceEpoch}',
      gameType: gameType,
      status: MiniGameStatus.countdown,
      startedByUserId: starterId,
      startedByUserName: starterName,
      startedAt: now,
      countdownEndsAt: now.add(const Duration(seconds: 3)),
      roundEndsAt: now.add(const Duration(seconds: 15)),
      currentRound: 1,
      totalRounds: 3,
      currentQuestion: questions.first,
      allQuestions: questions,
      answers: const {},
      scores: const {},
    );

    _activeRoom = _activeRoom!.copyWith(activeMiniGame: game);
    notifyListeners();

    _roomRepository.startMiniGame(_activeRoom!.id, game);

    // Schedule auto transition from countdown to round 1
    _miniGameCountdownTimer?.cancel();
    _miniGameCountdownTimer = Timer(const Duration(seconds: 3), () {
      if (_activeRoom?.activeMiniGame?.gameId == game.gameId &&
          _activeRoom?.activeMiniGame?.status == MiniGameStatus.countdown) {
        startRoundFromCountdown();
      }
    });
  }

  void startRoundFromCountdown() {
    _miniGameCountdownTimer?.cancel();
    if (_activeRoom == null || _activeRoom!.activeMiniGame == null) return;
    if (_activeRoom!.activeMiniGame!.status == MiniGameStatus.countdown) {
      final updatedGame = _activeRoom!.activeMiniGame!.copyWith(
        status: MiniGameStatus.inRound,
        roundEndsAt: DateTime.now().add(const Duration(seconds: 12)),
      );
      _activeRoom = _activeRoom!.copyWith(activeMiniGame: updatedGame);
      notifyListeners();
      _roomRepository.updateMiniGameState(_activeRoom!.id, updatedGame);
    }
  }

  void submitMiniGameAnswer({
    required String userId,
    required int optionIndex,
  }) {
    if (_activeRoom == null || _activeRoom!.activeMiniGame == null) return;
    final current = _activeRoom!.activeMiniGame!;
    if (current.status != MiniGameStatus.inRound) return;
    if (current.answers.containsKey(userId)) return;

    final isCorrect = optionIndex == current.currentQuestion.correctIndex;
    final points = isCorrect ? 10 : 0;
    final updatedScores = Map<String, int>.from(current.scores);
    updatedScores[userId] = (updatedScores[userId] ?? 0) + points;
    final updatedAnswers = Map<String, int>.from(current.answers)..[userId] = optionIndex;

    final updatedGame = current.copyWith(
      answers: updatedAnswers,
      scores: updatedScores,
    );

    _activeRoom = _activeRoom!.copyWith(activeMiniGame: updatedGame);
    notifyListeners();

    _roomRepository.submitMiniGameAnswer(
      roomId: _activeRoom!.id,
      currentGame: current,
      userId: userId,
      optionIndex: optionIndex,
      earnedPoints: points,
      totalParticipants: _activeRoom!.participants.length,
    );

    if (updatedAnswers.length >= _activeRoom!.participants.length) {
      _miniGameAutoAdvanceTimer?.cancel();
      _miniGameAutoAdvanceTimer = Timer(const Duration(milliseconds: 600), () {
        if (_activeRoom?.activeMiniGame?.status == MiniGameStatus.inRound) {
          revealMiniGameRound();
        }
      });
    }
  }

  void revealMiniGameRound() {
    _miniGameAutoAdvanceTimer?.cancel();
    if (_activeRoom == null || _activeRoom!.activeMiniGame == null) return;
    final current = _activeRoom!.activeMiniGame!;
    if (current.status != MiniGameStatus.inRound) return;

    final updatedGame = current.copyWith(
      status: MiniGameStatus.roundReview,
      roundEndsAt: DateTime.now().add(const Duration(seconds: 3)),
    );
    _activeRoom = _activeRoom!.copyWith(activeMiniGame: updatedGame);
    notifyListeners();
    _roomRepository.updateMiniGameState(_activeRoom!.id, updatedGame);

    _miniGameAutoAdvanceTimer = Timer(const Duration(seconds: 3), () {
      if (_activeRoom?.activeMiniGame?.status == MiniGameStatus.roundReview) {
        advanceMiniGameRound();
      }
    });
  }

  void advanceMiniGameRound() {
    _miniGameAutoAdvanceTimer?.cancel();
    if (_activeRoom == null || _activeRoom!.activeMiniGame == null) return;
    final current = _activeRoom!.activeMiniGame!;

    if (current.currentRound < current.totalRounds && current.currentRound < current.allQuestions.length) {
      final nextRound = current.currentRound + 1;
      final nextQuestion = current.allQuestions[nextRound - 1];
      final updatedGame = current.copyWith(
        currentRound: nextRound,
        currentQuestion: nextQuestion,
        status: MiniGameStatus.inRound,
        answers: const {},
        roundEndsAt: DateTime.now().add(const Duration(seconds: 12)),
      );
      _activeRoom = _activeRoom!.copyWith(activeMiniGame: updatedGame);
      notifyListeners();
      _roomRepository.updateMiniGameState(_activeRoom!.id, updatedGame);
    } else {
      // Award XP to user based on performance
      final myId = _academicService.profile.id;
      final myScore = current.scores[myId] ?? 0;
      final highestScore = current.scores.values.fold(0, (max, s) => s > max ? s : max);
      final isWinner = myScore > 0 && myScore >= highestScore;
      final xpReward = isWinner ? 20 : 10;
      _academicService.addXp(xpReward, reason: 'Mini-Game: ${current.gameType.title}');

      final completedGame = current.copyWith(status: MiniGameStatus.completed);
      _activeRoom = _activeRoom!.copyWith(activeMiniGame: completedGame);
      notifyListeners();
      _roomRepository.updateMiniGameState(_activeRoom!.id, completedGame);
    }
  }

  void exitMiniGame() {
    if (_activeRoom == null) return;
    _activeRoom = _activeRoom!.copyWith(clearActiveMiniGame: true);
    notifyListeners();
    _roomRepository.clearMiniGame(_activeRoom!.id);
  }

  void simulateAhmedMiniGameAnswer(int optionIndex) {
    submitMiniGameAnswer(userId: 'user_ahmed_peer', optionIndex: optionIndex);
  }

  // --- Real Synchronized Audio Music Engine ---
  void toggleMusicPlay({String? requesterId}) {
    if (_activeRoom == null) return;
    final myId = requesterId ?? _academicService.profile.id;

    if (_activeRoom!.hostId != myId) {
      debugPrint('[Music] Permission denied: Only host can control room music.');
      return;
    }

    final cur = _activeRoom!.musicState;
    final nextPlay = !cur.isPlaying;
    final now = DateTime.now();

    int nextPosition = cur.positionSeconds;
    if (!nextPlay && cur.startedAt != null) {
      final elapsed = now.difference(cur.startedAt!).inSeconds;
      nextPosition = (cur.positionSeconds + elapsed) % cur.totalDurationSeconds;
    }

    final nextMusic = cur.copyWith(
      isPlaying: nextPlay,
      startedAt: nextPlay ? now : null,
      clearStartedAt: !nextPlay,
      positionSeconds: nextPosition,
    );

    _activeRoom = _activeRoom!.copyWith(musicState: nextMusic);
    _syncAudioWithRoom();
    notifyListeners();

    _roomRepository.updateRoomMusic(_activeRoom!.id, nextMusic);
  }

  void nextTrack({String? requesterId}) {
    if (_activeRoom == null) return;
    final myId = requesterId ?? _academicService.profile.id;

    if (_activeRoom!.hostId != myId) {
      debugPrint('[Music] Permission denied: Only host can change room track.');
      return;
    }

    final cur = _activeRoom!.musicState;
    final curIdx = availableTracks.indexWhere((t) => t['id'] == cur.trackId);
    final nextIdx = (curIdx + 1) % availableTracks.length;
    final track = availableTracks[nextIdx];

    final nextMusic = cur.copyWith(
      trackId: track['id']!,
      trackTitle: track['title']!,
      artist: track['artist']!,
      audioUrl: track['url']!,
      totalDurationSeconds: int.tryParse(track['duration'] ?? '372') ?? 372,
      isPlaying: true,
      startedAt: DateTime.now(),
      positionSeconds: 0,
    );

    _activeRoom = _activeRoom!.copyWith(musicState: nextMusic);
    _syncAudioWithRoom();
    notifyListeners();

    _roomRepository.updateRoomMusic(_activeRoom!.id, nextMusic);
  }

  void prevTrack({String? requesterId}) {
    if (_activeRoom == null) return;
    final myId = requesterId ?? _academicService.profile.id;

    if (_activeRoom!.hostId != myId) return;

    final cur = _activeRoom!.musicState;
    final curIdx = availableTracks.indexWhere((t) => t['id'] == cur.trackId);
    final prevIdx = (curIdx - 1 + availableTracks.length) % availableTracks.length;
    final track = availableTracks[prevIdx];

    final nextMusic = cur.copyWith(
      trackId: track['id']!,
      trackTitle: track['title']!,
      artist: track['artist']!,
      audioUrl: track['url']!,
      totalDurationSeconds: int.tryParse(track['duration'] ?? '372') ?? 372,
      isPlaying: true,
      startedAt: DateTime.now(),
      positionSeconds: 0,
    );

    _activeRoom = _activeRoom!.copyWith(musicState: nextMusic);
    _syncAudioWithRoom();
    notifyListeners();

    _roomRepository.updateRoomMusic(_activeRoom!.id, nextMusic);
  }

  void _syncAudioWithRoom() {
    if (_activeRoom == null) return;
    audioPlayer.syncWithRoomMusic(
      musicState: _activeRoom!.musicState,
      isLocalMuted: _isLocalMuted,
      localVolume: _localVolume,
    );
  }

  int getMusicPositionSeconds() {
    if (_activeRoom == null) return 0;
    return _activeRoom!.musicState.currentPositionSeconds;
  }

  void toggleLocalMute() {
    _isLocalMuted = !_isLocalMuted;
    audioPlayer.setLocalMute(_isLocalMuted);
    notifyListeners();
  }

  void setLocalVolume(double vol) {
    _localVolume = vol.clamp(0.0, 1.0);
    audioPlayer.setLocalVolume(_localVolume);
    notifyListeners();
  }

  // End session and produce summary
  Future<SessionSummary> endSession() async {
    final now = DateTime.now();
    final elapsed = getElapsedDuration();
    final focusMinutes = (elapsed.inSeconds / 60).ceil().clamp(1, 480);

    final myId = _academicService.profile.id;
    final me = _activeRoom?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => _activeRoom!.participants.first,
    );

    int earnedXp = 50 + (focusMinutes * 2);
    final goalsCompleted = _completedGoalsInSession > 0
        ? _completedGoalsInSession
        : ((me != null && me.isGoalCompleted) ? 1 : 0);
    earnedXp += (goalsCompleted * 25);

    final studySession = StudySession(
      id: 'together_${now.millisecondsSinceEpoch}',
      courseId: _activeRoom?.courseCode ?? 'General Study',
      courseCode: _activeRoom?.courseCode ?? 'General Study',
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
      isGoalCompleted: goalsCompleted > 0 || (me?.isGoalCompleted ?? false),
      goal: me?.personalGoal,
      earnedXp: earnedXp,
      streakDays: _academicService.profile.studyStreakDays,
    );

    if (_activeRoom != null) {
      _roomRepository.endSession(_activeRoom!.id);
    }

    liveKitVoice.leaveVoiceRoom();
    audioPlayer.stop();

    _activeRoom = _activeRoom?.copyWith(
      status: StudyRoomStatus.ended,
      sessionEndedAt: now,
    );
    notifyListeners();

    return summary;
  }

  /// Calculates and persists session stats for participants when host ends the room
  Future<SessionSummary> recordParticipantSessionSummary() async {
    final now = DateTime.now();
    final elapsed = getElapsedDuration();
    final focusMinutes = (elapsed.inSeconds / 60).ceil().clamp(1, 480);

    final myId = _academicService.profile.id;
    final me = _activeRoom?.participants.firstWhere(
      (p) => p.userId == myId,
      orElse: () => _activeRoom!.participants.first,
    );

    int earnedXp = 50 + (focusMinutes * 2);
    final goalsCompleted = _completedGoalsInSession > 0
        ? _completedGoalsInSession
        : ((me != null && me.isGoalCompleted) ? 1 : 0);
    earnedXp += (goalsCompleted * 25);

    final studySession = StudySession(
      id: 'together_${now.millisecondsSinceEpoch}',
      courseId: _activeRoom?.courseCode ?? 'General Study',
      courseCode: _activeRoom?.courseCode ?? 'General Study',
      taskTitle: _activeRoom?.title ?? 'Study Together Session',
      durationMinutes: focusMinutes,
      timestamp: now,
      completed: true,
    );

    await _academicService.recordStudySessionAndReward(studySession, earnedXp: earnedXp);

    final summary = SessionSummary(
      totalDuration: elapsed,
      focusDuration: elapsed,
      breakDuration: const Duration(minutes: 5),
      isGoalCompleted: goalsCompleted > 0 || (me?.isGoalCompleted ?? false),
      goal: me?.personalGoal,
      earnedXp: earnedXp,
      streakDays: _academicService.profile.studyStreakDays,
    );

    liveKitVoice.leaveVoiceRoom();
    audioPlayer.stop();

    return summary;
  }

  void leaveRoom() {
    _peerSimTimer?.cancel();
    if (_activeRoom != null) {
      final myId = _academicService.profile.id;
      final isHost = _activeRoom!.hostId == myId;
      _roomRepository.leaveRoom(_activeRoom!.id, myId, isHost);
    }
    liveKitVoice.leaveVoiceRoom();
    audioPlayer.stop();
    _activeRoom = null;
    notifyListeners();
  }
}
