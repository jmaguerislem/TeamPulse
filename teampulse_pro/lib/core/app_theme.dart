import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_palette.dart';

class AppTheme {
  static InputDecorationTheme _inputTheme(AppPalette p) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: c, width: w),
    );
    return InputDecorationTheme(
      filled: true,
      fillColor: p.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: TextStyle(color: p.soft),
      errorStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
      border: border(p.outline),
      enabledBorder: border(p.outline),
      focusedBorder: border(AppColors.primary, 2),
      errorBorder: border(p.coralInk),
      focusedErrorBorder: border(p.coralInk, 2),
    );
  }

  static TextTheme _textTheme(AppPalette p) {
    return TextTheme(
      headlineLarge: GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: p.ink,
        height: 1.15,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      titleMedium: GoogleFonts.dmSans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
      bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: p.ink, height: 1.4),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: p.soft, height: 1.45),
      bodySmall: GoogleFonts.dmSans(fontSize: 12, color: p.soft),
      labelLarge: GoogleFonts.dmSans(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: p.ink,
      ),
    );
  }

  static ThemeData _build(AppPalette p, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
      primary: p.isDark ? p.primaryInk : AppColors.primary,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.background,
      colorScheme: scheme,
      extensions: [p],
      textTheme: _textTheme(p),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: p.ink),
      ),
      inputDecorationTheme: _inputTheme(p),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.isDark ? p.cardAlt : AppColors.navy,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        actionTextColor: const Color(0xFFB9B0FF),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  static ThemeData get light => _build(AppPalette.light, Brightness.light);
  static ThemeData get dark => _build(AppPalette.dark, Brightness.dark);
}
