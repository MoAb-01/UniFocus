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
  });

  @override
  Widget build(BuildContext context) {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    final progress = totalSeconds > 0 ? (totalSeconds - remainingSeconds) / totalSeconds : 0.0;

    final themeColor = isBreak ? AppColors.successEmerald : AppColors.primaryNavy;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Course & Task Pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: themeColor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: themeColor.withOpacity(0.18)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isRunning ? themeColor : AppColors.textMutedLight,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                courseCode.isNotEmpty ? '$courseCode • $taskTitle' : taskTitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: themeColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Timer Circular Display
        SizedBox(
          width: 230,
          height: 230,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 6,
                  color: AppColors.surfaceElevatedLight,
                ),
              ),
              // Progress track
              SizedBox(
                width: 220,
                height: 220,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 7,
                  strokeCap: StrokeCap.round,
                  color: themeColor,
                ),
              ),
              // Inside text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isBreak ? 'REST & RECHARGE' : 'DEEP FOCUS',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: isBreak ? AppColors.successEmerald : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$minutes:$seconds',
                    style: const TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      color: AppColors.textPrimaryLight,
                      fontFeatures: [],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isRunning
                        ? 'In session'
                        : (remainingSeconds == totalSeconds ? 'Ready to focus' : 'Paused'),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton.filledTonal(
              onPressed: onReset,
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Reset session',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceElevatedLight,
                foregroundColor: AppColors.textSecondaryLight,
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: onToggleStartPause,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(20),
                elevation: 2,
              ),
              child: Icon(
                isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            IconButton.filledTonal(
              onPressed: onSkip,
              icon: const Icon(Icons.skip_next_rounded, size: 20),
              tooltip: 'Complete session',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceElevatedLight,
                foregroundColor: AppColors.textSecondaryLight,
                padding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
