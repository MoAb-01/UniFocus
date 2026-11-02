import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'tactile_press.dart';

enum GameButtonVariant {
  primary, // Deep Work Green
  success, // Deep Work Green
  danger, // Terracotta Break
  warning, // Warm Amber
  purple, // Lavender Arena
  neutral, // Cardstock / Subtle
}

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final GameButtonVariant variant;
  final double height;
  final double? width;
  final bool isExpanded;
  final bool isLoading;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.variant = GameButtonVariant.primary,
    this.height = 52,
    this.width,
    this.isExpanded = true,
    this.isLoading = false,
  });

  (Color faceColor, Color textColor) _getColors() {
    switch (variant) {
      case GameButtonVariant.primary:
      case GameButtonVariant.success:
        return (AppColors.deepWorkGreen, Colors.white);
      case GameButtonVariant.danger:
        return (AppColors.terracottaBreak, Colors.white);
      case GameButtonVariant.warning:
        return (AppColors.warmAmber, Colors.white);
      case GameButtonVariant.purple:
        return (AppColors.lavenderArena, Colors.white);
      case GameButtonVariant.neutral:
        return (AppColors.cardstock, AppColors.inkPrimary);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();
    final isInteractive = onPressed != null && !isLoading;

    final content = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: isInteractive ? colors.$1 : colors.$1.withOpacity(0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.inkBorder, width: 1.5),
        boxShadow: isInteractive
            ? const [
                BoxShadow(
                  color: AppColors.inkBorder,
                  offset: Offset(0, 3),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colors.$2),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: colors.$2, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text.toUpperCase(),
                    style: TextStyle(
                      color: colors.$2,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (isExpanded) {
      return TactilePress(
        onTap: isInteractive ? onPressed : null,
        child: SizedBox(
          width: double.infinity,
          child: content,
        ),
      );
    }

    return TactilePress(
      onTap: isInteractive ? onPressed : null,
      child: content,
    );
  }
}
