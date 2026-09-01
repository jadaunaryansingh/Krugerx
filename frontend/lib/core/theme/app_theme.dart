import 'package:flutter/material.dart';
import 'design_system.dart';

/// Krugerx Theme — strictly derived from the Stitch design language.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: DesignSystem.primary,
      onPrimary: DesignSystem.onPrimary,
      primaryContainer: DesignSystem.primaryContainer,
      onPrimaryContainer: DesignSystem.onPrimaryContainer,
      secondary: DesignSystem.secondary,
      onSecondary: DesignSystem.onSecondary,
      secondaryContainer: DesignSystem.secondaryContainer,
      onSecondaryContainer: DesignSystem.onSecondaryContainer,
      tertiary: DesignSystem.tertiary,
      onTertiary: DesignSystem.onTertiary,
      tertiaryContainer: DesignSystem.tertiaryContainer,
      onTertiaryContainer: DesignSystem.onTertiaryContainer,
      error: DesignSystem.error,
      onError: DesignSystem.onError,
      errorContainer: DesignSystem.errorContainer,
      onErrorContainer: DesignSystem.onErrorContainer,
      surface: DesignSystem.surface,
      onSurface: DesignSystem.onSurface,
      onSurfaceVariant: DesignSystem.onSurfaceVariant,
      surfaceContainerLowest: DesignSystem.surfaceContainerLowest,
      surfaceContainerLow: DesignSystem.surfaceContainerLow,
      surfaceContainer: DesignSystem.surfaceContainer,
      surfaceContainerHigh: DesignSystem.surfaceContainerHigh,
      surfaceContainerHighest: DesignSystem.surfaceContainerHighest,
      outline: DesignSystem.outline,
      outlineVariant: DesignSystem.outlineVariant,
      inverseSurface: DesignSystem.inverseSurface,
      onInverseSurface: DesignSystem.inverseOnSurface,
      inversePrimary: DesignSystem.inversePrimary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: DesignSystem.background,
      fontFamily: DesignSystem.fontFamilyHanken,

      // ── AppBar ──────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: DesignSystem.surface,
        foregroundColor: DesignSystem.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: DesignSystem.titleMd.copyWith(color: DesignSystem.onSurface),
        shape: const Border(
          bottom: BorderSide(color: DesignSystem.outlineVariant, width: 1),
        ),
      ),

      // ── Divider ─────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: DesignSystem.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Card ────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: DesignSystem.surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusXl),
          side: const BorderSide(color: DesignSystem.outlineVariant),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // ── Input Decoration ────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: DesignSystem.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMarginMobile, 
          vertical: DesignSystem.spacingSm,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          borderSide: const BorderSide(color: DesignSystem.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          borderSide: const BorderSide(color: DesignSystem.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          borderSide: const BorderSide(color: DesignSystem.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          borderSide: BorderSide(color: DesignSystem.error.withValues(alpha: 0.6)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          borderSide: const BorderSide(color: DesignSystem.error, width: 1.5),
        ),
        hintStyle: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
        labelStyle: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurfaceVariant),
        prefixIconColor: DesignSystem.onSurfaceVariant,
        suffixIconColor: DesignSystem.onSurfaceVariant,
      ),

      // ── Filled Button ───────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DesignSystem.primary,
          foregroundColor: DesignSystem.onPrimary,
          disabledBackgroundColor: DesignSystem.primary.withValues(alpha: 0.3),
          disabledForegroundColor: DesignSystem.onPrimary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          ),
          textStyle: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSystem.spacingMd, 
            vertical: DesignSystem.spacingSm,
          ),
        ),
      ),

      // ── Text Button ─────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: DesignSystem.primary,
          textStyle: DesignSystem.bodyMd.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // ── Icon Button ─────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: DesignSystem.onSurfaceVariant,
          hoverColor: DesignSystem.primary.withValues(alpha: 0.08),
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: DesignSystem.primary,
        foregroundColor: DesignSystem.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
        ),
      ),

      // ── ListTile ────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        textColor: DesignSystem.onSurface,
        iconColor: DesignSystem.onSurfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusXl),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DesignSystem.spacingMarginMobile, 
          vertical: DesignSystem.spacingXs,
        ),
      ),

      // ── Switch ──────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return DesignSystem.primary;
          return DesignSystem.onSurfaceVariant;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return DesignSystem.primaryContainer;
          }
          return DesignSystem.surfaceContainerHighest;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Progress Indicator ──────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: DesignSystem.primary,
        linearTrackColor: DesignSystem.surfaceContainerHighest,
        circularTrackColor: DesignSystem.surfaceContainerHighest,
      ),

      // ── SnackBar ────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: DesignSystem.surfaceContainer,
        contentTextStyle: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radiusLg),
          side: const BorderSide(color: DesignSystem.outlineVariant),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Text Theme ──────────────────────────────────────────────────
      textTheme: TextTheme(
        displayLarge: DesignSystem.displayLg.copyWith(color: DesignSystem.onSurface),
        headlineLarge: DesignSystem.headlineLg.copyWith(color: DesignSystem.onSurface),
        headlineMedium: DesignSystem.headlineLgMobile.copyWith(color: DesignSystem.onSurface),
        titleLarge: DesignSystem.titleMd.copyWith(color: DesignSystem.onSurface),
        bodyLarge: DesignSystem.bodyLg.copyWith(color: DesignSystem.onSurface),
        bodyMedium: DesignSystem.bodyMd.copyWith(color: DesignSystem.onSurface),
        bodySmall: DesignSystem.labelCaps.copyWith(color: DesignSystem.onSurfaceVariant),
        labelLarge: DesignSystem.dataMono.copyWith(color: DesignSystem.onSurface),
      ),
    );
  }
}
