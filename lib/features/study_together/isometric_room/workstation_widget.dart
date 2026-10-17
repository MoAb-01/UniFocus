import 'package:flutter/material.dart';
import '../../../core/models/study_room.dart';
import '../../../core/theme/app_colors.dart';
import 'isometric_coordinates.dart';

/// 2.5D Isometric Workstation:
/// - Isometric oak desk surface with beveled front edge
/// - Matte metal legs
/// - Ergonomic mesh office chair
/// - Laptop with status-colored glowing screen
/// - Desk lamp and ambient warm glow
/// - Ceramic coffee cup / study material
class WorkstationWidget extends StatelessWidget {
  final WorkstationSlot slot;
  final RoomParticipant? participant;
  final bool isSelected;
  final bool isSelf;
  final bool isDark;
  final VoidCallback? onTap;

  const WorkstationWidget({
    super.key,
    required this.slot,
    this.participant,
    this.isSelected = false,
    this.isSelf = false,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = participant?.status;
    final isOnBreak = status == ParticipantStatus.onBreak;
    final isOccupied = participant != null;

    final screenGlowColor = isOccupied
        ? (status?.color ?? AppColors.brandOrange)
        : (isDark ? const Color(0xFF334155) : const Color(0xFF94A3B8));

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        size: const Size(120, 110),
        painter: _WorkstationPainter(
          slot: slot,
          isOccupied: isOccupied,
          isOnBreak: isOnBreak,
          isSelf: isSelf,
          isSelected: isSelected,
          isDark: isDark,
          screenGlowColor: screenGlowColor,
        ),
      ),
    );
  }
}

class _WorkstationPainter extends CustomPainter {
  final WorkstationSlot slot;
  final bool isOccupied;
  final bool isOnBreak;
  final bool isSelf;
  final bool isSelected;
  final bool isDark;
  final Color screenGlowColor;

  _WorkstationPainter({
    required this.slot,
    required this.isOccupied,
    required this.isOnBreak,
    required this.isSelf,
    required this.isSelected,
    required this.isDark,
    required this.screenGlowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 10);

    // 1. Floor shadow under workstation
    _drawShadow(canvas, center);

    // 2. Selection ring (if this desk is selected or is user's own desk)
    if (isSelected || isSelf) {
      _drawHighlightRing(canvas, center);
    }

    // 3. Ergonomic Office Chair
    _drawChair(canvas, center);

    // 4. Desk Surface & Legs
    _drawDesk(canvas, center);

    // 5. Laptop with glowing screen
    _drawLaptop(canvas, center);

    // 6. Accessories (Desk lamp, coffee cup / succulent)
    _drawAccessories(canvas, center);
  }

  void _drawShadow(Canvas canvas, Offset center) {
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: isDark ? 0.35 : 0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 18),
        width: 76,
        height: 34,
      ),
      shadowPaint,
    );
  }

  void _drawHighlightRing(Canvas canvas, Offset center) {
    final ringPaint = Paint()
      ..color = (isSelf ? AppColors.brandOrange : AppColors.brandBlue).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: center + const Offset(0, 18),
        width: 84,
        height: 40,
      ),
      ringPaint,
    );
  }

  void _drawChair(Canvas canvas, Offset center) {
    // Chair offset mathematically derived from workstation slot geometry
    final chairDelta = slot.chairScreenOffset - slot.deskScreenOffset;
    final chairOffset = center + chairDelta;

    // Chair base / casters shadow
    canvas.drawOval(
      Rect.fromCenter(center: chairOffset + const Offset(0, 12), width: 28, height: 14),
      Paint()..color = Colors.black.withValues(alpha: isDark ? 0.3 : 0.18),
    );

    // Seat cushion
    final cushionPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFF334155);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: chairOffset + const Offset(0, 4), width: 22, height: 14),
        const Radius.circular(5),
      ),
      cushionPaint,
    );

    // Curved backrest (drawn if chair is empty or on break)
    if (!isOccupied || isOnBreak) {
      final backrestPaint = Paint()
        ..color = isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: chairOffset + const Offset(0, -7), width: 20, height: 16),
          const Radius.circular(5),
        ),
        backrestPaint,
      );

      // Spine connector
      canvas.drawLine(
        chairOffset + const Offset(0, 4),
        chairOffset + const Offset(0, -2),
        Paint()
          ..color = isDark ? const Color(0xFF475569) : const Color(0xFF64748B)
          ..strokeWidth = 2.5,
      );
    }
  }

  void _drawDesk(Canvas canvas, Offset center) {
    // Desk surface top plane (isometric diamond)
    const dw = 32.0;
    const dh = 16.0;
    const deskH = 22.0; // elevation

    final topP0 = center + const Offset(0, -dh - deskH);
    final topPRight = center + const Offset(dw, -deskH);
    final topPFront = center + const Offset(0, dh - deskH);
    final topPLeft = center + const Offset(-dw, -deskH);

    // Legs (4 dark matte metal legs)
    final legPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFF475569)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(topP0, topP0 + const Offset(0, deskH), legPaint);
    canvas.drawLine(topPRight, topPRight + const Offset(0, deskH), legPaint);
    canvas.drawLine(topPFront, topPFront + const Offset(0, deskH), legPaint);
    canvas.drawLine(topPLeft, topPLeft + const Offset(0, deskH), legPaint);

    // Desk edge side faces (for 3D thickness)
    const edgeThick = 4.0;
    // Front-left face
    final flFace = Path()
      ..moveTo(topPLeft.dx, topPLeft.dy)
      ..lineTo(topPFront.dx, topPFront.dy)
      ..lineTo(topPFront.dx, topPFront.dy + edgeThick)
      ..lineTo(topPLeft.dx, topPLeft.dy + edgeThick)
      ..close();
    canvas.drawPath(flFace, Paint()..color = isDark ? const Color(0xFF241C15) : const Color(0xFFC7B194));

    // Front-right face
    final frFace = Path()
      ..moveTo(topPFront.dx, topPFront.dy)
      ..lineTo(topPRight.dx, topPRight.dy)
      ..lineTo(topPRight.dx, topPRight.dy + edgeThick)
      ..lineTo(topPFront.dx, topPFront.dy + edgeThick)
      ..close();
    canvas.drawPath(frFace, Paint()..color = isDark ? const Color(0xFF1E1710) : const Color(0xFFB89F80));

    // Desk top surface
    final topPath = Path()
      ..moveTo(topP0.dx, topP0.dy)
      ..lineTo(topPRight.dx, topPRight.dy)
      ..lineTo(topPFront.dx, topPFront.dy)
      ..lineTo(topPLeft.dx, topPLeft.dy)
      ..close();

    final deskTopPaint = Paint()
      ..color = isDark ? const Color(0xFF2C231B) : const Color(0xFFE5D5BF)
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, deskTopPaint);

    // Subtle edge highlight
    canvas.drawPath(
      topPath,
      Paint()
        ..color = (isDark ? const Color(0xFF453629) : Colors.white).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _drawLaptop(Canvas canvas, Offset center) {
    final laptopPos = center + const Offset(0, -22);

    // Keyboard base on desk
    final kbPath = Path()
      ..moveTo(laptopPos.dx - 10, laptopPos.dy + 2)
      ..lineTo(laptopPos.dx + 10, laptopPos.dy + 2)
      ..lineTo(laptopPos.dx + 6, laptopPos.dy + 8)
      ..lineTo(laptopPos.dx - 6, laptopPos.dy + 8)
      ..close();
    canvas.drawPath(kbPath, Paint()..color = slot.defaultLaptopColor);

    // Angled screen
    final screenPath = Path()
      ..moveTo(laptopPos.dx - 9, laptopPos.dy + 2)
      ..lineTo(laptopPos.dx + 9, laptopPos.dy + 2)
      ..lineTo(laptopPos.dx + 9, laptopPos.dy - 12)
      ..lineTo(laptopPos.dx - 9, laptopPos.dy - 12)
      ..close();
    canvas.drawPath(screenPath, Paint()..color = const Color(0xFF0F172A));

    // Screen display glow (Status-colored glow)
    final glowPaint = Paint()
      ..color = screenGlowColor.withValues(alpha: isOccupied ? 0.85 : 0.3)
      ..style = PaintingStyle.fill;

    final displayRect = Rect.fromCenter(
      center: laptopPos + const Offset(0, -5),
      width: 15,
      height: 10,
    );
    canvas.drawRect(displayRect, glowPaint);

    // Ambient glow emission from screen onto desk surface
    if (isOccupied) {
      canvas.drawOval(
        Rect.fromCenter(
          center: laptopPos + const Offset(0, 3),
          width: 26,
          height: 12,
        ),
        Paint()
          ..color = screenGlowColor.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  void _drawAccessories(Canvas canvas, Offset center) {
    // Desk lamp on left/right corner
    final lampPos = slot.isLeftWing
        ? center + const Offset(-18, -32)
        : center + const Offset(18, -32);

    // Lamp neck & head
    final lampPaint = Paint()
      ..color = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)
      ..strokeWidth = 1.8;
    canvas.drawLine(lampPos, lampPos + const Offset(0, 10), lampPaint);

    // Lamp shade
    final shadePath = Path()
      ..moveTo(lampPos.dx - 4, lampPos.dy)
      ..lineTo(lampPos.dx + 4, lampPos.dy)
      ..lineTo(lampPos.dx + 6, lampPos.dy + 4)
      ..lineTo(lampPos.dx - 6, lampPos.dy + 4)
      ..close();
    canvas.drawPath(shadePath, Paint()..color = AppColors.brandOrange);

    // Warm lamp ambient glow cone
    canvas.drawOval(
      Rect.fromCenter(
        center: lampPos + const Offset(0, 10),
        width: 22,
        height: 12,
      ),
      Paint()..color = const Color(0xFFFEF3C7).withValues(alpha: isDark ? 0.18 : 0.25),
    );

    // On Break coffee mug on desk
    if (isOnBreak) {
      final mugPos = center + const Offset(12, -20);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: mugPos, width: 7, height: 8),
          const Radius.circular(2),
        ),
        Paint()..color = AppColors.brandOrange,
      );
      // Steam
      final steamPaint = Paint()
        ..color = (isDark ? Colors.white70 : Colors.black26)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;
      final steamPath = Path()
        ..moveTo(mugPos.dx, mugPos.dy - 5)
        ..quadraticBezierTo(mugPos.dx + 2, mugPos.dy - 8, mugPos.dx, mugPos.dy - 11);
      canvas.drawPath(steamPath, steamPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WorkstationPainter oldDelegate) {
    return oldDelegate.isOccupied != isOccupied ||
        oldDelegate.isOnBreak != isOnBreak ||
        oldDelegate.isSelf != isSelf ||
        oldDelegate.isSelected != isSelected ||
        oldDelegate.isDark != isDark ||
        oldDelegate.screenGlowColor != screenGlowColor;
  }
}
