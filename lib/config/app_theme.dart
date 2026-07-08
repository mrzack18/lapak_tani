import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Color Palette ──────────────────────────────────────────────────────
  static const Color _primaryColor = Color(0xFF2E7D32);
  static const Color _primaryLight = Color(0xFF60AD5E);
  static const Color _primaryDark = Color(0xFF005005);
  static const Color _secondaryColor = Color(0xFFF9A825);
  static const Color _secondaryLight = Color(0xFFFFD95A);
  static const Color _secondaryDark = Color(0xFFC17900);
  static const Color _surfaceColor = Color(0xFFF5F5F5);
  static const Color _backgroundColor = Color(0xFFFAFAFA);
  static const Color _errorColor = Color(0xFFD32F2F);
  static const Color _onPrimaryColor = Colors.white;
  static const Color _onSecondaryColor = Colors.black;
  static const Color _onSurfaceColor = Color(0xFF212121);
  static const Color _onBackgroundColor = Color(0xFF212121);

  // ── Light Theme ────────────────────────────────────────────────────────
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: _primaryColor,
      onPrimary: _onPrimaryColor,
      primaryContainer: _primaryLight,
      onPrimaryContainer: _primaryDark,
      secondary: _secondaryColor,
      onSecondary: _onSecondaryColor,
      secondaryContainer: _secondaryLight,
      onSecondaryContainer: _secondaryDark,
      surface: _surfaceColor,
      onSurface: _onSurfaceColor,
      error: _errorColor,
      onError: Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundColor,

      // ── AppBar ───────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _onPrimaryColor,
        ),
        iconTheme: IconThemeData(color: _onPrimaryColor),
      ),

      // ── Card ─────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── ElevatedButton ───────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: _onPrimaryColor,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF757575),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: Color(0xFF9E9E9E),
        ),
      ),

      // ── FloatingActionButton ─────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: _onPrimaryColor,
        elevation: 4,
      ),

      // ── BottomNavigationBar ──────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: _primaryColor,
        unselectedItemColor: Color(0xFF9E9E9E),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 12),
      ),

      // ── Text Theme ──────────────────────────────────────────────────
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _onBackgroundColor),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _onBackgroundColor),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _onBackgroundColor),
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _onBackgroundColor),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: _onBackgroundColor),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onBackgroundColor),
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: _onBackgroundColor),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: _onBackgroundColor),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _onBackgroundColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal, color: _onBackgroundColor),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal, color: _onBackgroundColor),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: Color(0xFF757575)),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _onBackgroundColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _onBackgroundColor),
        labelSmall: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF757575)),
      ),

      // ── Divider ──────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE0E0E0),
        thickness: 1,
        space: 1,
      ),

      // ── Chip ─────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceColor,
        selectedColor: _primaryColor.withValues(alpha: 0.15),
        labelStyle: const TextStyle(fontSize: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
