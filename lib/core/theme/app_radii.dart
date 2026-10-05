import 'package:flutter/material.dart';

/// Centralized border radii tokens for UniFocus.
/// Avoids "everything is a giant pill" look with intentional geometric hierarchy.
class AppRadii {
  AppRadii._();

  static const double xs = 6.0;
  static const double sm = 10.0;
  static const double md = 14.0;
  static const double lg = 20.0;
  static const double xl = 28.0;
  static const double xxl = 36.0;
  static const double pill = 999.0;
  static const double circular = 1000.0;

  // BorderRadius helpers
  static final BorderRadius roundedXs = BorderRadius.circular(xs);
  static final BorderRadius roundedSm = BorderRadius.circular(sm);
  static final BorderRadius roundedMd = BorderRadius.circular(md);
  static final BorderRadius roundedLg = BorderRadius.circular(lg);
  static final BorderRadius roundedXl = BorderRadius.circular(xl);
  static final BorderRadius roundedXxl = BorderRadius.circular(xxl);
  static final BorderRadius roundedPill = BorderRadius.circular(pill);

  // Top/Bottom sheets and dialogs
  static final BorderRadius sheetTop = const BorderRadius.vertical(top: Radius.circular(xl));
}
