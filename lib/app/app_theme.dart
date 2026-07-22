import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:blog_app/app/app_colors.dart';
import 'package:blog_app/app/app_typography.dart';

class AppTheme {
  AppTheme._();

  //Border Radii (from design spec)
  static const double _radiusSm = 2;
  static const double _radiusDefault = 4;
  static const double _radiusLg = 8;
  static const double _radiusXl = 12;

  //Light Theme
  static ThemeData get light {
    const ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      onPrimaryContainer: AppColors.onPrimaryContainer,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      secondaryContainer: AppColors.secondaryContainer,
      onSecondaryContainer: AppColors.onSecondaryContainer,
      tertiary: AppColors.tertiary,
      onTertiary: AppColors.onTertiary,
      tertiaryContainer: AppColors.tertiaryContainer,
      onTertiaryContainer: AppColors.onTertiaryContainer,
      error: AppColors.error,
      onError: AppColors.onError,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.onErrorContainer,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      shadow: Colors.black,
      inverseSurface: AppColors.inverseSurface,
      onInverseSurface: AppColors.inverseOnSurface,
      surfaceTint: AppColors.surfaceTint,
      inversePrimary: AppColors.inversePrimary,
      surfaceContainerHighest: AppColors.surfaceVariant,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,

      //Typography
      textTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelLarge: AppTypography.labelMd,
        labelMedium: AppTypography.labelSm,
      ),
      primaryTextTheme: const TextTheme(
        displayLarge: AppTypography.display,
        headlineLarge: AppTypography.headlineLg,
        headlineMedium: AppTypography.headlineMd,
        bodyLarge: AppTypography.bodyLg,
        bodyMedium: AppTypography.bodyMd,
        labelLarge: AppTypography.labelMd,
        labelMedium: AppTypography.labelSm,
      ),

      //AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Manrope',
          fontSize: 24,
          fontWeight: FontWeight.w900,
          color: AppColors.onSurface,
          letterSpacing: -0.01,
        ),
      ),

      //Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
          ),
          textStyle: AppTypography.labelMd.copyWith(color: AppColors.onPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
          ),
          side: const BorderSide(color: AppColors.primary, width: 1),
          textStyle: AppTypography.labelMd.copyWith(color: AppColors.primary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
          ),
          textStyle: AppTypography.labelMd.copyWith(color: AppColors.primary),
        ),
      ),

      //Input Fields
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.outline,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),

      //Card
      cardTheme: const CardThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusLg)),
          side: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),

      //Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      //Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        side: BorderSide.none,
        labelStyle: AppTypography.labelSm.copyWith(color: AppColors.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusSm)),
        ),
      ),

      //Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // Navigation Bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryFixed,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSm.copyWith(color: AppColors.primary);
          }
          return AppTypography.labelSm.copyWith(color: AppColors.outline);
        }),
      ),

      //List Tile
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurface,
        ),
        subtitleTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),

      //Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.inverseSurface,
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.inverseOnSurface,
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      //Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusLg)),
        ),
        titleTextStyle: AppTypography.headlineMd.copyWith(
          color: AppColors.onSurface,
        ),
        contentTextStyle: AppTypography.bodyMd.copyWith(
          color: AppColors.onSurfaceVariant,
        ),
      ),

      //Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(_radiusXl)),
        ),
      ),

      //Tab Bar
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.outline,
        indicatorColor: AppColors.primary,
        labelStyle: AppTypography.labelMd,
        unselectedLabelStyle: AppTypography.labelMd,
        dividerColor: AppColors.outlineVariant,
      ),

      //Progress Indicator
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceContainerHigh,
      ),

      //Popup Menu
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.surfaceContainerLowest,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_radiusDefault)),
          side: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
        textStyle: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
      ),
    );
  }
}
