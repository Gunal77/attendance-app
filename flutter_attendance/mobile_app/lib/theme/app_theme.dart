import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color primaryColor = Color(0xFF4A90E2);
  static const Color secondaryColor = Color(0xFF50E3C2);
  static const Color backgroundColor = Color(0xFFF7F9FC);
  static const Color textColor = Color(0xFF1E1E2D);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE74C3C);
  static const Color successColor = Color(0xFF27AE60);

  // Material 3 Color Scheme
  static ColorScheme get colorScheme => ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: cardColor,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textColor,
        onSurface: textColor,
        onError: Colors.white,
        brightness: Brightness.light,
      );

  // Theme Data
  static ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(
          displayLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          displayMedium: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          displaySmall: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
          headlineLarge: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          headlineSmall: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          titleLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          titleMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: textColor,
          ),
          bodySmall: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.normal,
            color: textColor.withOpacity(0.7),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: cardColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: errorColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            color: textColor.withOpacity(0.7),
          ),
        ),
        appBarTheme: AppBarTheme(
          elevation: 0,
          centerTitle: true,
          backgroundColor: cardColor,
          foregroundColor: textColor,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 4,
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      );
}

