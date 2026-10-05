import 'package:flutter/material.dart';

/// Centralized typographic scale for UniFocus.
/// Combines high-energy game typography, punchy headers, and pristine academic readability.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Roboto';

  // Display: Punchy, high-impact titles
  static const TextStyle display = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.6,
    height: 1.15,
  );

  // Hero: Very large hero values (timers, GPA values, big XP numbers)
  static const TextStyle hero = TextStyle(
    fontSize: 38,
    fontWeight: FontWeight.w900,
    letterSpacing: -1.0,
    height: 1.05,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  // Headline: Screen titles, major section headers
  static const TextStyle headline = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
    height: 1.25,
  );

  // Title: Component headers, arena headings, dialog titles
  static const TextStyle title = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.3,
  );

  // Body: General readable text
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.45,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.4,
  );

  // Label: Uppercase tracking badges & tags (e.g. "STUDY ARENA", "LEVEL 7", "FOCUS SESSION")
  static const TextStyle label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.9,
    height: 1.2,
  );

  // Caption: Metadata, timestamps, footnote subtitles
  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.3,
  );

  // Button: High-energy tactile button text
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
    height: 1.2,
  );

  // Backward compatibility aliases
  static const TextStyle displayLarge = display;
  static const TextStyle displayMedium = headline;
  static const TextStyle displaySmall = title;
  static const TextStyle sectionHeader = title;
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.5,
  );
  static const TextStyle bodyMedium = body;
  static const TextStyle gpaValue = hero;
  static const TextStyle courseCode = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.5,
  );
  static const TextStyle gradeBadge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    letterSpacing: 0.2,
  );
  static const TextStyle labelUppercase = label;
}
