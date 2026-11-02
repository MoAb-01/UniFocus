import 'package:flutter/material.dart';

/// Centralized Tactile Analog Palette for UniFocus matching `code.txt`.
class AppColors {
  AppColors._();

  // --- Exact Color Tokens from `code.txt` ---
  static const Color surface = Color(0xFFFFF8F6); // #fff8f6
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF); // #ffffff
  static const Color surfaceContainerLow = Color(0xFFFFF1EC); // #fff1ec
  static const Color surfaceContainer = Color(0xFFF9EBE6); // #f9ebe6
  static const Color surfaceContainerHigh = Color(0xFFF3E5E0); // #f3e5e0
  static const Color surfaceVariant = Color(0xFFEDE0DB); // #ede0db
  static const Color onSurface = Color(0xFF211A17); // #211a17
  static const Color onSurfaceVariant = Color(0xFF424842); // #424842
  static const Color outline = Color(0xFF727971); // #727971
  static const Color outlineVariant = Color(0xFFC1C8C0); // #c1c8c0

  static const Color primary = Color(0xFF163C24); // #163c24 (Deep forest green)
  static const Color primaryContainer = Color(0xFF2E5339); // #2e5339
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryFixed = Color(0xFF00210E); // #00210e (button ledge shadow)
  static const Color onPrimaryFixedVariant = Color(0xFF294E35); // #294e35
  static const Color primaryFixed = Color(0xFFC2EDCA); // #c2edca (Mint badge fill)

  static const Color secondary = Color(0xFF994703); // #994703 (Rust brown text)
  static const Color secondaryContainer = Color(0xFFFC934F); // #fc934f (Terracotta clock ring & accents)
  static const Color onSecondaryContainer = Color(0xFF6D3000); // #6d3000
  static const Color secondaryFixed = Color(0xFFFFDBC9); // #ffdbc9 (Washi tape & date badge fill)
  static const Color secondaryFixedDim = Color(0xFFFFB68C); // #ffb68c (Brass paperclip)
  static const Color onSecondaryFixedVariant = Color(0xFF753400); // #753400

  static const Color tertiary = Color(0xFF223261); // #223261
  static const Color tertiaryContainer = Color(0xFF3A497A); // #3a497a (Navy audio/arena icon box)
  static const Color onTertiary = Color(0xFFFFFFFF);

  // --- Tactile Analog Desk aliases ---
  static const Color paperBg = surface;
  static const Color cardstock = surfaceContainerLow;
  static const Color cardstockSubtle = surfaceContainer;
  static const Color inkBorder = onSurface;
  static const Color inkBorderLight = outlineVariant;
  static const Color inkDivider = surfaceVariant;
  static const Color inkPrimary = onSurface;
  static const Color inkSecondary = onSurfaceVariant;
  static const Color inkTertiary = outline;
  static const Color deepWorkGreen = primary;
  static const Color deepWorkGreenHover = primaryContainer;
  static const Color terracottaBreak = secondaryContainer;
  static const Color warmAmber = secondaryContainer;
  static const Color lavenderArena = tertiaryContainer;
  static const Color hardShadow = onSurface;

  // Backward compatibility mappings
  static const Color backgroundLight = surface;
  static const Color surfaceLight = surfaceContainerLow;
  static const Color surfaceSubtle = surfaceContainer;
  static const Color borderLight = outlineVariant;
  static const Color dividerLight = surfaceVariant;

  static const Color textPrimaryLight = onSurface;
  static const Color textSecondaryLight = onSurfaceVariant;
  static const Color textMutedLight = outline;

  static const Color brandOrange = secondaryContainer;
  static const Color brandOrangeDark = secondary;
  static const Color brandOrangeLight = secondaryFixed;
  static const Color brandOrangeGlow = secondaryContainer;

  static const Color brandBlue = primary;
  static const Color brandBlueDark = onPrimaryFixed;
  static const Color brandBlueLight = primaryFixed;
  static const Color brandCyan = tertiaryContainer;

  // Isometric Room Environment Tones
  static const Color roomFloorLight = Color(0xFFEFE8DD);
  static const Color roomFloorDark = Color(0xFF26211E);
  static const Color roomWallLight = Color(0xFFF8F5EE);
  static const Color roomWallDark = Color(0xFF1F1A18);
  static const Color roomWallAccentLight = Color(0xFFE8DFD3);
  static const Color roomWallAccentDark = Color(0xFF2D2623);
  static const Color roomDeskLight = Color(0xFFDFCDB5);
  static const Color roomDeskDark = Color(0xFF3B3029);
  static const Color roomChairDark = Color(0xFF382F2A);

  // Accents & Gamification
  static const Color gamifyPurple = tertiaryContainer;
  static const Color gamifyPurpleDark = tertiary;
  static const Color gamifyPurpleLight = Color(0xFFDBE1FF);

  static const Color gamifyEmerald = primary;
  static const Color gamifyEmeraldDark = onPrimaryFixed;
  static const Color gamifyEmeraldLight = primaryFixed;

  static const Color streakOrange = secondaryContainer;
  static const Color streakOrangeDark = secondary;
  static const Color streakOrangeLight = secondaryFixed;

  static const Color gamifyYellow = secondaryContainer;
  static const Color gamifyYellowDark = secondary;
  static const Color gamifyYellowLight = secondaryFixed;

  static const Color dangerRed = Color(0xFFBA1A1A);
  static const Color dangerRedDark = Color(0xFF93000A);
  static const Color dangerRedLight = Color(0xFFFFDAD6);

  // Status Ring Colors (for Study Arena participants)
  static const Color statusStudying = primary;
  static const Color statusBreak = secondaryContainer;
  static const Color statusNeedHelp = tertiaryContainer;
  static const Color statusGoalProgress = secondary;
  static const Color statusLeavingSoon = onSurfaceVariant;

  // Program Indicators
  static const Color mainProgramColor = primary;
  static const Color capProgramColor = tertiaryContainer;
  static const Color yandalProgramColor = secondaryContainer;

  // Intentional Dark Mode Surfaces
  static const Color backgroundDark = Color(0xFF1B1715);
  static const Color surfaceDark = Color(0xFF241F1D);
  static const Color surfaceElevatedDark = Color(0xFF2E2724);
  static const Color borderDark = Color(0xFF423935);
  static const Color dividerDark = Color(0xFF352D29);

  static const Color textPrimaryDark = Color(0xFFFFF8F6);
  static const Color textSecondaryDark = Color(0xFFC4BBB2);
  static const Color textMutedDark = Color(0xFF8F857D);

  // Arena Glows & Ambience
  static const Color arenaRingLight = surfaceContainer;
  static const Color arenaRingDark = Color(0xFF2E2724);
  static const Color arenaPulseBlue = tertiaryContainer;
  static const Color arenaPulseBreak = secondaryContainer;

  // Semantic Mappings & Compatibility
  static const Color primaryBlue = primary;
  static const Color primaryNavy = primary;
  static const Color primaryNavyDark = onPrimaryFixed;
  static const Color primaryNavyLight = primaryFixed;

  static const Color successEmerald = primary;
  static const Color accentIndigo = tertiaryContainer;
  static const Color accentIndigoLight = Color(0xFFDBE1FF);
  static const Color accentCyan = tertiaryContainer;
  static const Color warningOrange = secondaryContainer;
  static const Color warningOrangeDark = secondary;

  static const Color purpleProgram = tertiaryContainer;
  static const Color purpleProgramLight = Color(0xFFDBE1FF);

  static const Color academicAmber = secondaryContainer;
  static const Color academicAmberDark = secondary;
  static const Color academicAmberLight = secondaryFixed;

  static const Color errorRose = dangerRed;
  static const Color errorRoseDark = dangerRedDark;
  static const Color errorRoseLight = dangerRedLight;

  static const Color successGreen = primary;
  static const Color successGreenDark = onPrimaryFixed;
  static const Color successGreenLight = primaryFixed;

  static const Color surfaceElevatedLight = surfaceContainerLow;

  // Course Tile Distinctive Accent Colors
  static const List<Color> courseColors = [
    Color(0xFF163C24), // Deep Forest Green
    Color(0xFF3A497A), // Navy
    Color(0xFFFC934F), // Terracotta
    Color(0xFF994703), // Rust Brown
    Color(0xFF2E5339), // Moss Green
    Color(0xFF223261), // Midnight Blue
  ];
}
