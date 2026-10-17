import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum GameButtonVariant {
  primary, // Blue
  success, // Emerald Green (START TOGETHER)
  danger, // Red (LEAVE ROOM / STOP)
  warning, // Orange (STREAKS / BREAK)
  purple, // XP / Gamification
  neutral, // Surface Slate
}

class GameButton extends StatefulWidget {
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
    this.height = 54,
    this.width,
    this.isExpanded = true,
    this.isLoading = false,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  (Color faceColor, Color bevelColor, Color textColor) _getColors() {
    switch (widget.variant) {
      case GameButtonVariant.primary:
        return (AppColors.brandBlue, AppColors.brandBlueDark, Colors.white);
      case GameButtonVariant.success:
        return (AppColors.gamifyEmerald, AppColors.gamifyEmeraldDark, Colors.white);
      case GameButtonVariant.danger:
        return (AppColors.dangerRed, AppColors.dangerRedDark, Colors.white);
      case GameButtonVariant.warning:
        return (AppColors.streakOrange, AppColors.streakOrangeDark, Colors.white);
      case GameButtonVariant.purple:
        return (AppColors.gamifyPurple, AppColors.gamifyPurpleDark, Colors.white);
      case GameButtonVariant.neutral:
        return (const Color(0xFFF1F5F9), const Color(0xFFCBD5E1), AppColors.textPrimaryLight);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (faceColor, bevelColor, textColor) = _getColors();
    final isDisabled = widget.onPressed == null || widget.isLoading;

    final double bevelHeight = _isPressed || isDisabled ? 1.0 : 4.0;
    final double topMargin = _isPressed || isDisabled ? 3.0 : 0.0;

    Widget buttonContent = Container(
      height: widget.height,
      width: widget.width,
      margin: EdgeInsets.only(top: topMargin),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.grey.shade400 : faceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDisabled ? Colors.grey.shade500 : bevelColor,
          width: 1.5,
        ),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: bevelColor,
                  offset: Offset(0, bevelHeight),
                  blurRadius: 0,
                ),
              ],
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: widget.isLoading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(widget.icon, color: textColor, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isDisabled ? null : (_) => setState(() => _isPressed = true),
      onTapCancel: isDisabled ? null : () => setState(() => _isPressed = false),
      onTap: isDisabled
          ? null
          : () {
              setState(() => _isPressed = false);
              widget.onPressed?.call();
            },
      child: widget.isExpanded
          ? SizedBox(width: double.infinity, child: buttonContent)
          : buttonContent,
    );
  }
}
