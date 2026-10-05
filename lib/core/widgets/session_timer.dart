import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Flagship Session Timer: the visual heartbeat of the Study Arena.
/// Hero typography, subtle glowing rings, ambient pulse, and synchronized room mode.
/// Zero Unicode emojis.
class SessionTimer extends StatefulWidget {
  final Duration elapsed;
  final bool isBreakMode;
  final Duration? breakRemaining;
  final String courseCode;

  const SessionTimer({
    super.key,
    required this.elapsed,
    this.isBreakMode = false,
    this.breakRemaining,
    required this.courseCode,
  });

  @override
  State<SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<SessionTimer> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final mins = d.inMinutes.remainder(60);
    final secs = d.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = widget.isBreakMode ? AppColors.streakOrange : AppColors.brandBlue;
    final activeTextColor = isDark ? Colors.white : AppColors.textPrimaryLight;

    final displayTime = widget.isBreakMode && widget.breakRemaining != null
        ? _formatDuration(widget.breakRemaining!)
        : _formatDuration(widget.elapsed);

    final modeLabel = widget.isBreakMode ? 'BREAK SESSION' : 'FOCUS SESSION';
    final modeIcon = widget.isBreakMode ? Icons.free_breakfast_rounded : Icons.sensors_rounded;

    return AnimatedBuilder(
      animation: _pulseScale,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseScale.value,
          child: child,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Room Mode Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: isDark ? 0.22 : 0.1),
              borderRadius: AppRadii.roundedPill,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.4),
                width: 1.2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  modeIcon,
                  size: 13,
                  color: primaryColor,
                ),
                const SizedBox(width: 5),
                Text(
                  modeLabel,
                  style: AppTypography.label.copyWith(
                    color: primaryColor,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Hero Digits (The Room Heartbeat)
          Text(
            displayTime,
            style: AppTypography.hero.copyWith(
              fontSize: 44,
              color: activeTextColor,
              letterSpacing: -1.2,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),

          // Course and Synchronized Aura Subtitle
          Text(
            '${widget.courseCode} · SYNCHRONIZED',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textMutedDark : AppColors.textSecondaryLight,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
