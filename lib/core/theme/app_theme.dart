import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// App theme implementing PRD "2025 Deep Focus" style
/// - Dark mode default (Zinc-900 background)
/// - Electric Lime (#BFFF0B) accents
/// - Inter font family
/// - Minimalist design
class AppTheme {
  // Color palette
  static const Color zinc900 = Color(0xFF18181B);
  static const Color zinc800 = Color(0xFF27272A);
  static const Color zinc700 = Color(0xFF3F3F46);
  static const Color zinc600 = Color(0xFF52525B);
  static const Color zinc500 = Color(0xFF71717A);
  static const Color zinc400 = Color(0xFFA1A1AA);
  static const Color zinc300 = Color(0xFFD4D4D8);
  static const Color zinc200 = Color(0xFFE4E4E7);
  static const Color zinc100 = Color(0xFFF4F4F5);

  static const Color electricLime = Color(0xFFBFFF0B);
  static const Color electricLimeDark = Color(0xFFA3D909);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: electricLime,
        onPrimary: zinc900,
        secondary: electricLime,
        onSecondary: zinc900,
        surface: zinc900,
        onSurface: zinc100,
      ),

      // Scaffold
      scaffoldBackgroundColor: zinc900,

      // Text theme using Inter font
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: zinc100,
          displayColor: zinc100,
        ),
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: zinc900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: zinc100,
        ),
        iconTheme: const IconThemeData(color: zinc300),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: zinc800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: zinc300,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: electricLime,
          foregroundColor: zinc900,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: zinc100,
          side: const BorderSide(color: zinc700),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: zinc800,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: zinc700),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: zinc700),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: electricLime, width: 2),
        ),
        hintStyle: GoogleFonts.inter(color: zinc500),
      ),

      // Dialog theme
      dialogTheme: DialogThemeData(
        backgroundColor: zinc800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: zinc700,
        thickness: 1,
      ),
    );
  }
}
