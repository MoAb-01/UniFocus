import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/study_room.dart';
import 'firebase_service.dart';

class FirestoreRoomRepository {
  final FirebaseService _firebaseService;

  static const List<int> preferredWorkstationSlots = [0, 3, 1, 4, 2, 5];

  FirestoreRoomRepository([FirebaseService? firebaseService])
      : _firebaseService = firebaseService ?? FirebaseService.instance;

  FirebaseFirestore? get _firestore => _firebaseService.firestore;
  bool get _isAvailable => _firebaseService.isInitialized && _firestore != null;
  bool get isAvailable => _isAvailable;

  // Generate unique 9-digit room code formatted as XXX-XXX-XXX
  String generateRoomCode() {
    final rng = Random();
    final p1 = rng.nextInt(900) + 100;
    final p2 = rng.nextInt(900) + 100;
    final p3 = rng.nextInt(900) + 100;
    return '$p1-$p2-$p3';
  }

  // ---------------------------------------------------------------------------
  // Room Creation & Joining
  // ---------------------------------------------------------------------------
  Future<StudyRoom?> createRoom({
    required String roomId,
    required String title,
    required String courseCode,
    required String hostId,
    required String hostName,
    required String hostMajor,
    required int hostLevel,
  }) async {
    if (!_isAvailable) return null;
    try {
      final now = DateTime.now();
      final hostParticipant = RoomParticipant(
        userId: hostId,
        displayName: hostName,
        major: hostMajor,
        level: hostLevel,
        isHost: true,
        status: ParticipantStatus.studying,
        currentSubject: 'Studying $courseCode',
        joinedAt: now,
      );

      final room = StudyRoom(
        id: roomId,
        title: title.isNotEmpty ? title : '$courseCode Focus Session',
        courseCode: courseCode,
        hostId: hostId,
        hostName: hostName,
        status: StudyRoomStatus.waiting,
        createdAt: now,
        participants: [hostParticipant],
      );

      final roomRef = _firestore!.collection('rooms').doc(roomId);

      final roomData = room.toJson();
      roomData.remove('participants');
      roomData['maxParticipants'] = 6;
      roomData['expiresAt'] = now.add(const Duration(hours: 12)).toIso8601String();

      await roomRef.set(roomData);

      final hostMemberData = hostParticipant.toJson();
      hostMemberData['workstationIndex'] = 0;
      await roomRef.collection('members').doc(hostId).set(hostMemberData);

      return room;
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] createRoom error: $e');
      return null;
    }
  }

  Future<bool> joinRoom({
    required String roomId,
    required RoomParticipant participant,
  }) async {
    if (!_isAvailable) return false;
    try {
      final roomRef = _firestore!.collection('rooms').doc(roomId);
      final roomDoc = await roomRef.get();

      if (!roomDoc.exists) {
        debugPrint('[FirestoreRoomRepository] joinRoom: Room $roomId does not exist');
        return false;
      }

      final statusStr = roomDoc.data()?['status'] as String?;
      if (statusStr == StudyRoomStatus.ended.name) {
        debugPrint('[FirestoreRoomRepository] joinRoom: Room $roomId has ended');
        return false;
      }

      final membersSnapshot = await roomRef.collection('members').get();
      if (membersSnapshot.docs.length >= 6) {
        debugPrint('[FirestoreRoomRepository] joinRoom: Room $roomId is full (6 max)');
        return false;
      }

      // Determine deterministic workstation slot
      final occupiedSlots = <int>{};
      for (final doc in membersSnapshot.docs) {
        final slot = doc.data()['workstationIndex'] as int?;
        if (slot != null) occupiedSlots.add(slot);
      }

      int assignedSlot = 0;
      for (final candidate in preferredWorkstationSlots) {
        if (!occupiedSlots.contains(candidate)) {
          assignedSlot = candidate;
          break;
        }
      }

      final memberData = participant.toJson();
      memberData['workstationIndex'] = assignedSlot;
      await roomRef.collection('members').doc(participant.userId).set(memberData);

      return true;
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] joinRoom error: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Realtime Listeners
  // ---------------------------------------------------------------------------
  Stream<StudyRoom?> streamRoom(String roomId) {
    if (!_isAvailable) return const Stream.empty();
    return _firestore!.collection('rooms').doc(roomId).snapshots().map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) return null;
      return StudyRoom.fromJson(snapshot.data()!);
    });
  }

  Stream<List<RoomParticipant>> streamMembers(String roomId) {
    if (!_isAvailable) return const Stream.empty();
    return _firestore!
        .collection('rooms')
        .doc(roomId)
        .collection('members')
        .snapshots()
        .map((snapshot) {
      final members = snapshot.docs.map((doc) => RoomParticipant.fromJson(doc.data())).toList();
      members.sort((a, b) {
        if (a.isHost && !b.isHost) return -1;
        if (!a.isHost && b.isHost) return 1;
        return a.joinedAt.compareTo(b.joinedAt);
      });
      return members;
    });
  }

  // ---------------------------------------------------------------------------
  // Room Lifecycle Operations
  // ---------------------------------------------------------------------------
  Future<void> startSession(String roomId) async {
    if (!_isAvailable) return;
    try {
      final now = DateTime.now();
      final sessionStart = now.add(const Duration(seconds: 3));
      await _firestore!.collection('rooms').doc(roomId).update({
        'status': StudyRoomStatus.active.name,
        'countdownStartedAt': FieldValue.serverTimestamp(),
        'sessionStartedAt': sessionStart.toIso8601String(),
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] startSession error: $e');
    }
  }

  Future<void> endSession(String roomId) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'status': StudyRoomStatus.ended.name,
        'sessionEndedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] endSession error: $e');
    }
  }

  Future<void> leaveRoom(String roomId, String userId, bool isHost) async {
    if (!_isAvailable) return;
    try {
      final roomRef = _firestore!.collection('rooms').doc(roomId);
      await roomRef.collection('members').doc(userId).delete();

      if (isHost) {
        await roomRef.update({
          'status': StudyRoomStatus.ended.name,
          'sessionEndedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] leaveRoom error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Member State Operations
  // ---------------------------------------------------------------------------
  Future<void> updateMemberStatus(
    String roomId,
    String userId,
    ParticipantStatus status, {
    String? currentSubject,
    String? personalGoal,
    int? breakMinutesRemaining,
  }) async {
    if (!_isAvailable) return;
    try {
      final updates = <String, dynamic>{
        'status': status.name,
        'breakMinutesRemaining': breakMinutesRemaining,
      };
      if (currentSubject != null) updates['currentSubject'] = currentSubject;
      if (personalGoal != null) updates['personalGoal'] = personalGoal;

      await _firestore!
          .collection('rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .update(updates);
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] updateMemberStatus error: $e');
    }
  }

  Future<void> updateMemberAudio(
    String roomId,
    String userId, {
    required bool isMicMuted,
    required bool isSpeaking,
  }) async {
    if (!_isAvailable) return;
    try {
      await _firestore!
          .collection('rooms')
          .doc(roomId)
          .collection('members')
          .doc(userId)
          .update({
        'isMicMuted': isMicMuted,
        'isSpeaking': isSpeaking,
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] updateMemberAudio error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Group Break & Voting
  // ---------------------------------------------------------------------------
  Future<void> proposeGroupBreak(String roomId, GroupBreakProposal proposal) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'status': StudyRoomStatus.groupBreakRequested.name,
        'activeGroupBreak': proposal.toJson(),
        'readyToResumeUserIds': <String>[],
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] proposeGroupBreak error: $e');
    }
  }

  Future<void> recordBreakVote({
    required String roomId,
    required GroupBreakProposal proposal,
    required String voterId,
    required bool accept,
    required int totalParticipants,
  }) async {
    if (!_isAvailable) return;
    try {
      if (proposal.requesterId == voterId && accept) return;
      if (proposal.votes[voterId] == accept) return;

      final updatedVotes = Map<String, bool>.from(proposal.votes)..[voterId] = accept;
      final updatedProposal = proposal.copyWith(votes: updatedVotes);

      if (updatedProposal.isApproved(totalParticipants)) {
        final now = DateTime.now();
        final breakEndsAt = now.add(Duration(minutes: proposal.breakMinutes));

        await _firestore!.collection('rooms').doc(roomId).update({
          'status': StudyRoomStatus.breakMode.name,
          'activeGroupBreak': updatedProposal.toJson(),
          'breakStartedAt': now.toIso8601String(),
          'breakEndsAt': breakEndsAt.toIso8601String(),
          'breakDurationMinutes': proposal.breakMinutes,
          'readyToResumeUserIds': <String>[],
        });
      } else if (updatedProposal.isDeclined(totalParticipants)) {
        await _firestore!.collection('rooms').doc(roomId).update({
          'status': StudyRoomStatus.active.name,
          'activeGroupBreak': null,
          'readyToResumeUserIds': <String>[],
        });
      } else {
        await _firestore!.collection('rooms').doc(roomId).update({
          'activeGroupBreak': updatedProposal.toJson(),
        });
      }
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] recordBreakVote error: $e');
    }
  }

  Future<void> startGroupBreakImmediately({
    required String roomId,
    required GroupBreakProposal proposal,
  }) async {
    if (!_isAvailable) return;
    try {
      final now = DateTime.now();
      final breakEndsAt = now.add(Duration(minutes: proposal.breakMinutes));

      await _firestore!.collection('rooms').doc(roomId).update({
        'status': StudyRoomStatus.breakMode.name,
        'activeGroupBreak': proposal.toJson(),
        'breakStartedAt': now.toIso8601String(),
        'breakEndsAt': breakEndsAt.toIso8601String(),
        'breakDurationMinutes': proposal.breakMinutes,
        'readyToResumeUserIds': <String>[],
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] startGroupBreakImmediately error: $e');
    }
  }

  Future<void> endGroupBreak(String roomId) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'status': StudyRoomStatus.active.name,
        'activeGroupBreak': null,
        'breakStartedAt': null,
        'breakEndsAt': null,
        'readyToResumeUserIds': <String>[],
        'activeMiniGame': null,
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] endGroupBreak error: $e');
    }
  }

  Future<void> setReadyToResume({
    required String roomId,
    required String userId,
    required bool isReady,
    required int totalParticipants,
  }) async {
    if (!_isAvailable) return;
    try {
      final docRef = _firestore!.collection('rooms').doc(roomId);
      await _firestore!.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;
        final data = snap.data() ?? {};
        final currentReady = (data['readyToResumeUserIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toSet() ??
            <String>{};

        if (isReady) {
          currentReady.add(userId);
        } else {
          currentReady.remove(userId);
        }

        if (totalParticipants > 0 && currentReady.length >= totalParticipants) {
          tx.update(docRef, {
            'status': StudyRoomStatus.active.name,
            'activeGroupBreak': null,
            'breakStartedAt': null,
            'breakEndsAt': null,
            'readyToResumeUserIds': <String>[],
            'activeMiniGame': null,
          });
        } else {
          tx.update(docRef, {
            'readyToResumeUserIds': currentReady.toList(),
          });
        }
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] setReadyToResume error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Room Music State
  // ---------------------------------------------------------------------------
  Future<void> updateRoomMusic(String roomId, RoomMusicState musicState) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'musicState': musicState.toJson(),
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] updateRoomMusic error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Synchronized Mini-Games
  // ---------------------------------------------------------------------------
  Future<void> startMiniGame(String roomId, RoomMiniGameState game) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'activeMiniGame': game.toJson(),
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] startMiniGame error: $e');
    }
  }

  Future<void> submitMiniGameAnswer({
    required String roomId,
    required RoomMiniGameState currentGame,
    required String userId,
    required int optionIndex,
    required int earnedPoints,
    int? totalParticipants,
  }) async {
    if (!_isAvailable) return;
    try {
      final docRef = _firestore!.collection('rooms').doc(roomId);
      await _firestore!.runTransaction((tx) async {
        final snap = await tx.get(docRef);
        if (!snap.exists) return;
        final data = snap.data() ?? {};
        final miniGameData = data['activeMiniGame'] as Map<String, dynamic>?;
        if (miniGameData == null) return;

        final currentMiniGame = RoomMiniGameState.fromJson(miniGameData);
        if (currentMiniGame.answers.containsKey(userId)) return;

        final updatedAnswers = Map<String, int>.from(currentMiniGame.answers)..[userId] = optionIndex;
        final currentScore = currentMiniGame.scores[userId] ?? 0;
        final updatedScores = Map<String, int>.from(currentMiniGame.scores)
          ..[userId] = currentScore + earnedPoints;

        final participantsCount = totalParticipants ?? (data['participants'] as List<dynamic>?)?.length ?? 1;

        RoomMiniGameState updatedGame;
        if (updatedAnswers.length >= participantsCount && currentMiniGame.status == MiniGameStatus.inRound) {
          updatedGame = currentMiniGame.copyWith(
            answers: updatedAnswers,
            scores: updatedScores,
            status: MiniGameStatus.roundReview,
            roundEndsAt: DateTime.now().add(const Duration(seconds: 3)),
          );
        } else {
          updatedGame = currentMiniGame.copyWith(
            answers: updatedAnswers,
            scores: updatedScores,
          );
        }

        tx.update(docRef, {
          'activeMiniGame': updatedGame.toJson(),
        });
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] submitMiniGameAnswer error: $e');
    }
  }

  Future<void> updateMiniGameState(String roomId, RoomMiniGameState game) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'activeMiniGame': game.toJson(),
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] updateMiniGameState error: $e');
    }
  }

  Future<void> clearMiniGame(String roomId) async {
    if (!_isAvailable) return;
    try {
      await _firestore!.collection('rooms').doc(roomId).update({
        'activeMiniGame': null,
      });
    } catch (e) {
      debugPrint('[FirestoreRoomRepository] clearMiniGame error: $e');
    }
  }
}
