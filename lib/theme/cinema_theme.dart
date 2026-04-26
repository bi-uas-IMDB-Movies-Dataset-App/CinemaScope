import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/cinema_colors.dart';

class CinemaTheme {
  static ThemeData dark() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: CinemaColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: CinemaColors.gold,
        secondary: CinemaColors.accent,
        surface: CinemaColors.surface,
        onPrimary: Colors.black,
        onSurface: CinemaColors.textPrimary,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: CinemaColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: CinemaColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: CinemaColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: CinemaColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: CinemaColors.textMuted,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: CinemaColors.surface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: CinemaColors.gold,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: CinemaColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: CinemaColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: CinemaColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CinemaColors.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CinemaColors.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: CinemaColors.gold, width: 1.5),
        ),
        labelStyle: const TextStyle(color: CinemaColors.textSecondary),
        hintStyle: const TextStyle(color: CinemaColors.textMuted),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CinemaColors.gold,
          foregroundColor: Colors.black,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: CinemaColors.card,
        selectedColor: CinemaColors.gold.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: CinemaColors.textSecondary, fontSize: 12),
        side: const BorderSide(color: CinemaColors.divider),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      dividerTheme: const DividerThemeData(
        color: CinemaColors.divider,
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: CinemaColors.surface,
        selectedItemColor: CinemaColors.gold,
        unselectedItemColor: CinemaColors.textMuted,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedIconTheme: const IconThemeData(size: 24),
        unselectedIconTheme: const IconThemeData(size: 22),
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 11),
      ),
    );
  }
}

