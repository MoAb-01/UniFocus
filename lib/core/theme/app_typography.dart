import 'package:flutter/material.dart';

/// Centralized typographic scale for UniFocus matching `code.txt`.
/// Uses Literata (Serif), Courier Prime (Monospace typewriter), and Plus Jakarta Sans (Body).
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Plus Jakarta Sans';
  static const String fontHeadline = 'Literata';
  static const String fontLabel = 'Courier Prime';
  static const String fontBody = 'Plus Jakarta Sans';

  /// Helper methods matching GoogleFonts.literata(), GoogleFonts.courierPrime(), GoogleFonts.plusJakartaSans()
  static TextStyle literata({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      fontFamily: fontHeadline,
      fontFamilyFallback: const ['Georgia', 'serif'],
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      fontFeatures: fontFeatures,
    );
  }

  static TextStyle courierPrime({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontLabel,
      fontFamilyFallback: const ['Courier New', 'monospace'],
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  static TextStyle plusJakartaSans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontBody,
      fontFamilyFallback: const ['Roboto', 'sans-serif'],
      fontSize: fontSize,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }

  // Display: Punchy, high-impact titles in Literata
  static const TextStyle display = TextStyle(
    fontFamily: fontHeadline,
    fontFamilyFallback: ['Georgia', 'serif'],
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  // Hero: Very large hero values (timers, GPA values, big XP numbers) in Literata
  static const TextStyle hero = TextStyle(
    fontFamily: fontHeadline,
    fontFamilyFallback: ['Georgia', 'serif'],
    fontSize: 52,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.0,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Headline: Screen titles, major section headers in Literata
  static const TextStyle headline = TextStyle(
    fontFamily: fontHeadline,
    fontFamilyFallback: ['Georgia', 'serif'],
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Title: Component headers, task titles in Literata
  static const TextStyle title = TextStyle(
    fontFamily: fontHeadline,
    fontFamilyFallback: ['Georgia', 'serif'],
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // Body: General readable text in Plus Jakarta Sans
  static const TextStyle body = TextStyle(
    fontFamily: fontBody,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontBody,
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Label: Uppercase tracking badges & tags in Courier Prime
  static const TextStyle label = TextStyle(
    fontFamily: fontLabel,
    fontFamilyFallback: ['Courier New', 'monospace'],
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.6,
    height: 1.2,
  );

  // Caption: Metadata, timestamps, footnote subtitles in Courier Prime
  static const TextStyle caption = TextStyle(
    fontFamily: fontLabel,
    fontFamilyFallback: ['Courier New', 'monospace'],
    fontSize: 11,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // Button: Tactile button text
  static const TextStyle button = TextStyle(
    fontFamily: fontLabel,
    fontFamilyFallback: ['Courier New', 'monospace'],
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Backward compatibility aliases
  static const TextStyle labelUppercase = label;
  static const TextStyle displayLarge = display;
  static const TextStyle displayMedium = headline;
  static const TextStyle displaySmall = title;
  static const TextStyle sectionHeader = title;
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontBody,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );
  static const TextStyle bodyMedium = body;
  static const TextStyle gpaValue = hero;
  static const TextStyle courseCode = TextStyle(
    fontFamily: fontLabel,
    fontSize: 13,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
  static const TextStyle gradeBadge = TextStyle(
    fontFamily: fontLabel,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
}
