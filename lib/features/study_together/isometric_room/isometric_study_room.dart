import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import 'isometric_coordinates.dart';
import 'room_environment_painter.dart';
import 'workstation_widget.dart';
import 'avatar_character_widget.dart';
import 'workstation_context_bubble.dart';

/// Flagship 2.5D / Isometric Multiplayer Study Room.
/// Immersive strategy/simulation game environment (Game Dev Tycoon / management game style).
/// The physical study room is the primary UI occupying 75-85% of the viewport.
/// Supports interactive panning and zooming across 6 fixed workstations.
class IsometricStudyRoom extends StatefulWidget {
  final List<RoomParticipant> participants;
  final String currentUserId;
  final bool isBreakMode;
  final bool hideUnusedWorkstations;
  final Function(RoomParticipant)? onParticipantTap;
  final VoidCallback? onDoorTap;

  const IsometricStudyRoom({
    super.key,
    required this.participants,
    required this.currentUserId,
    this.isBreakMode = false,
    this.hideUnusedWorkstations = true,
    this.onParticipantTap,
    this.onDoorTap,
  });

  static int slotIndexForParticipant(int participantIndex) {
    const mapping = IsometricCoordinates.participantSlotMapping;
    if (participantIndex < mapping.length) {
      return mapping[participantIndex];
    }
    return participantIndex % 6;
  }

  @override
  State<IsometricStudyRoom> createState() => _IsometricStudyRoomState();
}

class _IsometricStudyRoomState extends State<IsometricStudyRoom>
    with TickerProviderStateMixin {
  int? _selectedSlotIndex;

  // Personal break animation trackers
  final Map<int, AnimationController> _walkControllers = {};
  final Set<int> _walkingToDoorSlots = {};
  final Set<int> _walkingToDeskSlots = {};
  final Set<int> _outOfRoomSlots = {};

  final Map<String, ParticipantStatus> _previousStatuses = {};

  @override
  void initState() {
    super.initState();
    _syncParticipantBreakStates();
  }

  @override
  void didUpdateWidget(covariant IsometricStudyRoom oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncParticipantBreakStates();
  }

  @override
  void dispose() {
    for (final controller in _walkControllers.values) {
      controller.dispose();
    }
    _walkControllers.clear();
    super.dispose();
  }

  static int slotIndexForParticipant(int participantIndex) =>
      IsometricStudyRoom.slotIndexForParticipant(participantIndex);

  void _syncParticipantBreakStates() {
    for (int i = 0; i < widget.participants.length && i < 6; i++) {
      final p = widget.participants[i];
      final slotIdx = slotIndexForParticipant(i);
      final prevStatus = _previousStatuses[p.userId];

      if (prevStatus != null && prevStatus != p.status) {
        if (p.status == ParticipantStatus.onBreak && prevStatus != ParticipantStatus.onBreak) {
          _triggerWalkToDoor(slotIdx);
        } else if (prevStatus == ParticipantStatus.onBreak && p.status != ParticipantStatus.onBreak) {
          _triggerReturnToDesk(slotIdx);
        }
      } else if (prevStatus == null && p.status == ParticipantStatus.onBreak) {
        _outOfRoomSlots.add(slotIdx);
      }

      _previousStatuses[p.userId] = p.status;
    }
  }

  void _triggerWalkToDoor(int slotIdx) {
    _outOfRoomSlots.remove(slotIdx);
    _walkingToDeskSlots.remove(slotIdx);
    _walkingToDoorSlots.add(slotIdx);

    final controller = _getOrCreateController(slotIdx);
    controller.reset();
    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _walkingToDoorSlots.remove(slotIdx);
          _outOfRoomSlots.add(slotIdx);
        });
      }
    });
  }

  void _triggerReturnToDesk(int slotIdx) {
    _outOfRoomSlots.remove(slotIdx);
    _walkingToDoorSlots.remove(slotIdx);
    _walkingToDeskSlots.add(slotIdx);

    final controller = _getOrCreateController(slotIdx);
    controller.reset();
    controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _walkingToDeskSlots.remove(slotIdx);
        });
      }
    });
  }

  AnimationController _getOrCreateController(int slotIdx) {
    if (_walkControllers.containsKey(slotIdx)) {
      return _walkControllers[slotIdx]!;
    }
    final c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() {
        if (mounted) setState(() {});
      });
    _walkControllers[slotIdx] = c;
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Map<int, RoomParticipant> slotToParticipant = {};
    for (int i = 0; i < widget.participants.length && i < 6; i++) {
      final slotIdx = slotIndexForParticipant(i);
      slotToParticipant[slotIdx] = widget.participants[i];
    }

    // Hide unused workstations during active/break session if enabled
    final visibleSlots = widget.hideUnusedWorkstations
        ? IsometricCoordinates.slots
            .where((s) => slotToParticipant.containsKey(s.index))
            .toList()
        : IsometricCoordinates.slots;

    // Depth sort to ensure back workstations and characters render underneath front ones
    final sortedSlots = List<WorkstationSlot>.from(visibleSlots)
      ..sort((a, b) => a.depthKey.compareTo(b.depthKey));

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportW = constraints.maxWidth;
        final viewportH = constraints.maxHeight;

        // Calculate dynamic camera scale to fit the isometric room cleanly within viewport
        final scaleX = viewportW / (IsometricCoordinates.virtualWidth + 24);
        final scaleY = (viewportH * 0.75) / (IsometricCoordinates.virtualHeight + 24);
        final cameraScale = math.min(scaleX, scaleY).clamp(0.48, 1.5);

        return ClipRect(
          child: InteractiveViewer(
            minScale: 0.50,
            maxScale: 2.6,
            boundaryMargin: const EdgeInsets.symmetric(horizontal: 80, vertical: 80),
            clipBehavior: Clip.none,
            child: Center(
              child: Transform.scale(
                scale: cameraScale,
                alignment: Alignment.center,
                child: SizedBox(
                  width: IsometricCoordinates.virtualWidth,
                  height: IsometricCoordinates.virtualHeight,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Layer 1: Physical Room Architecture (CustomPainter)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: RoomEnvironmentPainter(
                            isDark: isDark,
                            isBreakMode: widget.isBreakMode,
                          ),
                        ),
                      ),

                      // Layer 2: Occupied Workstations (Unused hidden in active sessions)
                      for (final slot in sortedSlots) ...[
                        Positioned(
                          left: slot.deskScreenOffset.dx - 60,
                          top: slot.deskScreenOffset.dy - 55,
                          child: WorkstationWidget(
                            slot: slot,
                            participant: slotToParticipant[slot.index],
                            isSelected: _selectedSlotIndex == slot.index,
                            isSelf: slotToParticipant[slot.index]?.userId == widget.currentUserId,
                            isDark: isDark,
                            onTap: () {
                              setState(() => _selectedSlotIndex = slot.index);
                              final p = slotToParticipant[slot.index];
                              if (p != null) {
                                widget.onParticipantTap?.call(p);
                              }
                            },
                          ),
                        ),
                      ],

                      // Layer 3: Character Avatars (seated or walking to door)
                      for (final slot in sortedSlots) ...[
                        if (slotToParticipant.containsKey(slot.index)) ...[
                          AvatarCharacterWidget(
                            slot: slot,
                            participant: slotToParticipant[slot.index]!,
                            isSelf: slotToParticipant[slot.index]!.userId == widget.currentUserId,
                            isDark: isDark,
                            walkProgress: _walkControllers[slot.index]?.value,
                            isWalkingToDoor: _walkingToDoorSlots.contains(slot.index),
                            isWalkingToDesk: _walkingToDeskSlots.contains(slot.index),
                            isOutOfRoom: _outOfRoomSlots.contains(slot.index),
                          ),
                        ],
                      ],

                      // Layer 4: Contextual Floating Status Bubbles (Directly above each workstation)
                      for (final slot in sortedSlots) ...[
                        WorkstationContextBubble(
                          slot: slot,
                          participant: slotToParticipant[slot.index],
                          isSelf: slotToParticipant[slot.index]?.userId == widget.currentUserId,
                          isDark: isDark,
                          onTap: () {
                            setState(() => _selectedSlotIndex = slot.index);
                            final p = slotToParticipant[slot.index];
                            if (p != null) {
                              widget.onParticipantTap?.call(p);
                            }
                          },
                        ),
                      ],

                      // Layer 5: Doorway Tap Target & Interactive Tooltip
                      Positioned(
                        left: IsometricCoordinates.toScreen(6.8, 6.8).dx - 40,
                        top: IsometricCoordinates.toScreen(6.8, 6.8).dy - 30,
                        child: Tooltip(
                          message: 'Study Hall Entrance & Break Exit',
                          child: InkWell(
                            onTap: widget.onDoorTap,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 80,
                              height: 50,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
