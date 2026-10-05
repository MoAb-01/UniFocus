import 'package:flutter/material.dart';

/// Centralized Gamified Color Palette for UniFocus.
/// Combines Kahoot-like energy, Duolingo-like motivation, and purposeful academic hierarchy.
class AppColors {
  AppColors._();

  // Vibrant Brand Primaries (Bright Blue)
  static const Color brandBlue = Color(0xFF2563EB); // Electric Royal Blue
  static const Color brandBlueDark = Color(0xFF1D4ED8); // Bevel/shadow for 3D buttons
  static const Color brandBlueLight = Color(0xFFEFF6FF); // Soft blue tint
  static const Color brandCyan = Color(0xFF06B6D4); // Electric Cyan highlight

  // Gamification Accents (Purple, Emerald, Orange, Amber, Red)
  static const Color gamifyPurple = Color(0xFF8B5CF6); // XP & Level Badges
  static const Color gamifyPurpleDark = Color(0xFF7C3AED);
  static const Color gamifyPurpleLight = Color(0xFFF5F3FF);

  static const Color gamifyEmerald = Color(0xFF10B981); // Success, Start Together, Completed
  static const Color gamifyEmeraldDark = Color(0xFF059669);
  static const Color gamifyEmeraldLight = Color(0xFFD1FAE5);

  static const Color streakOrange = Color(0xFFF97316); // Hot Flame Streaks & Break Timer
  static const Color streakOrangeDark = Color(0xFFEA580C);
  static const Color streakOrangeLight = Color(0xFFFFF7ED);

  static const Color gamifyYellow = Color(0xFFF59E0B); // Stars, Honors, Coins
  static const Color gamifyYellowDark = Color(0xFFD97706);
  static const Color gamifyYellowLight = Color(0xFFFEF3C7);

  static const Color dangerRed = Color(0xFFEF4444); // Leave Room, Alerts, Overdue
  static const Color dangerRedDark = Color(0xFFDC2626);
  static const Color dangerRedLight = Color(0xFFFEE2E2);

  // Status Ring Colors (for Study Arena participants)
  static const Color statusStudying = Color(0xFF10B981);
  static const Color statusBreak = Color(0xFFF97316);
  static const Color statusNeedHelp = Color(0xFF3B82F6);
  static const Color statusGoalProgress = Color(0xFF8B5CF6);
  static const Color statusLeavingSoon = Color(0xFF64748B);

  // Program Indicators
  static const Color mainProgramColor = Color(0xFF2563EB);
  static const Color capProgramColor = Color(0xFF8B5CF6); // Double Major (ÇAP)
  static const Color yandalProgramColor = Color(0xFF06B6D4); // Minor (Yandal)

  // Neutral Backgrounds & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF8FAFC); // Very soft cool slate
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color dividerLight = Color(0xFFE2E8F0);

  // Intentional Dark Mode Surfaces (Oceanic midnight, not pure black or inverted)
  static const Color backgroundDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF161F30);
  static const Color surfaceElevatedDark = Color(0xFF1E293B);
  static const Color borderDark = Color(0xFF293548);
  static const Color dividerDark = Color(0xFF1E293B);

  // Arena Glows & Ambience
  static const Color arenaRingLight = Color(0xFFE0E7FF);
  static const Color arenaRingDark = Color(0xFF1E293B);
  static const Color arenaPulseBlue = Color(0xFF38BDF8);
  static const Color arenaPulseBreak = Color(0xFFFB923C);

  // Typography Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Semantic Mappings & Compatibility
  static const Color primaryBlue = brandBlue;
  static const Color primaryNavy = brandBlue;
  static const Color primaryNavyDark = brandBlueDark;
  static const Color primaryNavyLight = brandBlueLight;

  static const Color successEmerald = gamifyEmerald;
  static const Color accentIndigo = Color(0xFF4F46E5);
  static const Color accentIndigoLight = Color(0xFFEEF2FF);
  static const Color accentCyan = brandCyan;
  static const Color warningOrange = streakOrange;
  static const Color warningOrangeDark = streakOrangeDark;

  static const Color purpleProgram = gamifyPurple;
  static const Color purpleProgramLight = gamifyPurpleLight;

  static const Color academicAmber = gamifyYellow;
  static const Color academicAmberDark = gamifyYellowDark;
  static const Color academicAmberLight = gamifyYellowLight;

  static const Color errorRose = dangerRed;
  static const Color errorRoseDark = dangerRedDark;
  static const Color errorRoseLight = dangerRedLight;

  static const Color successGreen = gamifyEmerald;
  static const Color successGreenDark = gamifyEmeraldDark;
  static const Color successGreenLight = gamifyEmeraldLight;

  static const Color surfaceElevatedLight = surfaceLight;

  // Course Tile Distinctive Accent Colors
  static const List<Color> courseColors = [
    Color(0xFF2563EB), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFF10B981), // Emerald
    Color(0xFFF97316), // Orange
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
  ];
}
