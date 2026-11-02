import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// AnalogCard: Tactile cardstock container matching `code.txt` (`#FFF1EC` surface with `#211A17` bottom ledge shadow).
class AnalogCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final double shadowOffset;
  final Color? shadowColor;
  final VoidCallback? onTap;

  const AnalogCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.borderRadius = 24.0,
    this.borderWidth = 0.0,
    this.borderColor,
    this.shadowOffset = 4.0,
    this.shadowColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(borderRadius),
        border: borderWidth > 0
            ? Border.all(
                color: borderColor ?? AppColors.onSurface,
                width: borderWidth,
              )
            : null,
        boxShadow: shadowOffset > 0
            ? [
                BoxShadow(
                  color: shadowColor ?? AppColors.onSurface,
                  offset: Offset(0, shadowOffset),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      padding: padding ?? const EdgeInsets.all(20),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
