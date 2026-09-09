import 'package:flutter/material.dart';

class DesignSystem {
  DesignSystem._();

  // --- Colors ---
  static const Color background = Color(0xFF000000);
  static const Color surfaceContainerLowest = Color(0xFF050505);
  static const Color surfaceContainer = Color(0xFF111111);
  static const Color surface = Color(0xFF000000);
  static const Color surfaceContainerHighest = Color(0xFF1A1A1A);
  static const Color surfaceBright = Color(0xFF393939);
  static const Color surfaceContainerHigh = Color(0xFF222222);
  static const Color surfaceVariant = Color(0xFF222222);
  static const Color surfaceDim = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF0A0A0A);
  
  static const Color primary = Color(0xFFFF0000);
  static const Color primaryDim = Color(0xFF550000);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF220000);
  static const Color onPrimaryContainer = Color(0xFF75AF89); // kept from previous, though not heavily used
  static const Color primaryFixedDim = Color(0xFF98D4AC);
  static const Color primaryFixed = Color(0xFFFF0000);
  
  static const Color secondary = Color(0xFFC6C6C6);
  static const Color onSecondary = Color(0xFF2F3131);
  static const Color secondaryContainer = Color(0xFF484949);
  static const Color onSecondaryContainer = Color(0xFFB8B8B8);
  static const Color secondaryFixed = Color(0xFFE3E2E2);
  static const Color secondaryFixedDim = Color(0xFFC6C6C6);

  static const Color tertiary = Color(0xFFE3C0A6);
  static const Color onTertiary = Color(0xFF412C1A);
  static const Color tertiaryContainer = Color(0xFF4B3422);
  static const Color onTertiaryContainer = Color(0xFFBD9C84);
  static const Color tertiaryFixed = Color(0xFFFFDCC3);
  static const Color tertiaryFixedDim = Color(0xFFE3C0A6);

  static const Color error = Color(0xFFFF0000);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);
  
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFF777777);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);
  static const Color inversePrimary = Color(0xFF316948);
  
  static const Color outline = Color(0xFF333333);
  static const Color outlineVariant = Color(0xFF222222);

  // --- Spacing ---
  static const double spacingXs = 4.0;
  static const double spacingBase = 8.0;
  static const double spacingSm = 12.0;
  static const double spacingMarginMobile = 16.0;
  static const double spacingMd = 24.0;
  static const double spacingGutter = 24.0;
  static const double spacingLg = 48.0;
  static const double spacingMarginDesktop = 64.0;
  static const double spacingXl = 80.0;

  // --- Border Radius ---
  static const double radiusDefault = 2.0; // 0.125rem
  static const double radiusLg = 4.0; // 0.25rem
  static const double radiusXl = 8.0; // 0.5rem
  static const double radiusFull = 12.0; // 0.75rem (approx for small elements)
  
  // --- Text Styles ---
  static const String fontFamilyArchivo = 'Archivo Narrow';
  static const String fontFamilyHanken = 'Hanken Grotesk';
  static const String fontFamilyJetBrains = 'JetBrains Mono';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamilyArchivo,
    fontSize: 48,
    height: 52 / 48,
    letterSpacing: -0.02 * 48,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: fontFamilyArchivo,
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: fontFamilyArchivo,
    fontSize: 28,
    height: 34 / 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: fontFamilyArchivo,
    fontSize: 20,
    height: 28 / 20,
    letterSpacing: 0.05 * 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamilyHanken,
    fontSize: 18,
    height: 28 / 18,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamilyHanken,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle dataMono = TextStyle(
    fontFamily: fontFamilyJetBrains,
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.02 * 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: fontFamilyJetBrains,
    fontSize: 12,
    height: 16 / 12,
    letterSpacing: 0.1 * 12,
    fontWeight: FontWeight.w700,
  );

  // --- Brand & Status Colors (from Legacy KrugerXTheme) ---
  static const Color brandGold = Color(0xFFC9A038);
  static const Color brandGoldGlow = Color(0x26C9A038);
  static const Color electricLight = Color(0xFFDABF6E);
  static const Color incognitoColor = Color(0xFF3D7A52);
  
  static const Color statusSafe = Color(0xFF4CAF6E);
  static const Color statusWarning = Color(0xFFD4A017);
  static const Color statusDanger = Color(0xFFE05252);
  
  static const LinearGradient brandBrassGradient = LinearGradient(
    colors: [brandGold, electricLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Motion ---
  static const Duration motionFast = Duration(milliseconds: 80);
  static const Duration motionBase = Duration(milliseconds: 120);
  static const Duration motionSlow = Duration(milliseconds: 200);
  static const Curve motionCurve = Curves.easeOutCubic;
}
