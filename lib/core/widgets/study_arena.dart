import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/study_room.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';
import 'participant_node.dart';

/// Flagship Central Study Arena.
/// Defines the shared digital study space: a circular/elliptical multiplayer environment
/// with ambient orbital rings, central room heartbeat, and spatially arranged participants.
/// Zero Unicode emojis.
class StudyArena extends StatefulWidget {
  final List<RoomParticipant> participants;
  final String currentUserId;
  final bool isBreakMode;
  final Widget? centerChild;
  final Function(RoomParticipant)? onParticipantTap;

  const StudyArena({
    super.key,
    required this.participants,
    required this.currentUserId,
    this.isBreakMode = false,
    this.centerChild,
    this.onParticipantTap,
  });

  @override
  State<StudyArena> createState() => _StudyArenaState();
}

class _StudyArenaState extends State<StudyArena> with SingleTickerProviderStateMixin {
  late final AnimationController _orbitController;

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.isBreakMode ? AppColors.streakOrange : AppColors.brandBlue;

    return LayoutBuilder(
      builder: (context, constraints) {
        final arenaWidth = constraints.maxWidth;
        final arenaHeight = math.max(340.0, math.min(constraints.maxHeight, 460.0));
        final centerX = arenaWidth / 2;
        final centerY = arenaHeight / 2;
        final radiusX = (arenaWidth / 2) - 75;
        final radiusY = (arenaHeight / 2) - 75;

        final count = widget.participants.length;

        return SizedBox(
          width: arenaWidth,
          height: arenaHeight,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Ambient Outer Concentric Orbit Track
              Positioned.fill(
                child: CustomPaint(
                  painter: _ArenaOrbitPainter(
                    isDark: isDark,
                    color: primaryColor,
                    isBreakMode: widget.isBreakMode,
                  ),
                ),
              ),

              // Central Heartbeat Orb / Arena Core
              Center(
                child: widget.centerChild ??
                    _buildDefaultArenaCore(isDark, primaryColor),
              ),

              // Spatial Participant Nodes arranged around the central arena
              for (int i = 0; i < count; i++) ...[
                _buildPositionedParticipant(
                  index: i,
                  total: count,
                  participant: widget.participants[i],
                  centerX: centerX,
                  centerY: centerY,
                  radiusX: radiusX,
                  radiusY: radiusY,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultArenaCore(bool isDark, Color primaryColor) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            primaryColor.withValues(alpha: isDark ? 0.25 : 0.12),
            primaryColor.withValues(alpha: 0.0),
          ],
        ),
      ),
      child: Center(
        child: Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? AppColors.surfaceDark : Colors.white,
            border: Border.all(
              color: primaryColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isBreakMode
                    ? Icons.free_breakfast_rounded
                    : Icons.sensors_rounded,
                size: 26,
                color: primaryColor,
              ),
              const SizedBox(height: 3),
              Text(
                widget.isBreakMode ? 'BREAK' : 'ARENA',
                style: AppTypography.label.copyWith(
                  color: primaryColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionedParticipant({
    required int index,
    required int total,
    required RoomParticipant participant,
    required double centerX,
    required double centerY,
    required double radiusX,
    required double radiusY,
  }) {
    // Trigonometric or symmetrical layout
    double angle;
    if (total == 1) {
      angle = -math.pi / 2; // top center
    } else if (total == 2) {
      // 2 players: Top-left and Bottom-right
      angle = (index == 0) ? -math.pi * 0.75 : math.pi * 0.25;
    } else if (total == 3) {
      angle = (-math.pi / 2) + (index * 2 * math.pi / 3);
    } else {
      // 4 or more: distribute evenly around ellipse
      angle = (-math.pi / 2) + (index * 2 * math.pi / total);
    }

    final posX = centerX + (radiusX * math.cos(angle)) - 65; // centered node offset
    final posY = centerY + (radiusY * math.sin(angle)) - 65;

    final isSelf = participant.userId == widget.currentUserId;

    return Positioned(
      left: posX,
      top: posY,
      child: ParticipantNode(
        participant: participant,
        isSelf: isSelf,
        onTap: () => widget.onParticipantTap?.call(participant),
      ),
    );
  }
}

class _ArenaOrbitPainter extends CustomPainter {
  final bool isDark;
  final Color color;
  final bool isBreakMode;

  _ArenaOrbitPainter({
    required this.isDark,
    required this.color,
    required this.isBreakMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadiusX = (size.width / 2) - 25;
    final outerRadiusY = (size.height / 2) - 25;

    final innerRadiusX = outerRadiusX * 0.6;
    final innerRadiusY = outerRadiusY * 0.6;

    // Outer subtle orbit line
    final outerPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.18 : 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: outerRadiusX * 2,
        height: outerRadiusY * 2,
      ),
      outerPaint,
    );

    // Inner orbit line
    final innerPaint = Paint()
      ..color = color.withValues(alpha: isDark ? 0.12 : 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: innerRadiusX * 2,
        height: innerRadiusY * 2,
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ArenaOrbitPainter oldDelegate) {
    return oldDelegate.isDark != isDark ||
        oldDelegate.color != color ||
        oldDelegate.isBreakMode != isBreakMode;
  }
}
