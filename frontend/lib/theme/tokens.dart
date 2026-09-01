import 'package:flutter/material.dart';

@immutable
class KrugerColors extends ThemeExtension<KrugerColors> {
  const KrugerColors({
    required this.bg,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.gold,
    required this.goldGlow,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.safe,
    required this.warning,
    required this.danger,
  });

  final Color bg;          // #141414
  final Color surface1;    // #1E1E1E — tab bar, sidebar
  final Color surface2;    // #272727 — menus, dropdowns, address bar fill
  final Color surface3;    // #313131 — hover / selected state
  final Color gold;        // #C9A038 — brand accent
  final Color goldGlow;    // rgba(201,160,56,0.15)
  final Color textPrimary;   // #F0EDE6 — warm white, never pure #FFFFFF
  final Color textSecondary; // #8A8680
  final Color border;        // rgba(255,255,255,0.07)
  final Color safe;          // #4CAF6E — HTTPS / synced
  final Color warning;       // #D4A017 — mixed content
  final Color danger;        // #E05252 — insecure / errors

  static const dark = KrugerColors(
    bg: Color(0xFF141414),
    surface1: Color(0xFF1E1E1E),
    surface2: Color(0xFF272727),
    surface3: Color(0xFF313131),
    gold: Color(0xFFC9A038),
    goldGlow: Color(0x26C9A038),
    textPrimary: Color(0xFFF0EDE6),
    textSecondary: Color(0xFF8A8680),
    border: Color(0x12FFFFFF),
    safe: Color(0xFF4CAF6E),
    warning: Color(0xFFD4A017),
    danger: Color(0xFFE05252),
  );

  @override
  KrugerColors copyWith({
    Color? bg,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? gold,
    Color? goldGlow,
    Color? textPrimary,
    Color? textSecondary,
    Color? border,
    Color? safe,
    Color? warning,
    Color? danger,
  }) {
    return KrugerColors(
      bg: bg ?? this.bg,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      gold: gold ?? this.gold,
      goldGlow: goldGlow ?? this.goldGlow,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      border: border ?? this.border,
      safe: safe ?? this.safe,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
    );
  }

  @override
  KrugerColors lerp(ThemeExtension<KrugerColors>? other, double t) {
    if (other is! KrugerColors) {
      return this;
    }
    return KrugerColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      gold: Color.lerp(gold, other.gold, t)!,
      goldGlow: Color.lerp(goldGlow, other.goldGlow, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      border: Color.lerp(border, other.border, t)!,
      safe: Color.lerp(safe, other.safe, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
