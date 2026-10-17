import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../../features/study_together/isometric_room/isometric_study_room.dart';

/// Flagship 2.5D Isometric Multi-player Study Room.
/// Refactored from the previous circular orbit layout into a physical 2.5D academic study hall.
/// Houses 6 predefined workstations, physical room architecture, and personal break walking animations.
/// Zero Unicode emojis.
class StudyArena extends StatelessWidget {
  final List<RoomParticipant> participants;
  final String currentUserId;
  final bool isBreakMode;
  final bool hideUnusedWorkstations;
  final Widget? centerChild;
  final Function(RoomParticipant)? onParticipantTap;
  final VoidCallback? onDoorTap;

  const StudyArena({
    super.key,
    required this.participants,
    required this.currentUserId,
    this.isBreakMode = false,
    this.hideUnusedWorkstations = true,
    this.centerChild,
    this.onParticipantTap,
    this.onDoorTap,
  });

  @override
  Widget build(BuildContext context) {
    return IsometricStudyRoom(
      participants: participants,
      currentUserId: currentUserId,
      isBreakMode: isBreakMode,
      hideUnusedWorkstations: hideUnusedWorkstations,
      onParticipantTap: onParticipantTap,
      onDoorTap: onDoorTap,
    );
  }
}
