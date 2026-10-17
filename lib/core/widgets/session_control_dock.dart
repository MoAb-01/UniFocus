import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Floating game-style Control Dock for the Study Arena.
/// Compact, tactile buttons: BREAK, SUBJECT, GOAL, MUSIC, MORE.
/// Zero Unicode emojis: uses Material Symbols.
class SessionControlDock extends StatelessWidget {
  final VoidCallback onBreakPressed;
  final VoidCallback onSubjectPressed;
  final VoidCallback onGoalPressed;
  final VoidCallback onMusicPressed;
  final VoidCallback onMorePressed;
  final bool isBreakActive;
  final bool isMusicPlaying;

  const SessionControlDock({
    super.key,
    required this.onBreakPressed,
    required this.onSubjectPressed,
    required this.onGoalPressed,
    required this.onMusicPressed,
    required this.onMorePressed,
    this.isBreakActive = false,
    this.isMusicPlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceElevatedDark.withValues(alpha: 0.94)
            : Colors.white.withValues(alpha: 0.94),
        borderRadius: AppRadii.roundedPill,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildDockItem(
              context: context,
              icon: Icons.free_breakfast_rounded,
              label: 'BREAK',
              isActive: isBreakActive,
              activeColor: AppColors.streakOrange,
              onTap: onBreakPressed,
            ),
            _buildDockItem(
              context: context,
              icon: Icons.edit_note_rounded,
              label: 'SUBJECT',
              isActive: false,
              activeColor: AppColors.brandBlue,
              onTap: onSubjectPressed,
            ),
            _buildDockItem(
              context: context,
              icon: Icons.flag_rounded,
              label: 'GOAL',
              isActive: false,
              activeColor: AppColors.gamifyPurple,
              onTap: onGoalPressed,
            ),
            _buildDockItem(
              context: context,
              icon: Icons.music_note_rounded,
              label: 'MUSIC',
              isActive: isMusicPlaying,
              activeColor: AppColors.brandBlue,
              onTap: onMusicPressed,
            ),
            _buildDockItem(
              context: context,
              icon: Icons.more_horiz_rounded,
              label: 'MORE',
              isActive: false,
              activeColor: AppColors.textSecondaryLight,
              onTap: onMorePressed,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDockItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.roundedPill,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppRadii.roundedPill,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? activeColor : defaultColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                color: isActive ? activeColor : defaultColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
