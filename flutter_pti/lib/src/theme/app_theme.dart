import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _bg = Color(0xFF0f0f11);
  static const _panel = Color(0xFF18181b);
  static const _surface = Color(0xFF27272a);
  static const _primary = Color(0xFFF43F5E);
  static const _secondary = Color(0xFF06B6D4);
  static const _text = Color(0xFFE4E4E7);

  static ThemeData theme() {
    final colorScheme = const ColorScheme.dark(
      primary: _primary,
      secondary: _secondary,
      surface: _panel,
      error: Color(0xFFF97316),
    ).copyWith(
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: _text,
    );

    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: _bg,
      colorScheme: colorScheme,
    );

    final textTheme = GoogleFonts.manropeTextTheme(base.textTheme).apply(
      bodyColor: _text,
      displayColor: _text,
    );

    return base.copyWith(
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: _text,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: _text),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .08), width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _secondary, width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        labelStyle: textTheme.bodyMedium?.copyWith(color: Colors.white70, letterSpacing: .6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.1),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surface,
        selectedColor: _secondary,
        labelStyle: textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: .8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      cardTheme: CardThemeData(
        color: _panel,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _secondary,
        behavior: SnackBarBehavior.floating,
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
      dividerColor: Colors.white12,
      extensions: const <ThemeExtension<dynamic>>[
        StatusColors(
          income: Color(0xFF34D399),
          expense: Color(0xFFF87171),
        ),
      ],
    );
  }
}

class StatusColors extends ThemeExtension<StatusColors> {
  final Color income;
  final Color expense;

  const StatusColors({
    this.income = const Color(0xFF34D399),
    this.expense = const Color(0xFFF87171),
  });

  @override
  ThemeExtension<StatusColors> copyWith({Color? income, Color? expense}) {
    return StatusColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
    );
  }

  @override
  ThemeExtension<StatusColors> lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      income: Color.lerp(income, other.income, t) ?? income,
      expense: Color.lerp(expense, other.expense, t) ?? expense,
    );
  }
}
