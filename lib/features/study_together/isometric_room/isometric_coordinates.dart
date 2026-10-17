import 'package:flutter/material.dart';

/// Geometry and coordinate translation for the 2.5D / isometric UniFocus study room.
/// Uses 2:1 dimetric projection commonly adopted in isometric simulation games.
/// Tuned for an immersive strategy-game framing with zero wasted margins.
class IsometricCoordinates {
  IsometricCoordinates._();

  // Tight virtual canvas dimensions matching actual room boundaries
  static const double virtualWidth = 620.0;
  static const double virtualHeight = 480.0;

  // Grid sizing
  static const double tileWidthHalf = 38.0;
  static const double tileHeightHalf = 19.0;
  static const double originX = 310.0;
  static const double originY = 148.0;
  static const double wallHeight = 135.0;

  // Grid dimensions (8x8 tiles)
  static const int gridTiles = 8;

  /// Translates grid coordinates (x, y, z) to 2.5D screen offsets on virtual canvas.
  /// z is height above the floor plane in virtual pixels.
  static Offset toScreen(double x, double y, [double z = 0.0]) {
    final screenX = originX + (x - y) * tileWidthHalf;
    final screenY = originY + (x + y) * tileHeightHalf - z;
    return Offset(screenX, screenY);
  }

  /// Calculates depth sorting key. Larger values are closer to camera and drawn on top.
  static double depth(double x, double y, [double z = 0.0]) {
    return (x + y) * 100.0 + z;
  }

  /// Visible entrance door coordinates (front edge threshold)
  static const Offset doorPoint = Offset(6.8, 6.8);
  static const Offset doorExitPoint = Offset(8.0, 8.0);

  /// Deterministic participant-to-workstation mapping specified by requirements:
  /// Participant 1 → Workstation 1 (Slot 0)
  /// Participant 2 → Workstation 4 (Slot 3)
  /// Participant 3 → Workstation 2 (Slot 1)
  /// Participant 4 → Workstation 5 (Slot 4)
  /// Participant 5 → Workstation 3 (Slot 2)
  /// Participant 6 → Workstation 6 (Slot 5)
  static const List<int> participantSlotMapping = [0, 3, 1, 4, 2, 5];

  /// 6 Predefined Fixed Workstations.
  /// Spatially balanced & collision-free:
  /// - Workstations 1, 2, 3 on the Left Wing
  /// - Workstations 4, 5, 6 on the Right Wing
  /// - Central study aisle (x ≈ y) runs between them with zero overlap.
  static const List<WorkstationSlot> slots = [
    // Left Wing (facing inward toward central aisle)
    WorkstationSlot(
      index: 0,
      label: 'Desk 1 · North Left',
      deskX: 1.0,
      deskY: 2.4,
      chairX: 1.6,
      chairY: 2.4,
      aisleX: 2.8,
      aisleY: 2.8,
      isLeftWing: true,
      defaultLaptopColor: Color(0xFF64748B),
    ),
    WorkstationSlot(
      index: 1,
      label: 'Desk 2 · Mid Left',
      deskX: 1.0,
      deskY: 4.4,
      chairX: 1.6,
      chairY: 4.4,
      aisleX: 3.6,
      aisleY: 3.6,
      isLeftWing: true,
      defaultLaptopColor: Color(0xFF475569),
    ),
    WorkstationSlot(
      index: 2,
      label: 'Desk 3 · South Left',
      deskX: 1.0,
      deskY: 6.4,
      chairX: 1.6,
      chairY: 6.4,
      aisleX: 4.6,
      aisleY: 4.6,
      isLeftWing: true,
      defaultLaptopColor: Color(0xFF334155),
    ),

    // Right Wing (facing inward toward central aisle)
    WorkstationSlot(
      index: 3,
      label: 'Desk 4 · North Right',
      deskX: 2.4,
      deskY: 1.0,
      chairX: 2.4,
      chairY: 1.6,
      aisleX: 2.8,
      aisleY: 2.8,
      isLeftWing: false,
      defaultLaptopColor: Color(0xFF64748B),
    ),
    WorkstationSlot(
      index: 4,
      label: 'Desk 5 · Mid Right',
      deskX: 4.4,
      deskY: 1.0,
      chairX: 4.4,
      chairY: 1.6,
      aisleX: 3.6,
      aisleY: 3.6,
      isLeftWing: false,
      defaultLaptopColor: Color(0xFF475569),
    ),
    WorkstationSlot(
      index: 5,
      label: 'Desk 6 · South Right',
      deskX: 6.4,
      deskY: 1.0,
      chairX: 6.4,
      chairY: 1.6,
      aisleX: 4.6,
      aisleY: 4.6,
      isLeftWing: false,
      defaultLaptopColor: Color(0xFF334155),
    ),
  ];
}

class WorkstationSlot {
  final int index;
  final String label;
  final double deskX;
  final double deskY;
  final double chairX;
  final double chairY;
  final double aisleX;
  final double aisleY;
  final bool isLeftWing;
  final Color defaultLaptopColor;

  const WorkstationSlot({
    required this.index,
    required this.label,
    required this.deskX,
    required this.deskY,
    required this.chairX,
    required this.chairY,
    required this.aisleX,
    required this.aisleY,
    required this.isLeftWing,
    required this.defaultLaptopColor,
  });

  Offset get deskScreenOffset =>
      IsometricCoordinates.toScreen(deskX, deskY, 0.0);

  Offset get chairScreenOffset =>
      IsometricCoordinates.toScreen(chairX, chairY, 0.0);

  Offset get aisleScreenOffset =>
      IsometricCoordinates.toScreen(aisleX, aisleY, 0.0);

  double get depthKey =>
      IsometricCoordinates.depth(deskX, deskY, 10.0);
}
