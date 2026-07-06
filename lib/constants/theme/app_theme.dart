import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF612DBA);
  static const Color primaryLight = Color.fromARGB(255, 151, 121, 201);
  static const Color accent = Color(0xFF53FCE5);
  static const Color surface = Color(0xFF1F1B30);
  static const Color deactivated = Color(0xFF777378);

  // Tailwind grays
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);
  static const Color gray800 = Color(0xFF1F2937);
  static const Color gray900 = Color(0xFF111827);
  static const Color gray950 = Color(0xFF030712);
}

class AppTextSizes {
  AppTextSizes._();

  // Tailwind font sizes (in logical pixels)
  static const double xs = 12;
  static const double sm = 14;
  static const double base = 16;
  static const double lg = 18;
  static const double xl = 20;
  static const double xl2 = 24;
  static const double xl3 = 30;
  static const double xl4 = 36;
  static const double xl5 = 48;
  static const double xl6 = 60;
  static const double xl7 = 72;
  static const double xl8 = 96;
  static const double xl9 = 128;
}

class AppTextStyles {
  AppTextStyles._();

  /// Inter with tabular (monospaced) figures + slashed zero.
  /// Use for any numeric readout so digits align in columns and 0 ≠ O.
  static TextStyle data({
    double fontSize = AppTextSizes.base,
    FontWeight fontWeight = FontWeight.w500,
    Color color = AppColors.gray100,
  }) => GoogleFonts.inter(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    fontFeatures: const [
      FontFeature.tabularFigures(),
      FontFeature.slashedZero(),
    ],
  );
}

class AppTheme {
  AppTheme._();

  // Sizes + colors live here; Inter is layered on top in `dark`.
  static const TextTheme _baseTextTheme = TextTheme(
    // Display
    displayLarge: TextStyle(fontSize: AppTextSizes.xl9, color: AppColors.gray50),
    displayMedium: TextStyle(fontSize: AppTextSizes.xl8, color: AppColors.gray50),
    displaySmall: TextStyle(fontSize: AppTextSizes.xl7, color: AppColors.gray50),
    // Headline
    headlineLarge: TextStyle(fontSize: AppTextSizes.xl6, color: AppColors.gray50),
    headlineMedium: TextStyle(fontSize: AppTextSizes.xl5, color: AppColors.gray50),
    headlineSmall: TextStyle(fontSize: AppTextSizes.xl4, color: AppColors.gray50),
    // Title
    titleLarge: TextStyle(fontSize: AppTextSizes.xl3, color: AppColors.gray50),
    titleMedium: TextStyle(fontSize: AppTextSizes.xl2, color: AppColors.gray50),
    titleSmall: TextStyle(fontSize: AppTextSizes.xl, color: AppColors.gray50),
    // Body
    bodyLarge: TextStyle(fontSize: AppTextSizes.lg, color: AppColors.gray100),
    bodyMedium: TextStyle(fontSize: AppTextSizes.base, color: AppColors.gray100),
    bodySmall: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.gray300),
    // Label
    labelLarge: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.gray400),
    labelMedium: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.gray400),
    labelSmall: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.deactivated),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onPrimary: AppColors.gray50,
      onSecondary: AppColors.gray900,
      onSurface: AppColors.gray100,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    inputDecorationTheme: InputDecorationTheme(
      // 8pt grid: even vertical rhythm inside every field
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      // Inactive state: muted but legible — gray-700 fill, gray-400 content
      filled: true,
      fillColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.gray700
            : Colors.transparent,
      ),
      // border-radius: 8px on all inputs
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray500),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gray700),
      ),
      // Labels: 14 (smaller than the 16 value text), muted gray-400 when disabled
      labelStyle: WidgetStateTextStyle.resolveWith(
        (states) => TextStyle(
          fontSize: AppTextSizes.sm,
          color: states.contains(WidgetState.disabled)
              ? AppColors.gray400
              : AppColors.gray300,
        ),
      ),
      hintStyle: const TextStyle(fontSize: AppTextSizes.sm, color: AppColors.gray500),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        Color color = AppColors.gray300;
        if (states.contains(WidgetState.disabled)) {
          color = AppColors.gray400;
        } else if (states.contains(WidgetState.error)) {
          color = const Color(0xFFEF4444); // rojo de validación
        } else if (states.contains(WidgetState.focused)) {
          color = AppColors.primaryLight;
        }
        return TextStyle(fontSize: AppTextSizes.sm, color: color);
      }),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.gray400
            : AppColors.gray300,
      ),
    ),
    // Inter overlays the family onto the base sizes/colors above.
    textTheme: GoogleFonts.interTextTheme(_baseTextTheme),
  );
}
