import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';
import 'isometric_coordinates.dart';

/// Visual style profile for the 6 distinct student character slots
class CharacterStyle {
  final Color hairColor;
  final Color hoodieColor;
  final Color skinColor;
  final String hairStyle; // 'short', 'curly', 'ponytail', 'fade'

  const CharacterStyle({
    required this.hairColor,
    required this.hoodieColor,
    required this.skinColor,
    required this.hairStyle,
  });
}

/// 2.5D Isometric Character / Avatar:
/// - Physically positioned at the assigned workstation chair
/// - Rhythmic typing & breathing focus micro-animation
/// - Supports animated walking transitions between desk and door during personal breaks
class AvatarCharacterWidget extends StatefulWidget {
  final WorkstationSlot slot;
  final RoomParticipant participant;
  final bool isSelf;
  final bool isDark;
  final double? walkProgress; // 0.0 to 1.0 if walking
  final bool isWalkingToDoor;
  final bool isWalkingToDesk;
  final bool isOutOfRoom;

  const AvatarCharacterWidget({
    super.key,
    required this.slot,
    required this.participant,
    this.isSelf = false,
    this.isDark = false,
    this.walkProgress,
    this.isWalkingToDoor = false,
    this.isWalkingToDesk = false,
    this.isOutOfRoom = false,
  });

  @override
  State<AvatarCharacterWidget> createState() => _AvatarCharacterWidgetState();
}

class _AvatarCharacterWidgetState extends State<AvatarCharacterWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _focusBobController;

  static const List<CharacterStyle> _styles = [
    CharacterStyle(
      hairColor: Color(0xFF1E1B18), // Dark brunette
      hoodieColor: Color(0xFF1E3A8A), // Collegiate Navy
      skinColor: Color(0xFFE0BB95),
      hairStyle: 'short',
    ),
    CharacterStyle(
      hairColor: Color(0xFF3F2E1E), // Brown curls
      hoodieColor: Color(0xFF047857), // Forest green
      skinColor: Color(0xFFF3D2B5),
      hairStyle: 'curly',
    ),
    CharacterStyle(
      hairColor: Color(0xFF78350F), // Auburn ponytail
      hoodieColor: Color(0xFF475569), // Slate gray
      skinColor: Color(0xFFECC29C),
      hairStyle: 'ponytail',
    ),
    CharacterStyle(
      hairColor: Color(0xFF1C1917), // Black high-fade
      hoodieColor: Color(0xFFEA580C), // UniFocus Orange
      skinColor: Color(0xFF9E6539),
      hairStyle: 'fade',
    ),
    CharacterStyle(
      hairColor: Color(0xFF92400E), // Sandy chestnut
      hoodieColor: Color(0xFF6B21A8), // Deep purple
      skinColor: Color(0xFFF0CCA8),
      hairStyle: 'short',
    ),
    CharacterStyle(
      hairColor: Color(0xFF171717), // Jet black waves
      hoodieColor: Color(0xFF0284C7), // Sky blue
      skinColor: Color(0xFFD4A373),
      hairStyle: 'curly',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Calming 2.8-second focus breathing and typing micro-oscillation
    _focusBobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _focusBobController.dispose();
    super.dispose();
  }

  CharacterStyle get _style => _styles[widget.slot.index % _styles.length];

  Offset _computePosition(double bob) {
    const verticalSeatedAnchor = 4.0;
    if (widget.walkProgress == null) {
      // Seated position physically inside the chair cushion
      final base = widget.slot.chairScreenOffset;
      return base + Offset(0, verticalSeatedAnchor + bob);
    }

    final p = widget.walkProgress!.clamp(0.0, 1.0);
    final chair = widget.slot.chairScreenOffset + const Offset(0, verticalSeatedAnchor);
    final aisle = widget.slot.aisleScreenOffset + const Offset(0, verticalSeatedAnchor);
    final door = IsometricCoordinates.toScreen(
      IsometricCoordinates.doorPoint.dx,
      IsometricCoordinates.doorPoint.dy,
      0,
    ) + const Offset(0, verticalSeatedAnchor);

    // Two-segment waypoint interpolation: chair -> aisle -> door
    if (widget.isWalkingToDoor) {
      if (p <= 0.35) {
        final t = p / 0.35;
        return Offset.lerp(chair, aisle, t)! + Offset(0, math.sin(t * math.pi * 4) * 2.5);
      } else {
        final t = (p - 0.35) / 0.65;
        return Offset.lerp(aisle, door, t)! + Offset(0, math.sin(t * math.pi * 8) * 2.5);
      }
    } else if (widget.isWalkingToDesk) {
      if (p <= 0.65) {
        final t = p / 0.65;
        return Offset.lerp(door, aisle, t)! + Offset(0, math.sin(t * math.pi * 8) * 2.5);
      } else {
        final t = (p - 0.65) / 0.35;
        return Offset.lerp(aisle, chair, t)! + Offset(0, math.sin(t * math.pi * 4) * 2.5);
      }
    }

    return chair;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isOutOfRoom) {
      return const SizedBox.shrink(); // Out on break, not inside room
    }

    final style = _style;
    final isNeedHelp = widget.participant.status == ParticipantStatus.needHelp;

    return AnimatedBuilder(
      animation: _focusBobController,
      builder: (context, child) {
        final bob = (math.sin(_focusBobController.value * math.pi * 2) * 1.4);
        final pos = _computePosition(bob);

        // Fade out slightly when right at the door threshold
        double opacity = 1.0;
        if (widget.walkProgress != null) {
          if (widget.isWalkingToDoor && widget.walkProgress! > 0.85) {
            opacity = (1.0 - widget.walkProgress!) / 0.15;
          } else if (widget.isWalkingToDesk && widget.walkProgress! < 0.15) {
            opacity = widget.walkProgress! / 0.15;
          }
        }

        return Positioned(
          left: pos.dx - 22,
          top: pos.dy - 38,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: CustomPaint(
              size: const Size(44, 52),
              painter: _CharacterPainter(
                style: style,
                isLeftWing: widget.slot.isLeftWing,
                isWalking: widget.walkProgress != null,
                isNeedHelp: isNeedHelp,
                isSelf: widget.isSelf,
                bob: bob,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CharacterPainter extends CustomPainter {
  final CharacterStyle style;
  final bool isLeftWing;
  final bool isWalking;
  final bool isNeedHelp;
  final bool isSelf;
  final double bob;

  _CharacterPainter({
    required this.style,
    required this.isLeftWing,
    required this.isWalking,
    required this.isNeedHelp,
    required this.isSelf,
    required this.bob,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    const centerY = 28.0;

    // Head position
    final headCenter = Offset(centerX, centerY - 10);

    // 1. Torso / Hoodie
    final torsoPath = Path()
      ..moveTo(centerX - 9, centerY - 2)
      ..lineTo(centerX + 9, centerY - 2)
      ..lineTo(centerX + 11, centerY + 14)
      ..lineTo(centerX - 11, centerY + 14)
      ..close();

    canvas.drawPath(
      torsoPath,
      Paint()..color = style.hoodieColor,
    );

    // Hoodie collar / drawstrings
    final collarPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(centerX - 3, centerY - 1), Offset(centerX, centerY + 4), collarPaint);
    canvas.drawLine(Offset(centerX + 3, centerY - 1), Offset(centerX, centerY + 4), collarPaint);

    // 2. Arms & Hands (angled toward keyboard on desk)
    final armPaint = Paint()
      ..color = style.hoodieColor
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    if (isWalking) {
      // Walking arm swing
      canvas.drawLine(Offset(centerX - 8, centerY + 2), Offset(centerX - 10, centerY + 10), armPaint);
      canvas.drawLine(Offset(centerX + 8, centerY + 2), Offset(centerX + 10, centerY + 10), armPaint);
    } else {
      // Resting on desk / typing
      if (isLeftWing) {
        canvas.drawLine(Offset(centerX - 7, centerY + 2), Offset(centerX - 12, centerY + 11), armPaint);
        canvas.drawLine(Offset(centerX + 6, centerY + 2), Offset(centerX - 4, centerY + 12), armPaint);
      } else {
        canvas.drawLine(Offset(centerX - 6, centerY + 2), Offset(centerX + 4, centerY + 12), armPaint);
        canvas.drawLine(Offset(centerX + 7, centerY + 2), Offset(centerX + 12, centerY + 11), armPaint);
      }
    }

    // 3. Head & Face (3/4 perspective)
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: 14, height: 16),
      Paint()..color = style.skinColor,
    );

    // 4. Hair
    final hairPaint = Paint()..color = style.hairColor;
    switch (style.hairStyle) {
      case 'short':
        final hairPath = Path()
          ..moveTo(headCenter.dx - 8, headCenter.dy - 1)
          ..quadraticBezierTo(headCenter.dx - 8, headCenter.dy - 10, headCenter.dx, headCenter.dy - 10)
          ..quadraticBezierTo(headCenter.dx + 8, headCenter.dy - 10, headCenter.dx + 8, headCenter.dy - 1)
          ..quadraticBezierTo(headCenter.dx + 4, headCenter.dy - 4, headCenter.dx, headCenter.dy - 5)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        break;

      case 'curly':
        canvas.drawCircle(headCenter + const Offset(-4, -6), 4.5, hairPaint);
        canvas.drawCircle(headCenter + const Offset(0, -8), 5.0, hairPaint);
        canvas.drawCircle(headCenter + const Offset(4, -6), 4.5, hairPaint);
        canvas.drawCircle(headCenter + const Offset(-6, -2), 3.8, hairPaint);
        canvas.drawCircle(headCenter + const Offset(6, -2), 3.8, hairPaint);
        break;

      case 'ponytail':
        final hairPath = Path()
          ..moveTo(headCenter.dx - 7, headCenter.dy)
          ..quadraticBezierTo(headCenter.dx, headCenter.dy - 10, headCenter.dx + 7, headCenter.dy)
          ..close();
        canvas.drawPath(hairPath, hairPaint);
        // Ponytail tie behind
        canvas.drawCircle(headCenter + const Offset(7, -2), 3.5, hairPaint);
        canvas.drawOval(
          Rect.fromCenter(center: headCenter + const Offset(9, 3), width: 5, height: 9),
          hairPaint,
        );
        break;

      case 'fade':
      default:
        final fadePath = Path()
          ..moveTo(headCenter.dx - 7, headCenter.dy - 2)
          ..lineTo(headCenter.dx - 7, headCenter.dy - 8)
          ..lineTo(headCenter.dx + 7, headCenter.dy - 8)
          ..lineTo(headCenter.dx + 7, headCenter.dy - 2)
          ..close();
        canvas.drawPath(fadePath, hairPaint);
        break;
    }

    // 5. Help Indicator Badge (pulsing beacon if participant needs help)
    if (isNeedHelp) {
      final helpCenter = headCenter + const Offset(0, -16);
      canvas.drawCircle(helpCenter, 7.5, Paint()..color = AppColors.brandBlue);
      canvas.drawCircle(helpCenter, 10.5, Paint()
        ..color = AppColors.brandBlue.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5);
      // '?' question mark in vector
      final textPainter = TextPainter(
        text: const TextSpan(
          text: '?',
          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      textPainter.paint(canvas, helpCenter - Offset(textPainter.width / 2, textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _CharacterPainter oldDelegate) {
    return oldDelegate.style != style ||
        oldDelegate.isWalking != isWalking ||
        oldDelegate.isNeedHelp != isNeedHelp ||
        oldDelegate.isSelf != isSelf ||
        oldDelegate.bob != bob;
  }
}
