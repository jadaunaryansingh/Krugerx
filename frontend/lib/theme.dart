import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/tokens.dart';

/// KrugerX Design System
class KrugerXTheme {
  KrugerXTheme._();

  // ── Colors for direct access (Backwards compatibility) ──────────────────
  static const primary       = Color(0xFFC9A038);
  static const secondary     = Color(0xFF8B2F3A);
  static const tertiary      = Color(0xFF2D5A3D);
  static const onSurface     = Color(0xFFF0EDE6);
  static const surfaceContainer = Color(0xFF272727);
  static const electricLight = Color(0xFFDABF6E);
  static const incognitoColor = Color(0xFF3D7A52);

  static const brassGradient = LinearGradient(
    colors: [primary, electricLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Theme Data ─────────────────────────────────────────────────────────
  static ThemeData get dark {
    final bodyFont = GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFFF0EDE6), letterSpacing: -0.5),
        titleLarge:   TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFF0EDE6), letterSpacing: -0.3),
        titleMedium:  TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: Color(0xFFF0EDE6)),
        titleSmall:   TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF0EDE6)),
        bodyLarge:    TextStyle(fontSize: 14, color: Color(0xFFF0EDE6)),
        bodyMedium:   TextStyle(fontSize: 13, color: Color(0xFF8A8680)),
        bodySmall:    TextStyle(fontSize: 11, color: Color(0xFF8A8680)),
        labelLarge:   TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFFF0EDE6), letterSpacing: 0.1),
        labelMedium:  TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF8A8680)),
        labelSmall:   TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: Color(0xFF8A8680), letterSpacing: 0.8),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KrugerColors.dark.bg,
      fontFamily: GoogleFonts.inter().fontFamily,
      extensions: const [KrugerColors.dark],
      colorScheme: ColorScheme.dark(
        primary: KrugerColors.dark.gold,
        surface: KrugerColors.dark.surface1,
        onSurface: KrugerColors.dark.textPrimary,
        surfaceContainerLow: KrugerColors.dark.bg,
        surfaceContainer: KrugerColors.dark.surface2,
        surfaceContainerHigh: KrugerColors.dark.surface3,
        outline: KrugerColors.dark.border,
        error: KrugerColors.dark.danger,
      ),
      textTheme: bodyFont,
      // Minimal overrides, rely mostly on tokens
      appBarTheme: AppBarTheme(
        backgroundColor: KrugerColors.dark.surface1,
        foregroundColor: KrugerColors.dark.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      iconTheme: IconThemeData(color: KrugerColors.dark.textSecondary, size: 20),
    );
  }
}

