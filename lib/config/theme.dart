import 'package:flutter/material.dart';

class AppTheme {
  // Moderne Farbpalette
  static const Color primaryColor = Color(0xFF2E7D52); // Tiefes Waldgrün
  static const Color primaryLight = Color(0xFF60AD7B); // Helles Grün
  static const Color secondaryColor = Color(0xFFFF8A50); // Warmes Korall-Orange
  static const Color backgroundColor = Color(0xFFF8F9FA); // Fast-weißes Grau
  static const Color surfaceColor = Colors.white;
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color textPrimary = Color(0xFF1A1A2E); // Dunkles Navy
  static const Color textSecondary = Color(0xFF6B7280); // Mittelgrau

  // Schwierigkeitsfarben
  static const Color level1Color = Color(0xFF43A047); // Grün
  static const Color level2Color = Color(0xFFFFA726); // Amber
  static const Color level3Color = Color(0xFFEF5350); // Rot
  static const Color level4Color = Color(0xFF7B1FA2); // Dunkelviolett

  // Gradient für AppBar und Akzente
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2E7D52), Color(0xFF60AD7B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: surfaceColor,
        error: errorColor,
      ),
      scaffoldBackgroundColor: backgroundColor,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.grey.shade100),
        ),
        surfaceTintColor: Colors.transparent,
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: errorColor),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  static Color getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return level1Color;
      case 2:
        return level2Color;
      case 3:
        return level3Color;
      case 4:
        return level4Color;
      default:
        return level1Color;
    }
  }
}
