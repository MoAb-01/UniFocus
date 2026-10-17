import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'isometric_coordinates.dart';

/// Renders the physical 2.5D study room architecture:
/// - Isometric parquet floor with central aisle carpet runner
/// - Left wall with large architectural campus daylight window
/// - Right wall with Scandinavian bookshelf, academic whiteboard, and clock
/// - Visible front doorway / exit threshold
/// - Potted lush Monstera corner plant
class RoomEnvironmentPainter extends CustomPainter {
  final bool isDark;
  final bool isBreakMode;

  RoomEnvironmentPainter({
    required this.isDark,
    required this.isBreakMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawWalls(canvas);
    _drawFloor(canvas);
    _drawWindowAndDaylight(canvas);
    _drawRightWallDecorations(canvas);
    _drawDoorway(canvas);
    _drawCornerPlant(canvas);
  }

  void _drawWalls(Canvas canvas) {
    const wallH = IsometricCoordinates.wallHeight;

    // --- Left Wall ---
    final leftWallPath = Path()
      ..moveTo(IsometricCoordinates.toScreen(0, 8, 0).dx, IsometricCoordinates.toScreen(0, 8, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(0, 0, 0).dx, IsometricCoordinates.toScreen(0, 0, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(0, 0, wallH).dx, IsometricCoordinates.toScreen(0, 0, wallH).dy)
      ..lineTo(IsometricCoordinates.toScreen(0, 8, wallH).dx, IsometricCoordinates.toScreen(0, 8, wallH).dy)
      ..close();

    final leftWallPaint = Paint()
      ..color = isDark ? const Color(0xFF181F2D) : const Color(0xFFF7F4EE)
      ..style = PaintingStyle.fill;
    canvas.drawPath(leftWallPath, leftWallPaint);

    // Subtle ambient shadow on left wall
    final leftWallBorder = Paint()
      ..color = isDark ? const Color(0xFF273347) : const Color(0xFFE5DDD0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(leftWallPath, leftWallBorder);

    // --- Right Wall ---
    final rightWallPath = Path()
      ..moveTo(IsometricCoordinates.toScreen(0, 0, 0).dx, IsometricCoordinates.toScreen(0, 0, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(8, 0, 0).dx, IsometricCoordinates.toScreen(8, 0, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(8, 0, wallH).dx, IsometricCoordinates.toScreen(8, 0, wallH).dy)
      ..lineTo(IsometricCoordinates.toScreen(0, 0, wallH).dx, IsometricCoordinates.toScreen(0, 0, wallH).dy)
      ..close();

    final rightWallPaint = Paint()
      ..color = isDark ? const Color(0xFF1E2738) : const Color(0xFFECE6DC)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rightWallPath, rightWallPaint);
    canvas.drawPath(rightWallPath, leftWallBorder);

    // Baseboard trim along bottom of walls
    _drawBaseboard(canvas, 0, 8, 0, 0, isDark ? const Color(0xFF111722) : const Color(0xFFDFCFC0));
    _drawBaseboard(canvas, 0, 0, 8, 0, isDark ? const Color(0xFF141A26) : const Color(0xFFD7C7B6));
  }

  void _drawBaseboard(Canvas canvas, double x1, double y1, double x2, double y2, Color color) {
    const baseH = 8.0;
    final path = Path()
      ..moveTo(IsometricCoordinates.toScreen(x1, y1, 0).dx, IsometricCoordinates.toScreen(x1, y1, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(x2, y2, 0).dx, IsometricCoordinates.toScreen(x2, y2, 0).dy)
      ..lineTo(IsometricCoordinates.toScreen(x2, y2, baseH).dx, IsometricCoordinates.toScreen(x2, y2, baseH).dy)
      ..lineTo(IsometricCoordinates.toScreen(x1, y1, baseH).dx, IsometricCoordinates.toScreen(x1, y1, baseH).dy)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawFloor(Canvas canvas) {
    // Floor boundary
    final p0 = IsometricCoordinates.toScreen(0, 0);
    final pRight = IsometricCoordinates.toScreen(8, 0);
    final pFront = IsometricCoordinates.toScreen(8, 8);
    final pLeft = IsometricCoordinates.toScreen(0, 8);

    final floorPath = Path()
      ..moveTo(p0.dx, p0.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(pFront.dx, pFront.dy)
      ..lineTo(pLeft.dx, pLeft.dy)
      ..close();

    // Floor Base (warm oak parquet or deep walnut)
    final floorPaint = Paint()
      ..color = isDark ? const Color(0xFF141923) : const Color(0xFFEDE4D4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(floorPath, floorPaint);

    // Grid parquet planks
    final tileLinePaint = Paint()
      ..color = (isDark ? const Color(0xFF232D3F) : const Color(0xFFDDD2BF)).withValues(alpha: 0.6)
      ..strokeWidth = 1.0;

    for (int i = 0; i <= 8; i++) {
      final a = IsometricCoordinates.toScreen(i.toDouble(), 0);
      final b = IsometricCoordinates.toScreen(i.toDouble(), 8);
      canvas.drawLine(a, b, tileLinePaint);

      final c = IsometricCoordinates.toScreen(0, i.toDouble());
      final d = IsometricCoordinates.toScreen(8, i.toDouble());
      canvas.drawLine(c, d, tileLinePaint);
    }

    // Central Aisle Runner Carpet
    // Connects from back wall (x=2.8..4.2, y=2.8..4.2) straight down to the door (x=7.5, y=7.5)
    final carpetPath = Path()
      ..moveTo(IsometricCoordinates.toScreen(2.4, 2.4).dx, IsometricCoordinates.toScreen(2.4, 2.4).dy)
      ..lineTo(IsometricCoordinates.toScreen(4.6, 2.4).dx, IsometricCoordinates.toScreen(4.6, 2.4).dy)
      ..lineTo(IsometricCoordinates.toScreen(7.6, 5.4).dx, IsometricCoordinates.toScreen(7.6, 5.4).dy)
      ..lineTo(IsometricCoordinates.toScreen(5.4, 7.6).dx, IsometricCoordinates.toScreen(5.4, 7.6).dy)
      ..close();

    final carpetPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E2838).withValues(alpha: 0.7)
          : const Color(0xFFF9F7F2).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;
    canvas.drawPath(carpetPath, carpetPaint);

    // Subtle orange brand accent edge along carpet border
    final carpetBorder = Paint()
      ..color = AppColors.brandOrange.withValues(alpha: isDark ? 0.35 : 0.25)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(carpetPath, carpetBorder);
  }

  void _drawWindowAndDaylight(Canvas canvas) {
    // Architectural window on Left Wall between y = 2.0 and y = 6.6, z = 22 to 125
    final wBottomLeft = IsometricCoordinates.toScreen(0, 6.4, 24);
    final wBottomRight = IsometricCoordinates.toScreen(0, 2.0, 24);
    final wTopRight = IsometricCoordinates.toScreen(0, 2.0, 126);
    final wTopLeft = IsometricCoordinates.toScreen(0, 6.4, 126);

    final windowPath = Path()
      ..moveTo(wBottomLeft.dx, wBottomLeft.dy)
      ..lineTo(wBottomRight.dx, wBottomRight.dy)
      ..lineTo(wTopRight.dx, wTopRight.dy)
      ..lineTo(wTopLeft.dx, wTopLeft.dy)
      ..close();

    // Outside view gradient (Daylight blue / dawn sky or starry night)
    final skyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
            : [const Color(0xFFBAE6FD), const Color(0xFFE0F2FE), const Color(0xFFF0FDF4)],
        stops: const [0.0, 0.65, 1.0],
      ).createShader(Rect.fromPoints(wTopLeft, wBottomRight));
    canvas.drawPath(windowPath, skyPaint);

    // Distant campus greenery / silhouettes outside window
    final treePaint = Paint()
      ..color = (isDark ? const Color(0xFF0D1D2D) : const Color(0xFF86EFAC)).withValues(alpha: 0.65);
    final treePath = Path()
      ..moveTo(wBottomLeft.dx, wBottomLeft.dy)
      ..quadraticBezierTo((wBottomLeft.dx + wBottomRight.dx) / 2, wBottomLeft.dy - 18, wBottomRight.dx, wBottomRight.dy)
      ..close();
    canvas.drawPath(treePath, treePaint);

    // Window Mullions (modern thin dark frames)
    final mullionPaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0;

    // Horizontal mullion
    final midLeft = IsometricCoordinates.toScreen(0, 6.4, 75);
    final midRight = IsometricCoordinates.toScreen(0, 2.0, 75);
    canvas.drawLine(midLeft, midRight, mullionPaint);

    // Vertical mullions
    for (double y = 3.4; y <= 5.2; y += 1.6) {
      final vBottom = IsometricCoordinates.toScreen(0, y, 24);
      final vTop = IsometricCoordinates.toScreen(0, y, 126);
      canvas.drawLine(vBottom, vTop, mullionPaint);
    }

    // Outer window frame border
    canvas.drawPath(windowPath, Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5);

    // Sunlight beam onto the floor
    if (!isDark) {
      final sunBeam = Path()
        ..moveTo(IsometricCoordinates.toScreen(0, 2.0, 0).dx, IsometricCoordinates.toScreen(0, 2.0, 0).dy)
        ..lineTo(IsometricCoordinates.toScreen(0, 6.4, 0).dx, IsometricCoordinates.toScreen(0, 6.4, 0).dy)
        ..lineTo(IsometricCoordinates.toScreen(4.2, 7.8, 0).dx, IsometricCoordinates.toScreen(4.2, 7.8, 0).dy)
        ..lineTo(IsometricCoordinates.toScreen(3.8, 1.8, 0).dx, IsometricCoordinates.toScreen(3.8, 1.8, 0).dy)
        ..close();
      canvas.drawPath(sunBeam, Paint()
        ..color = const Color(0xFFFFFBEB).withValues(alpha: 0.18)
        ..style = PaintingStyle.fill);
    }
  }

  void _drawRightWallDecorations(Canvas canvas) {
    // 1. Scandinavian Bookshelf along Right Wall (x = 0.6 to 2.4, z = 0 to 110)
    final shelfP1 = IsometricCoordinates.toScreen(0.6, 0, 0);
    final shelfP2 = IsometricCoordinates.toScreen(2.4, 0, 0);
    final shelfTop2 = IsometricCoordinates.toScreen(2.4, 0, 105);
    final shelfTop1 = IsometricCoordinates.toScreen(0.6, 0, 105);

    final shelfPath = Path()
      ..moveTo(shelfP1.dx, shelfP1.dy)
      ..lineTo(shelfP2.dx, shelfP2.dy)
      ..lineTo(shelfTop2.dx, shelfTop2.dy)
      ..lineTo(shelfTop1.dx, shelfTop1.dy)
      ..close();

    canvas.drawPath(shelfPath, Paint()
      ..color = isDark ? const Color(0xFF2A2219) : const Color(0xFFDCC8B0));

    // Bookshelf horizontal shelves
    final shelfBorder = Paint()
      ..color = isDark ? const Color(0xFF1E1710) : const Color(0xFFBFA78D)
      ..strokeWidth = 2.0;

    for (double z = 30; z <= 85; z += 26) {
      final s1 = IsometricCoordinates.toScreen(0.6, 0, z);
      final s2 = IsometricCoordinates.toScreen(2.4, 0, z);
      canvas.drawLine(s1, s2, shelfBorder);

      // Books on shelf
      _drawBooks(canvas, 0.7, 2.2, z + 2, 18);
    }

    // 2. Academic Noticeboard / Calendar (x = 3.6 to 6.2, z = 45 to 105)
    final boardP1 = IsometricCoordinates.toScreen(3.6, 0, 45);
    final boardP2 = IsometricCoordinates.toScreen(6.2, 0, 45);
    final boardTop2 = IsometricCoordinates.toScreen(6.2, 0, 105);
    final boardTop1 = IsometricCoordinates.toScreen(3.6, 0, 105);

    final boardPath = Path()
      ..moveTo(boardP1.dx, boardP1.dy)
      ..lineTo(boardP2.dx, boardP2.dy)
      ..lineTo(boardTop2.dx, boardTop2.dy)
      ..lineTo(boardTop1.dx, boardTop1.dy)
      ..close();

    canvas.drawPath(boardPath, Paint()
      ..color = isDark ? const Color(0xFF263248) : const Color(0xFFF1EDE4));
    canvas.drawPath(boardPath, Paint()
      ..color = isDark ? const Color(0xFF3B4861) : const Color(0xFFC7BBAA)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0);

    // Sticky notes on board
    _drawStickyNote(canvas, 3.9, 0, 80, const Color(0xFFFEF08A)); // Yellow
    _drawStickyNote(canvas, 4.7, 0, 75, const Color(0xFFBFDBFE)); // Blue
    _drawStickyNote(canvas, 5.5, 0, 82, const Color(0xFFFED7AA)); // Orange

    // 3. Modern Wall Clock at x = 7.0, z = 100
    final clockCenter = IsometricCoordinates.toScreen(6.8, 0, 105);
    canvas.drawCircle(clockCenter, 11, Paint()..color = isDark ? const Color(0xFF334155) : Colors.white);
    canvas.drawCircle(clockCenter, 11, Paint()
      ..color = AppColors.brandOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0);
    // Clock hands pointing to 10:10 (Focus Time)
    canvas.drawLine(clockCenter, clockCenter + const Offset(-4, -6), Paint()..color = isDark ? Colors.white : Colors.black87..strokeWidth = 1.5);
    canvas.drawLine(clockCenter, clockCenter + const Offset(5, -3), Paint()..color = AppColors.brandOrange..strokeWidth = 1.2);
  }

  void _drawBooks(Canvas canvas, double xStart, double xEnd, double z, double bookH) {
    final colors = [
      AppColors.brandOrange,
      AppColors.brandBlue,
      AppColors.gamifyPurple,
      AppColors.gamifyEmerald,
      const Color(0xFFE11D48),
      const Color(0xFF0284C7),
    ];
    int colorIdx = 0;
    for (double x = xStart; x < xEnd - 0.2; x += 0.26) {
      final b1 = IsometricCoordinates.toScreen(x, 0, z);
      final b2 = IsometricCoordinates.toScreen(x + 0.18, 0, z);
      final bTop2 = IsometricCoordinates.toScreen(x + 0.18, 0, z + bookH);
      final bTop1 = IsometricCoordinates.toScreen(x, 0, z + bookH);

      final p = Path()
        ..moveTo(b1.dx, b1.dy)
        ..lineTo(b2.dx, b2.dy)
        ..lineTo(bTop2.dx, bTop2.dy)
        ..lineTo(bTop1.dx, bTop1.dy)
        ..close();
      canvas.drawPath(p, Paint()..color = colors[colorIdx % colors.length]);
      colorIdx++;
    }
  }

  void _drawStickyNote(Canvas canvas, double x, double y, double z, Color color) {
    final s1 = IsometricCoordinates.toScreen(x, y, z);
    final s2 = IsometricCoordinates.toScreen(x + 0.55, y, z);
    final sTop2 = IsometricCoordinates.toScreen(x + 0.55, y, z + 16);
    final sTop1 = IsometricCoordinates.toScreen(x, y, z + 16);

    final p = Path()
      ..moveTo(s1.dx, s1.dy)
      ..lineTo(s2.dx, s2.dy)
      ..lineTo(sTop2.dx, sTop2.dy)
      ..lineTo(sTop1.dx, sTop1.dy)
      ..close();
    canvas.drawPath(p, Paint()..color = color);
  }

  void _drawDoorway(Canvas canvas) {
    // Visible Entrance Door threshold at front edge: (6.5, 6.5) to (7.5, 7.5)
    final dLeft = IsometricCoordinates.toScreen(6.2, 7.8, 0);
    final dRight = IsometricCoordinates.toScreen(7.8, 6.2, 0);
    final dTopRight = IsometricCoordinates.toScreen(7.8, 6.2, 75);
    final dTopLeft = IsometricCoordinates.toScreen(6.2, 7.8, 75);

    // Door frame
    final framePath = Path()
      ..moveTo(dLeft.dx, dLeft.dy)
      ..lineTo(dTopLeft.dx, dTopLeft.dy)
      ..lineTo(dTopRight.dx, dTopRight.dy)
      ..lineTo(dRight.dx, dRight.dy);

    final framePaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF8C7A65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawPath(framePath, framePaint);

    // Welcome Doormat
    final matP1 = IsometricCoordinates.toScreen(6.4, 6.4, 0);
    final matP2 = IsometricCoordinates.toScreen(7.4, 6.4, 0);
    final matP3 = IsometricCoordinates.toScreen(7.4, 7.4, 0);
    final matP4 = IsometricCoordinates.toScreen(6.4, 7.4, 0);

    final matPath = Path()
      ..moveTo(matP1.dx, matP1.dy)
      ..lineTo(matP2.dx, matP2.dy)
      ..lineTo(matP3.dx, matP3.dy)
      ..lineTo(matP4.dx, matP4.dy)
      ..close();

    canvas.drawPath(matPath, Paint()..color = isDark ? const Color(0xFF334155) : const Color(0xFFC4B5A0));

    // Exit Indicator Beacon (glowing dot)
    final beaconCenter = IsometricCoordinates.toScreen(7.0, 7.0, 82);
    canvas.drawCircle(beaconCenter, 4.5, Paint()..color = AppColors.brandOrange);
    canvas.drawCircle(beaconCenter, 7.0, Paint()
      ..color = AppColors.brandOrange.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
  }

  void _drawCornerPlant(Canvas canvas) {
    // Corner Pot at (0.3, 0.3)
    final potCenter = IsometricCoordinates.toScreen(0.4, 0.4, 0);
    // Shadow
    canvas.drawOval(
      Rect.fromCenter(center: potCenter + const Offset(0, 4), width: 26, height: 13),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );

    // Ceramic cylinder pot
    final potPath = Path()
      ..moveTo(potCenter.dx - 9, potCenter.dy)
      ..lineTo(potCenter.dx + 9, potCenter.dy)
      ..lineTo(potCenter.dx + 11, potCenter.dy - 16)
      ..lineTo(potCenter.dx - 11, potCenter.dy - 16)
      ..close();
    canvas.drawPath(potPath, Paint()..color = isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0));

    // Lush Monstera leaves
    final leafPaint = Paint()..color = const Color(0xFF15803D);
    final leafLight = Paint()..color = const Color(0xFF22C55E);

    _drawLeaf(canvas, potCenter + const Offset(0, -16), -math.pi * 0.4, 22, leafPaint);
    _drawLeaf(canvas, potCenter + const Offset(0, -16), -math.pi * 0.7, 24, leafLight);
    _drawLeaf(canvas, potCenter + const Offset(0, -16), -math.pi * 0.15, 20, leafPaint);
    _drawLeaf(canvas, potCenter + const Offset(0, -16), -math.pi * 0.9, 18, leafLight);
    _drawLeaf(canvas, potCenter + const Offset(0, -16), -math.pi * 0.55, 28, leafPaint);
  }

  void _drawLeaf(Canvas canvas, Offset origin, double angle, double length, Paint paint) {
    final dest = origin + Offset(math.cos(angle) * length, math.sin(angle) * length);
    final path = Path()
      ..moveTo(origin.dx, origin.dy)
      ..quadraticBezierTo(
        (origin.dx + dest.dx) / 2 + math.sin(angle) * 7,
        (origin.dy + dest.dy) / 2 - math.cos(angle) * 7,
        dest.dx,
        dest.dy,
      )
      ..quadraticBezierTo(
        (origin.dx + dest.dx) / 2 - math.sin(angle) * 7,
        (origin.dy + dest.dy) / 2 + math.cos(angle) * 7,
        origin.dx,
        origin.dy,
      )
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant RoomEnvironmentPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.isBreakMode != isBreakMode;
  }
}
