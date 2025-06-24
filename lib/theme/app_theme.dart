import 'package:flutter/material.dart';

class AppTheme {
  // Color palette
  static const Color primary = Color(0xFF1A237E); // Deep Blue
  static const Color accent = Color(0xFFFF9800); // Vibrant Orange
  static const Color background = Color(0xFFF5F5F5); // Light Gray
  static const Color success = Color(0xFF43A047); // Emerald Green
  static const Color warning = Color(0xFFE53935); // Red

  static ThemeData lightTheme = ThemeData(
    primaryColor: primary,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primary,
      secondary: accent,
      background: background,
      error: warning,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        color: Colors.black87,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: accent,
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: accent,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF181A20),
    colorScheme: ColorScheme.dark(
      primary: primary,
      secondary: accent,
      background: const Color(0xFF181A20),
      error: warning,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF23243A),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Montserrat',
        fontWeight: FontWeight.bold,
        fontSize: 32,
        color: Colors.white,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Roboto',
        fontSize: 18,
        color: Colors.white70,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Roboto',
        fontWeight: FontWeight.w500,
        fontSize: 16,
        color: accent,
      ),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: accent,
      textTheme: ButtonTextTheme.primary,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        textStyle: const TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
