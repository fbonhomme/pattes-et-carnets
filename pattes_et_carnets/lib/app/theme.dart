import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _primary = Color(0xFF566342);
  static const _onPrimary = Color(0xFFFFFFFF);
  static const _primaryContainer = Color(0xFFA3B18A);
  static const _onPrimaryContainer = Color(0xFF384425);

  static const _secondary = Color(0xFF356668);
  static const _onSecondary = Color(0xFFFFFFFF);
  static const _secondaryContainer = Color(0xFFB9ECEE);
  static const _onSecondaryContainer = Color(0xFF3C6C6E);

  static const _tertiary = Color(0xFF74556A);
  static const _onTertiary = Color(0xFFFFFFFF);
  static const _tertiaryContainer = Color(0xFFC6A1B9);

  static const _error = Color(0xFFBA1A1A);
  static const _onError = Color(0xFFFFFFFF);
  static const _errorContainer = Color(0xFFFFDAD6);

  static const _background = Color(0xFFFBF9F4);
  static const _surface = Color(0xFFFBF9F4);
  static const _onSurface = Color(0xFF1B1C19);
  static const _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const _surfaceContainerLow = Color(0xFFF6F3EE);
  static const _surfaceContainer = Color(0xFFF0EEE9);
  static const _surfaceContainerHigh = Color(0xFFEAE8E3);
  static const _surfaceContainerHighest = Color(0xFFE4E2DD);
  static const _onSurfaceVariant = Color(0xFF45483F);
  static const _outline = Color(0xFF76786E);
  static const _outlineVariant = Color(0xFFC6C8BB);
  static const _inverseSurface = Color(0xFF30312D);
  static const _inverseOnSurface = Color(0xFFF3F0EB);
  static const _inversePrimary = Color(0xFFBECCA3);

  // Cream card surface (from HTML: #FEFAE0)
  static const cardSurface = Color(0xFFFEFAE0);

  // Soft card shadow tinted with sage green
  static const cardShadow = BoxShadow(
    color: Color(0x1FA3B18A),
    blurRadius: 20,
    offset: Offset(0, 4),
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: _primary,
          onPrimary: _onPrimary,
          primaryContainer: _primaryContainer,
          onPrimaryContainer: _onPrimaryContainer,
          secondary: _secondary,
          onSecondary: _onSecondary,
          secondaryContainer: _secondaryContainer,
          onSecondaryContainer: _onSecondaryContainer,
          tertiary: _tertiary,
          onTertiary: _onTertiary,
          tertiaryContainer: _tertiaryContainer,
          onTertiaryContainer: Color(0xFF53374B),
          error: _error,
          onError: _onError,
          errorContainer: _errorContainer,
          onErrorContainer: Color(0xFF93000A),
          surface: _surface,
          onSurface: _onSurface,
          onSurfaceVariant: _onSurfaceVariant,
          outline: _outline,
          outlineVariant: _outlineVariant,
          inverseSurface: _inverseSurface,
          onInverseSurface: _inverseOnSurface,
          inversePrimary: _inversePrimary,
          surfaceContainerLowest: _surfaceContainerLowest,
          surfaceContainerLow: _surfaceContainerLow,
          surfaceContainer: _surfaceContainer,
          surfaceContainerHigh: _surfaceContainerHigh,
          surfaceContainerHighest: _surfaceContainerHighest,
        ),
        scaffoldBackgroundColor: _background,
        textTheme: _buildTextTheme(),
        cardTheme: CardThemeData(
          color: cardSurface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: EdgeInsets.zero,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _surface,
          foregroundColor: _primary,
          elevation: 1,
          shadowColor: const Color(0x1FA3B18A),
          titleTextStyle: GoogleFonts.quicksand(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: _surfaceContainer,
          indicatorColor: _primaryContainer,
          elevation: 0,
          labelTextStyle: WidgetStateProperty.all(
            GoogleFonts.nunitoSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _primary,
          foregroundColor: _onPrimary,
          shape: StadiumBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: _onPrimary,
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        chipTheme: ChipThemeData(
          shape: const StadiumBorder(),
          backgroundColor: _surfaceContainerHigh,
          labelStyle: GoogleFonts.nunitoSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _surfaceContainerLow,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _primary, width: 2),
          ),
          labelStyle: GoogleFonts.nunitoSans(
            fontWeight: FontWeight.w700,
            color: _onSurfaceVariant,
          ),
        ),
      );

  static TextTheme _buildTextTheme() => TextTheme(
        displayLarge: GoogleFonts.quicksand(
            fontSize: 32, fontWeight: FontWeight.w700, height: 1.25),
        displayMedium: GoogleFonts.quicksand(
            fontSize: 28, fontWeight: FontWeight.w700, height: 1.25),
        displaySmall: GoogleFonts.quicksand(
            fontSize: 24, fontWeight: FontWeight.w700, height: 1.25),
        headlineLarge: GoogleFonts.quicksand(
            fontSize: 24, fontWeight: FontWeight.w600, height: 1.33),
        headlineMedium: GoogleFonts.quicksand(
            fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
        headlineSmall: GoogleFonts.quicksand(
            fontSize: 18, fontWeight: FontWeight.w600, height: 1.44),
        titleLarge: GoogleFonts.quicksand(
            fontSize: 20, fontWeight: FontWeight.w600, height: 1.4),
        titleMedium: GoogleFonts.nunitoSans(
            fontSize: 16, fontWeight: FontWeight.w700, height: 1.5),
        titleSmall: GoogleFonts.nunitoSans(
            fontSize: 14, fontWeight: FontWeight.w700,
            letterSpacing: 0.5, height: 1.43),
        bodyLarge: GoogleFonts.nunitoSans(
            fontSize: 18, fontWeight: FontWeight.w400, height: 1.44),
        bodyMedium: GoogleFonts.nunitoSans(
            fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
        bodySmall: GoogleFonts.nunitoSans(
            fontSize: 14, fontWeight: FontWeight.w400, height: 1.43),
        labelLarge: GoogleFonts.nunitoSans(
            fontSize: 14, fontWeight: FontWeight.w700,
            letterSpacing: 0.5, height: 1.43),
        labelMedium: GoogleFonts.nunitoSans(
            fontSize: 12, fontWeight: FontWeight.w600, height: 1.33),
        labelSmall: GoogleFonts.nunitoSans(
            fontSize: 11, fontWeight: FontWeight.w600,
            letterSpacing: 0.5, height: 1.45),
      );
}
