import 'package:flutter/material.dart';

enum StudyRoomStatus { waiting, active, ended }

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
    joinedAt: json['joinedAt'] != null
        ? DateTime.parse(json['joinedAt'] as String)
        : DateTime.now(),
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
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

class RoomMusicState {
  final String trackId;
  final String trackTitle;
  final String artist;
  final bool isPlaying;
  final DateTime? startedAt;
  final int positionSeconds;
  final int totalDurationSeconds;

  const RoomMusicState({
    required this.trackId,
    required this.trackTitle,
    required this.artist,
    required this.isPlaying,
    this.startedAt,
    this.positionSeconds = 0,
    this.totalDurationSeconds = 1800, // 30 mins
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
    bool? isPlaying,
    DateTime? startedAt,
    int? positionSeconds,
    int? totalDurationSeconds,
  }) {
    return RoomMusicState(
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      artist: artist ?? this.artist,
      isPlaying: isPlaying ?? this.isPlaying,
      startedAt: startedAt ?? this.startedAt,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      totalDurationSeconds: totalDurationSeconds ?? this.totalDurationSeconds,
    );
  }

  Map<String, dynamic> toJson() => {
    'trackId': trackId,
    'trackTitle': trackTitle,
    'artist': artist,
    'isPlaying': isPlaying,
    'startedAt': startedAt?.toIso8601String(),
    'positionSeconds': positionSeconds,
    'totalDurationSeconds': totalDurationSeconds,
  };

  factory RoomMusicState.fromJson(Map<String, dynamic> json) => RoomMusicState(
    trackId: json['trackId'] as String? ?? 'track_lofi_1',
    trackTitle: json['trackTitle'] as String? ?? 'Lo-fi Study Beats',
    artist: json['artist'] as String? ?? 'UniFocus Ambient',
    isPlaying: json['isPlaying'] as bool? ?? false,
    startedAt: json['startedAt'] != null
        ? DateTime.parse(json['startedAt'] as String)
        : null,
    positionSeconds: json['positionSeconds'] as int? ?? 0,
    totalDurationSeconds: json['totalDurationSeconds'] as int? ?? 1800,
  );
}

class StudyRoom {
  final String id; // Code: "482-731-205"
  final String title;
  final String courseCode;
  final String hostId;
  final String hostName;
  final StudyRoomStatus status;
  final DateTime createdAt;
  final DateTime? sessionStartedAt;
  final DateTime? sessionEndedAt;
  final List<RoomParticipant> participants;
  final List<BreakRequest> breakRequests;
  final RoomMusicState musicState;
  final bool isVoiceBreakEnabled; // Prepared for future WebRTC temporary voice break rooms

  const StudyRoom({
    required this.id,
    required this.title,
    required this.courseCode,
    required this.hostId,
    required this.hostName,
    this.status = StudyRoomStatus.waiting,
    required this.createdAt,
    this.sessionStartedAt,
    this.sessionEndedAt,
    this.participants = const [],
    this.breakRequests = const [],
    this.musicState = const RoomMusicState(
      trackId: 'track_lofi_1',
      trackTitle: 'Lo-fi Study Beats',
      artist: 'UniFocus Chill',
      isPlaying: false,
    ),
    this.isVoiceBreakEnabled = false,
  });

  bool get isAnyOnBreak =>
      participants.any((p) => p.status == ParticipantStatus.onBreak);

  StudyRoom copyWith({
    String? id,
    String? title,
    String? courseCode,
    String? hostId,
    String? hostName,
    StudyRoomStatus? status,
    DateTime? createdAt,
    DateTime? sessionStartedAt,
    DateTime? sessionEndedAt,
    List<RoomParticipant>? participants,
    List<BreakRequest>? breakRequests,
    RoomMusicState? musicState,
    bool? isVoiceBreakEnabled,
  }) {
    return StudyRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      courseCode: courseCode ?? this.courseCode,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      sessionStartedAt: sessionStartedAt ?? this.sessionStartedAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
      participants: participants ?? this.participants,
      breakRequests: breakRequests ?? this.breakRequests,
      musicState: musicState ?? this.musicState,
      isVoiceBreakEnabled: isVoiceBreakEnabled ?? this.isVoiceBreakEnabled,
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
    'sessionStartedAt': sessionStartedAt?.toIso8601String(),
    'sessionEndedAt': sessionEndedAt?.toIso8601String(),
    'participants': participants.map((p) => p.toJson()).toList(),
    'breakRequests': breakRequests.map((b) => b.toJson()).toList(),
    'musicState': musicState.toJson(),
    'isVoiceBreakEnabled': isVoiceBreakEnabled,
  };

  factory StudyRoom.fromJson(Map<String, dynamic> json) => StudyRoom(
    id: json['id'] as String,
    title: json['title'] as String,
    courseCode: json['courseCode'] as String? ?? 'CENG401',
    hostId: json['hostId'] as String,
    hostName: json['hostName'] as String,
    status: StudyRoomStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => StudyRoomStatus.waiting,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    sessionStartedAt: json['sessionStartedAt'] != null
        ? DateTime.parse(json['sessionStartedAt'] as String)
        : null,
    sessionEndedAt: json['sessionEndedAt'] != null
        ? DateTime.parse(json['sessionEndedAt'] as String)
        : null,
    participants: (json['participants'] as List<dynamic>?)
            ?.map((p) => RoomParticipant.fromJson(p as Map<String, dynamic>))
            .toList() ??
        const [],
    breakRequests: (json['breakRequests'] as List<dynamic>?)
            ?.map((b) => BreakRequest.fromJson(b as Map<String, dynamic>))
            .toList() ??
        const [],
    musicState: json['musicState'] != null
        ? RoomMusicState.fromJson(json['musicState'] as Map<String, dynamic>)
        : const RoomMusicState(
            trackId: 'track_lofi_1',
            trackTitle: 'Lo-fi Study Beats',
            artist: 'UniFocus Chill',
            isPlaying: false,
          ),
    isVoiceBreakEnabled: json['isVoiceBreakEnabled'] as bool? ?? false,
  );
}
