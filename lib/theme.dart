import 'package:flutter/material.dart';

class RuscaColors {
  static const bg = Color(0xFF0E1116);
  static const card = Color(0xFF1A2130);
  static const cardAlt = Color(0xFF232C3D);
  static const accent = Color(0xFFF4C15D);
  static const ok = Color(0xFF3DDC97);
  static const no = Color(0xFFFF6B6B);
  static const muted = Color(0xFF9AA3B5);
}

ThemeData buildRuscaTheme() {
  const scheme = ColorScheme.dark(
    primary: RuscaColors.accent,
    secondary: RuscaColors.ok,
    surface: RuscaColors.card,
    error: RuscaColors.no,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: RuscaColors.bg,
    appBarTheme: const AppBarTheme(
      backgroundColor: RuscaColors.bg,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: RuscaColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
  );
}
