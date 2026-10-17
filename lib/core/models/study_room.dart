import 'package:flutter/material.dart';

enum StudyRoomStatus {
  waiting,
  active,
  groupBreakRequested,
  breakMode,
  ended;

  static StudyRoomStatus get lobby => StudyRoomStatus.waiting;
  bool get isBreak => this == StudyRoomStatus.breakMode;
}

enum ParticipantStatus {
  studying('Studying', 0xFF10B981),
  onBreak('On Break', 0xFFF97316),
  needHelp('Need Help', 0xFF3B82F6),
  goalProgress('Goal Active', 0xFF8B5CF6),
  leavingSoon('Leaving Soon', 0xFF64748B);

  final String label;
  final int colorValue;
  const ParticipantStatus(this.label, this.colorValue);

  Color get color => Color(colorValue);

  IconData get icon {
    switch (this) {
      case ParticipantStatus.studying:
        return Icons.auto_stories_rounded;
      case ParticipantStatus.onBreak:
        return Icons.free_breakfast_rounded;
      case ParticipantStatus.needHelp:
        return Icons.help_outline_rounded;
      case ParticipantStatus.goalProgress:
        return Icons.flag_rounded;
      case ParticipantStatus.leavingSoon:
        return Icons.schedule_rounded;
    }
  }
}

class RoomParticipant {
  final String userId;
  final String displayName;
  final String major;
  final int level;
  final bool isHost;
  final ParticipantStatus status;
  final String currentSubject;
  final String? personalGoal;
  final bool isGoalCompleted;
  final int? breakMinutesRemaining;
  final DateTime joinedAt;
  final bool isMicMuted;
  final bool isSpeaking;

  const RoomParticipant({
    required this.userId,
    required this.displayName,
    required this.major,
    required this.level,
    this.isHost = false,
    this.status = ParticipantStatus.studying,
    required this.currentSubject,
    this.personalGoal,
    this.isGoalCompleted = false,
    this.breakMinutesRemaining,
    required this.joinedAt,
    this.isMicMuted = true,
    this.isSpeaking = false,
  });

  RoomParticipant copyWith({
    String? userId,
    String? displayName,
    String? major,
    int? level,
    bool? isHost,
    ParticipantStatus? status,
    String? currentSubject,
    String? personalGoal,
    bool? isGoalCompleted,
    int? breakMinutesRemaining,
    DateTime? joinedAt,
    bool? isMicMuted,
    bool? isSpeaking,
  }) {
    return RoomParticipant(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      major: major ?? this.major,
      level: level ?? this.level,
      isHost: isHost ?? this.isHost,
      status: status ?? this.status,
      currentSubject: currentSubject ?? this.currentSubject,
      personalGoal: personalGoal ?? this.personalGoal,
      isGoalCompleted: isGoalCompleted ?? this.isGoalCompleted,
      breakMinutesRemaining: breakMinutesRemaining ?? this.breakMinutesRemaining,
      joinedAt: joinedAt ?? this.joinedAt,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'displayName': displayName,
    'major': major,
    'level': level,
    'isHost': isHost,
    'status': status.name,
    'currentSubject': currentSubject,
    'personalGoal': personalGoal,
    'isGoalCompleted': isGoalCompleted,
    'breakMinutesRemaining': breakMinutesRemaining,
    'joinedAt': joinedAt.toIso8601String(),
    'isMicMuted': isMicMuted,
    'isSpeaking': isSpeaking,
  };

  factory RoomParticipant.fromJson(Map<String, dynamic> json) => RoomParticipant(
    userId: json['userId'] as String,
    displayName: json['displayName'] as String,
    major: json['major'] as String,
    level: json['level'] as int? ?? 1,
    isHost: json['isHost'] as bool? ?? false,
    status: ParticipantStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => ParticipantStatus.studying,
    ),
    currentSubject: json['currentSubject'] as String? ?? 'Studying',
    personalGoal: json['personalGoal'] as String?,
    isGoalCompleted: json['isGoalCompleted'] as bool? ?? false,
    breakMinutesRemaining: json['breakMinutesRemaining'] as int?,
    joinedAt: _parseDateTime(json['joinedAt']) ?? DateTime.now(),
    isMicMuted: json['isMicMuted'] as bool? ?? true,
    isSpeaking: json['isSpeaking'] as bool? ?? false,
  );
}

class BreakRequest {
  final String id;
  final String userId;
  final String userName;
  final int requestedMinutes;
  final bool? isApproved; // null = pending, true = approved, false = declined
  final DateTime createdAt;

  const BreakRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.requestedMinutes,
    this.isApproved,
    required this.createdAt,
  });

  BreakRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    int? requestedMinutes,
    bool? isApproved,
    DateTime? createdAt,
  }) {
    return BreakRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      requestedMinutes: requestedMinutes ?? this.requestedMinutes,
      isApproved: isApproved ?? this.isApproved,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'requestedMinutes': requestedMinutes,
    'isApproved': isApproved,
    'createdAt': createdAt.toIso8601String(),
  };

  factory BreakRequest.fromJson(Map<String, dynamic> json) => BreakRequest(
    id: json['id'] as String,
    userId: json['userId'] as String,
    userName: json['userName'] as String,
    requestedMinutes: json['requestedMinutes'] as int,
    isApproved: json['isApproved'] as bool?,
    createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
  );
}

class GroupBreakProposal {
  final String id;
  final String requesterId;
  final String requesterName;
  final int breakMinutes;
  final Map<String, bool> votes; // userId -> true (accepted) / false (declined)
  final DateTime createdAt;

  const GroupBreakProposal({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    this.breakMinutes = 5,
    this.votes = const {},
    required this.createdAt,
  });

  int get acceptCount => votes.values.where((v) => v == true).length;
  int get declineCount => votes.values.where((v) => v == false).length;

  bool isApproved(int totalParticipants) {
    if (totalParticipants <= 1) return acceptCount >= 1;
    if (totalParticipants == 2) return acceptCount >= 2;
    return acceptCount > (totalParticipants / 2);
  }

  bool isDeclined(int totalParticipants) {
    if (totalParticipants <= 1) return false;
    if (totalParticipants == 2) return declineCount >= 1;
    return declineCount > (totalParticipants / 2);
  }

  GroupBreakProposal copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    int? breakMinutes,
    Map<String, bool>? votes,
    DateTime? createdAt,
  }) {
    return GroupBreakProposal(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      breakMinutes: breakMinutes ?? this.breakMinutes,
      votes: votes ?? this.votes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requesterId': requesterId,
    'requesterName': requesterName,
    'breakMinutes': breakMinutes,
    'votes': votes,
    'createdAt': createdAt.toIso8601String(),
  };

  factory GroupBreakProposal.fromJson(Map<String, dynamic> json) => GroupBreakProposal(
    id: json['id'] as String,
    requesterId: json['requesterId'] as String,
    requesterName: json['requesterName'] as String,
    breakMinutes: json['breakMinutes'] as int? ?? 5,
    votes: (json['votes'] as Map<dynamic, dynamic>?)?.map(
          (k, v) => MapEntry(k.toString(), v == true),
        ) ??
        const {},
    createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
  );
}

class RoomMusicState {
  final String trackId;
  final String trackTitle;
  final String artist;
  final String audioUrl;
  final bool isPlaying;
  final DateTime? startedAt;
  final int positionSeconds;
  final int totalDurationSeconds;

  const RoomMusicState({
    required this.trackId,
    required this.trackTitle,
    required this.artist,
    this.audioUrl = 'asset://assets/audio/ambient_study.wav',
    required this.isPlaying,
    this.startedAt,
    this.positionSeconds = 0,
    this.totalDurationSeconds = 360,
  });

  int get currentPositionSeconds {
    if (!isPlaying || startedAt == null) return positionSeconds;
    final elapsed = DateTime.now().difference(startedAt!).inSeconds;
    final computed = positionSeconds + elapsed;
    return computed > totalDurationSeconds ? totalDurationSeconds : (computed < 0 ? 0 : computed);
  }

  RoomMusicState copyWith({
    String? trackId,
    String? trackTitle,
    String? artist,
    String? audioUrl,
    bool? isPlaying,
    DateTime? startedAt,
    bool clearStartedAt = false,
    int? positionSeconds,
    int? totalDurationSeconds,
  }) {
    return RoomMusicState(
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      isPlaying: isPlaying ?? this.isPlaying,
      startedAt: clearStartedAt ? null : (startedAt ?? this.startedAt),
      positionSeconds: positionSeconds ?? this.positionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'trackTitle': trackTitle,
    'artist': artist,
    'audioUrl': audioUrl,
    'isPlaying': isPlaying,
    'startedAt': startedAt?.toIso8601String(),
    'positionSeconds': positionSeconds,
    'totalDurationSeconds': totalDurationSeconds,
  };

  factory RoomMusicState.fromJson(Map<String, dynamic> json) => RoomMusicState(
    trackId: json['trackId'] as String? ?? 'track_ambient_study',
    trackTitle: json['trackTitle'] as String? ?? 'Ambient Study Harmonic Flow',
    artist: json['artist'] as String? ?? 'UniFocus Royalty-Free Lo-Fi',
    audioUrl: json['audioUrl'] as String? ?? 'asset://assets/audio/ambient_study.wav',
    isPlaying: json['isPlaying'] as bool? ?? false,
    startedAt: _parseDateTime(json['startedAt']),
    positionSeconds: json['positionSeconds'] as int? ?? 0,
    totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 360,
  );
}

class StudyRoom {
  final String id; // Code: "XXX-XXX-XXX"
  final String title;
  final String courseCode;
  final String hostId;
  final String hostName;
  final StudyRoomStatus status;
  final DateTime createdAt;
  final DateTime? countdownStartedAt;
  final DateTime? sessionStartedAt;
  final DateTime? sessionEndedAt;
  final List<RoomParticipant> participants;
  final List<BreakRequest> breakRequests;
  final GroupBreakProposal? activeGroupBreak;
  final DateTime? breakStartedAt;
  final DateTime? breakEndsAt;
  final int breakDurationMinutes;
  final RoomMusicState musicState;
  final bool isVoiceBreakEnabled;
  final RoomMiniGameState? activeMiniGame;
  final List<String> readyToResumeUserIds;

  const StudyRoom({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.hostId,
    required this.hostName,
    this.status = StudyRoomStatus.waiting,
    required this.createdAt,
    this.countdownStartedAt,
    this.sessionStartedAt,
    this.sessionEndedAt,
    this.participants = const [],
    this.breakRequests = const [],
    this.activeGroupBreak,
    this.breakStartedAt,
    this.breakEndsAt,
    this.breakDurationMinutes = 5,
    this.musicState = const RoomMusicState(
      trackId: 'track_ambient_study',
      trackTitle: 'Ambient Study Harmonic Flow',
      artist: 'UniFocus Royalty-Free Lo-Fi',
      audioUrl: 'asset://assets/audio/ambient_study.wav',
      isPlaying: false,
      totalDurationSeconds: 360,
    ),
    this.isVoiceBreakEnabled = true,
    this.activeMiniGame,
    this.readyToResumeUserIds = const [],
  });

  bool get isAnyOnBreak =>
      status == StudyRoomStatus.breakMode ||
      participants.any((p) => p.status == ParticipantStatus.onBreak);

  bool get isGroupBreakActive => status == StudyRoomStatus.breakMode;

  StudyRoom copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? hostId,
    String? hostName,
    StudyRoomStatus? status,
    DateTime? createdAt,
    DateTime? countdownStartedAt,
    bool clearCountdownStartedAt = false,
    DateTime? sessionStartedAt,
    DateTime? sessionEndedAt,
    List<RoomParticipant>? participants,
    List<BreakRequest>? breakRequests,
    GroupBreakProposal? activeGroupBreak,
    bool clearActiveGroupBreak = false,
    DateTime? breakStartedAt,
    DateTime? breakEndsAt,
    int? breakDurationMinutes,
    RoomMusicState? musicState,
    bool? isVoiceBreakEnabled,
    RoomMiniGameState? activeMiniGame,
    bool clearActiveMiniGame = false,
    List<String>? readyToResumeUserIds,
    bool clearReadyToResumeUserIds = false,
  }) {
    return StudyRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      countdownStartedAt: clearCountdownStartedAt ? null : (countdownStartedAt ?? this.countdownStartedAt),
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
      participants: participants ?? this.participants,
      breakRequests: breakRequests ?? this.breakRequests,
      activeGroupBreak: clearActiveGroupBreak ? null : (activeGroupBreak ?? this.activeGroupBreak),
      breakStartedAt: breakStartedAt ?? this.breakStartedAt,
      breakEndsAt: breakEndsAt ?? this.breakEndsAt,
      breakDurationMinutes: breakDurationMinutes ?? this.breakDurationMinutes,
      musicState: musicState ?? this.musicState,
      isVoiceBreakEnabled: isVoiceBreakEnabled ?? this.isVoiceBreakEnabled,
      activeMiniGame: clearActiveMiniGame ? null : (activeMiniGame ?? this.activeMiniGame),
      readyToResumeUserIds: clearReadyToResumeUserIds ? const [] : (readyToResumeUserIds ?? this.readyToResumeUserIds),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'courseCode': courseCode,
    'hostId': hostId,
    'hostName': hostName,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'countdownStartedAt': countdownStartedAt?.toIso8601String(),
    'sessionStartedAt': sessionStartedAt?.toIso8601String(),
    'sessionEndedAt': sessionEndedAt?.toIso8601String(),
    'participants': participants.map((p) => p.toJson()).toList(),
    'breakRequests': breakRequests.map((b) => b.toJson()).toList(),
    'activeGroupBreak': activeGroupBreak?.toJson(),
    'breakStartedAt': breakStartedAt?.toIso8601String(),
    'breakEndsAt': breakEndsAt?.toIso8601String(),
    'breakDurationMinutes': breakDurationMinutes,
    'musicState': musicState.toJson(),
    'isVoiceBreakEnabled': isVoiceBreakEnabled,
    'activeMiniGame': activeMiniGame?.toJson(),
    'readyToResumeUserIds': readyToResumeUserIds,
  };

  factory StudyRoom.fromJson(Map<String, dynamic> json) {
    final parsedCountdown = _parseDateTime(json['countdownStartedAt']);
    final parsedSession = _parseDateTime(json['sessionStartedAt']);

    final effectiveCountdown = parsedCountdown ??
        parsedSession?.subtract(const Duration(seconds: 3));
    final effectiveSession = parsedSession ??
        effectiveCountdown?.add(const Duration(seconds: 3));

    return StudyRoom(
      id: json['id'] as String,
      title: json['title'] as String,
      courseCode: json['courseCode'] as String? ?? 'General Study',
      hostId: json['hostId'] as String,
      hostName: json['hostName'] as String,
      status: StudyRoomStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StudyRoomStatus.waiting,
      ),
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.now(),
      countdownStartedAt: effectiveCountdown,
      sessionStartedAt: effectiveSession,
      sessionEndedAt: _parseDateTime(json['sessionEndedAt']),
      participants: (json['participants'] as List<dynamic>?)
              ?.map((p) => RoomParticipant.fromJson(p as Map<String, dynamic>))
              .toList() ??
          const [],
      breakRequests: (json['breakRequests'] as List<dynamic>?)
              ?.map((b) => BreakRequest.fromJson(b as Map<String, dynamic>))
              .toList() ??
          const [],
      activeGroupBreak: json['activeGroupBreak'] != null
          ? GroupBreakProposal.fromJson(json['activeGroupBreak'] as Map<String, dynamic>)
          : null,
      breakStartedAt: _parseDateTime(json['breakStartedAt']),
      breakEndsAt: _parseDateTime(json['breakEndsAt']),
      breakDurationMinutes: json['breakDurationMinutes'] as int? ?? 5,
      musicState: json['musicState'] != null
          ? RoomMusicState.fromJson(json['musicState'] as Map<String, dynamic>)
          : const RoomMusicState(
              trackId: 'track_ambient_study',
              trackTitle: 'Ambient Study Harmonic Flow',
              artist: 'UniFocus Royalty-Free Lo-Fi',
              audioUrl: 'asset://assets/audio/ambient_study.wav',
              isPlaying: false,
              totalDurationSeconds: 360,
            ),
      isVoiceBreakEnabled: json['isVoiceBreakEnabled'] as bool? ?? true,
      activeMiniGame: json['activeMiniGame'] != null
          ? RoomMiniGameState.fromJson(json['activeMiniGame'] as Map<String, dynamic>)
          : null,
      readyToResumeUserIds: (json['readyToResumeUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  try {
    // ignore: avoid_dynamic_calls
    final dynamic result = (value as dynamic).toDate();
    if (result is DateTime) return result;
  } catch (_) {}
  return null;
}

enum MiniGameType {
  quickQuiz('Quick Quiz', 'Trivia challenge across study subjects', Icons.quiz_rounded),
  fastMath('Fast Math', 'Speed mental arithmetic drill', Icons.calculate_rounded),
  wordChallenge('Word Challenge', 'Unscramble academic vocabulary', Icons.spellcheck_rounded),
  memoryMatch('Memory Match', 'Recall pattern and symbol sequences', Icons.psychology_rounded);

  final String title;
  final String description;
  final IconData icon;
  const MiniGameType(this.title, this.description, this.icon);
}

enum MiniGameStatus {
  countdown,
  inRound,
  roundReview,
  completed;
}

class MiniGameQuestion {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String? explanation;

  const MiniGameQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation,
  });

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'options': options,
    'correctIndex': correctIndex,
    'explanation': explanation,
  };

  factory MiniGameQuestion.fromJson(Map<String, dynamic> json) => MiniGameQuestion(
    prompt: json['prompt'] as String,
    options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
    correctIndex: json['correctIndex'] as int,
    explanation: json['explanation'] as String?,
  );
}

class RoomMiniGameState {
  final String gameId;
  final MiniGameType gameType;
  final MiniGameStatus status;
  final String startedByUserId;
  final String startedByUserName;
  final DateTime startedAt;
  final DateTime countdownEndsAt;
  final DateTime roundEndsAt;
  final int currentRound;
  final int totalRounds;
  final MiniGameQuestion currentQuestion;
  final List<MiniGameQuestion> allQuestions;
  final Map<String, int> answers; // userId -> selected option index
  final Map<String, int> scores;  // userId -> points

  const RoomMiniGameState({
    required this.gameId,
    required this.gameType,
    required this.status,
    required this.startedByUserId,
    required this.startedByUserName,
    required this.startedAt,
    required this.countdownEndsAt,
    required this.roundEndsAt,
    this.currentRound = 1,
    this.totalRounds = 3,
    required this.currentQuestion,
    this.allQuestions = const [],
    this.answers = const {},
    this.scores = const {},
  });

  RoomMiniGameState copyWith({
    String? gameId,
    MiniGameType? gameType,
    MiniGameStatus? status,
    String? startedByUserId,
    String? startedByUserName,
    DateTime? startedAt,
    DateTime? countdownEndsAt,
    DateTime? roundEndsAt,
    int? currentRound,
    int? totalRounds,
    MiniGameQuestion? currentQuestion,
    List<MiniGameQuestion>? allQuestions,
    Map<String, int>? answers,
    Map<String, int>? scores,
  }) {
    return RoomMiniGameState(
      gameId: gameId ?? this.gameId,
      gameType: gameType ?? this.gameType,
      status: status ?? this.status,
      startedByUserId: startedByUserId ?? this.startedByUserId,
      startedByUserName: startedByUserName ?? this.startedByUserName,
      startedAt: startedAt ?? this.startedAt,
      countdownEndsAt: countdownEndsAt ?? this.countdownEndsAt,
      roundEndsAt: roundEndsAt ?? this.roundEndsAt,
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      allQuestions: allQuestions ?? this.allQuestions,
      answers: answers ?? this.answers,
      scores: scores ?? this.scores,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameType': gameType.name,
    'status': status.name,
    'startedByUserId': startedByUserId,
    'startedByUserName': startedByUserName,
    'startedAt': startedAt.toIso8601String(),
    'countdownEndsAt': countdownEndsAt.toIso8601String(),
    'roundEndsAt': roundEndsAt.toIso8601String(),
    'currentRound': currentRound,
    'totalRounds': totalRounds,
    'currentQuestion': currentQuestion.toJson(),
    'allQuestions': allQuestions.map((q) => q.toJson()).toList(),
    'answers': answers,
    'scores': scores,
  };

  factory RoomMiniGameState.fromJson(Map<String, dynamic> json) => RoomMiniGameState(
    gameId: json['gameId'] as String,
    gameType: MiniGameType.values.firstWhere(
      (e) => e.name == json['gameType'],
      orElse: () => MiniGameType.quickQuiz,
    ),
    status: MiniGameStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => MiniGameStatus.countdown,
    ),
    startedByUserId: json['startedByUserId'] as String,
    startedByUserName: json['startedByUserName'] as String,
    startedAt: _parseDateTime(json['startedAt']) ?? DateTime.now(),
    countdownEndsAt: _parseDateTime(json['countdownEndsAt']) ?? DateTime.now(),
    roundEndsAt: _parseDateTime(json['roundEndsAt']) ?? DateTime.now(),
    currentRound: json['currentRound'] as int? ?? 1,
    totalRounds: json['totalRounds'] as int? ?? 3,
    currentQuestion: MiniGameQuestion.fromJson(json['currentQuestion'] as Map<String, dynamic>),
    allQuestions: (json['allQuestions'] as List<dynamic>?)
            ?.map((q) => MiniGameQuestion.fromJson(q as Map<String, dynamic>))
            .toList() ??
        const [],
    answers: (json['answers'] as Map<dynamic, dynamic>?)?.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ) ??
        const {},
    scores: (json['scores'] as Map<dynamic, dynamic>?)?.map(
          (k, v) => MapEntry(k.toString(), (v as num).toInt()),
        ) ??
        const {},
  );
}
