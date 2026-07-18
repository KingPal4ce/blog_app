import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  //Font Families
  static const String _headingFamily = 'Manrope';
  static const String _bodyFamily = 'Source Serif 4';

  //Display
  static const TextStyle display = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 48,
    fontWeight: FontWeight.w800,
    height: 56 / 48,
    letterSpacing: -0.04,
  );

  //Headlines
  static const TextStyle headlineLg = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.02,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32 / 24,
  );

  //Body
  static const TextStyle bodyLg = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 32 / 20,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: _bodyFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 28 / 17,
  );

  //Labels
  static const TextStyle labelMd = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: 0.02,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: _headingFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: 0.05,
  );
}
