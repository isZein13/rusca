import 'package:flutter/material.dart';

class RuscaColors {
  static const paper = Color(0xFFF4EFE6);
  static const card = Color(0xFFFFFCF8);
  static const cardAlt = Color(0xFFE8E0D4);
  static const line = Color(0xFFDDD3C5);
  static const ink = Color(0xFF1C1916);
  static const muted = Color(0xFF6F675C);
  static const stamp = Color(0xFFB42318);
  static const ok = Color(0xFF1F7A4D);
  static const no = Color(0xFFB42318);
  static const accent = stamp;
  static const blue = ink;
}

class RuscaType {
  static const page = TextStyle(
    fontSize: 28,
    height: 1.1,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: RuscaColors.ink,
  );
  static const kicker = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    color: RuscaColors.stamp,
  );
}

ThemeData buildRuscaTheme() {
  const scheme = ColorScheme.light(
    primary: RuscaColors.ink,
    onPrimary: Colors.white,
    secondary: RuscaColors.stamp,
    surface: RuscaColors.card,
    error: RuscaColors.no,
    onSurface: RuscaColors.ink,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: RuscaColors.paper,
    splashFactory: InkRipple.splashFactory,
    dividerColor: RuscaColors.line,
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: RuscaColors.ink, height: 1.35, fontSize: 15),
      titleLarge: RuscaType.page,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RuscaColors.ink,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RuscaColors.ink,
        backgroundColor: RuscaColors.card,
        minimumSize: const Size.fromHeight(52),
        side: const BorderSide(color: RuscaColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}

class PaperCard extends StatelessWidget {
  const PaperCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(22, 22, 22, 16),
    this.borderColor = RuscaColors.line,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: RuscaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
