import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  //Primary
  static const Color primary = Color(0xFF000000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C1B1B);
  static const Color onPrimaryContainer = Color(0xFF858383);
  static const Color inversePrimary = Color(0xFFC8C6C5);

  //Secondary (Accent – Indigo)
  static const Color secondary = Color(0xFF4648D4);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF6063EE);
  static const Color onSecondaryContainer = Color(0xFFFFFBFF);

  //Tertiary
  static const Color tertiary = Color(0xFF000000);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF1C1B1A);
  static const Color onTertiaryContainer = Color(0xFF868381);

  //Error
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);

  //Surface
  static const Color surface = Color(0xFFF8F9FA);
  static const Color surfaceDim = Color(0xFFD9DADB);
  static const Color surfaceBright = Color(0xFFF8F9FA);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F4F5);
  static const Color surfaceContainer = Color(0xFFEDEEEF);
  static const Color surfaceContainerHigh = Color(0xFFE7E8E9);
  static const Color surfaceContainerHighest = Color(0xFFE1E3E4);
  static const Color onSurface = Color(0xFF191C1D);
  static const Color onSurfaceVariant = Color(0xFF444748);
  static const Color inverseSurface = Color(0xFF2E3132);
  static const Color inverseOnSurface = Color(0xFFF0F1F2);
  static const Color surfaceTint = Color(0xFF5F5E5E);

  //Outline
  static const Color outline = Color(0xFF747878);
  static const Color outlineVariant = Color(0xFFC4C7C7);

  //Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color onBackground = Color(0xFF191C1D);

  //Surface Variant
  static const Color surfaceVariant = Color(0xFFE1E3E4);

  //Fixed (for chips / tags / badges)
  static const Color primaryFixed = Color(0xFFE5E2E1);
  static const Color primaryFixedDim = Color(0xFFC8C6C5);
  static const Color onPrimaryFixed = Color(0xFF1C1B1B);
  static const Color onPrimaryFixedVariant = Color(0xFF474646);

  static const Color secondaryFixed = Color(0xFFE1E0FF);
  static const Color secondaryFixedDim = Color(0xFFC0C1FF);
  static const Color onSecondaryFixed = Color(0xFF07006C);
  static const Color onSecondaryFixedVariant = Color(0xFF2F2EBE);

  static const Color tertiaryFixed = Color(0xFFE6E1DF);
  static const Color tertiaryFixedDim = Color(0xFFCAC6C3);
  static const Color onTertiaryFixed = Color(0xFF1C1B1A);
  static const Color onTertiaryFixedVariant = Color(0xFF484645);
}
