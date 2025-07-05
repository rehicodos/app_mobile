import 'package:flutter/material.dart';

class AppTheme {
  static const Color txtColor = Colors.black87;
  static const Color appbarrColor = Color(0xFF0D47A1);
  static const Color primaryColor = Color(0xFF1565C0);
  // static const Color scaffoldBackground = Colors.blue[100]; // bleu acier
  static const Color scaffoldBackground = Color(0xFFD0E2F2); // bleu acier
  // static const Color scaffoldBackground = Color(0xFFFAFAFA);
  static const Color accentColor = Color(0xFF42A5F5);

  static ThemeData get theme {
    return ThemeData(
      // scaffoldBackgroundColor: Colors.grey[50],
      scaffoldBackgroundColor: Colors.blue[100],
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: accentColor,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: appbarrColor,
        foregroundColor: Colors.white,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        // border: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide(color: primaryColor),
        // ),
        // focusedBorder: OutlineInputBorder(
        //   borderRadius: BorderRadius.circular(8),
        //   borderSide: BorderSide(color: accentColor, width: 2),
        // ),
      ),
      textTheme: TextTheme(
        bodyMedium: TextStyle(color: Colors.black87),
        titleLarge: TextStyle(
          // fontSize: 20,
          // fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
