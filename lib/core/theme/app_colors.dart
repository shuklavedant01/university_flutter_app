import 'package:flutter/material.dart';

/// Veritas Academic & Campus Core color palette definition based on DESIGN.md
abstract class AppColors {
  // Core Oxford Navy & Crimson Brand Roles
  static const Color primary = Color(0xFF0F2942);
  static const Color primaryDark = Color(0xFF001428);
  static const Color primaryContainer = Color(0xFF0F2942);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF7991AF);

  static const Color secondary = Color(0xFF8B1E3F); // Collegiate Crimson
  static const Color secondaryLight = Color(0xFFA73453);
  static const Color secondaryContainer = Color(0xFFFFD9DE);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF74092F);

  static const Color tertiary = Color(0xFFC5832B); // Scholarly Amber
  static const Color tertiaryContainer = Color(0xFF3B2200);
  static const Color tertiaryFixed = Color(0xFFFFDDB9);
  static const Color tertiaryFixedDim = Color(0xFFFFB964);
  static const Color onTertiary = Color(0xFFFFFFFF);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceLow = Color(0xFFEFF4FF);
  static const Color surfaceContainer = Color(0xFFF1F5F9);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color surfaceContainerHighest = Color(0xFFD5E3FC);

  // Typography & Content Colors
  static const Color onSurface = Color(0xFF0D1C2E);
  static const Color onSurfaceVariant = Color(0xFF475569);
  static const Color outline = Color(0xFF74777E);
  static const Color outlineVariant = Color(0xFFC3C6CE);

  // Status & Accents
  static const Color success = Color(0xFF15803D); // Forest Green
  static const Color successContainer = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFB45309); // Burnished Ochre
  static const Color warningContainer = Color(0xFFFEF3C7);
  static const Color urgentCrimson = Color(0xFF991B1B);
  static const Color errorContainer = Color(0xFFFEE2E2);

  static const Color cardShadow = Color(0x0A0F2942);
}
