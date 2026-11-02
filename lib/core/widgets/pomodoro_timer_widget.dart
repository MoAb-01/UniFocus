import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class PomodoroTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final bool isRunning;
  final bool isBreak;
  final String courseCode;
  final String taskTitle;
  final VoidCallback onToggleStartPause;
  final VoidCallback onReset;
  final VoidCallback onSkip;
  final VoidCallback? onAddFiveMinutes;

  const PomodoroTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isRunning,
    required this.isBreak,
    required this.courseCode,
    required this.taskTitle,
    required this.onToggleStartPause,
    required this.onReset,
    required this.onSkip,
    this.onAddFiveMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = totalSeconds > 0
        ? (remainingSeconds / totalSeconds).clamp(0.0, 1.0)
        : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Clock Face Radial Housing
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.onSurface.withValues(alpha: 0.06),
                offset: const Offset(0, 3),
                blurRadius: 0,
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 248,
              height: 248,
              child: CustomPaint(
                painter: _AnalogRadialClockPainter(progress: progress),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$minutes:$seconds',
                        style: AppTypography.literata(
                          fontSize: 54,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          letterSpacing: -1.0,
                          height: 1.0,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isBreak
                            ? 'REST INTERVAL'
                            : (isRunning ? 'IN FOCUS SPRINT' : 'Ready to focus'),
                        style: AppTypography.courierPrime(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isBreak ? AppColors.secondary : AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Big Physical CTA Push Button: "Start" and "Resume"
        GestureDetector(
          onTap: onToggleStartPause,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isBreak ? AppColors.secondary : AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.onPrimaryFixed,
                  offset: Offset(0, 5),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning ? 'Pause' : (remainingSeconds < totalSeconds ? 'Resume' : 'Start'),
                  style: AppTypography.literata(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Micro Keys: +5 Mins, Done, Reset
        Row(
          children: [
            if (onAddFiveMinutes != null) ...[
              Expanded(
                child: GestureDetector(
                  onTap: onAddFiveMinutes,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.onSurface,
                          offset: Offset(0, 3),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Text(
                      '+5 Mins',
                      style: AppTypography.courierPrime(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: GestureDetector(
                onTap: onSkip,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.onSurface,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'DONE',
                    style: AppTypography.courierPrime(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: GestureDetector(
                onTap: onReset,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.onSurface,
                        offset: Offset(0, 3),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Text(
                    'RESET',
                    style: AppTypography.courierPrime(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnalogRadialClockPainter extends CustomPainter {
  final double progress;

  const _AnalogRadialClockPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = (size.shortestSide / 2) * (102.0 / 120.0);
    final tickRadius = (size.shortestSide / 2) * (92.0 / 120.0);

    // 1. Outer Track Ring
    final trackPaint = Paint()
      ..color = const Color(0xFFEDE0DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;
    canvas.drawCircle(center, outerRadius, trackPaint);

    // 2. Inner Dashed Tick Ring
    final tickPaint = Paint()
      ..color = const Color(0x99C1C8C0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const totalTicks = 48;
    const sweepPerTick = (2 * math.pi) / totalTicks;
    for (int i = 0; i < totalTicks; i++) {
      final startAngle = i * sweepPerTick;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: tickRadius),
        startAngle,
        sweepPerTick * 0.22,
        false,
        tickPaint,
      );
    }

    // 3. Active Progress Arc
    final activePaint = Paint()
      ..color = const Color(0xFFFC934F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9.0
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _AnalogRadialClockPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
