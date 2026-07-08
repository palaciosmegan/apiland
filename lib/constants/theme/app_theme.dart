import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  AppColors._();

  // static const Color primary100 = Color(0xFFA99BE1);
  // static const Color primary200 = Color(0xFF9A87DA);
  // static const Color primary300 = Color(0xFF8A72D3);
  // static const Color primary400 = Color(0xFF7C5DCB);
  // static const Color primary500 = Color(0xFF6E47C3);
  // static const Color primary600 = Color(0xFF612DBA);

  static const Color primary100 = Color(0xFFDDD3FF);
  static const Color primary200 = Color(0xFFD6CAFF);
  static const Color primary300 = Color(0xFFD0C1FF);
  static const Color primary400 = Color(0xFFCAB8FF);
  static const Color primary500 = Color(0xFFC3AFFF);
  static const Color primary600 = Color(0xFFBDA6FF);

  static const Color accent = Color(0xFF53FCE5);
  static const Color surface = Color(0xFF1F1B30);
  static const Color secondarySurface = Color(0xFF312E42);
  static const Color deactivated = Color(0xFF777378);
  static const Color textStandout = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFFD3D2D7);
  static const Color textSecondary = Color(0xFF121212);

  static const Color green100 = Color(0xFFB8FFC1);
  static const Color green200 = Color(0xFF9DFFAC);
  static const Color green300 = Color(0xFF7DFF95);
  static const Color green400 = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);

  static const Color info100 = Color(0xFFB9E4FF);
  static const Color info200 = Color(0xFFA1DBFF);
  static const Color info300 = Color(0xFF87D1FF);

  static const Color orange100 = Color(0xFFFFD194);
  static const Color orange200 = Color(0xFFFFC77A);
  static const Color orange300 = Color(0xFFFFBC5E);

  // ── Semánticos (uso, no primitivos) ──────────────────────────────────
  // Cards claras sobre el fondo oscuro (dashboard).
  static const Color cardSurface = secondarySurface; // fondo de card clara
  static const Color onCard = textStandout; // texto fuerte sobre card clara
  static const Color onCardMuted = gray400; // texto tenue sobre card clara
  // Pills / badges oscuros.
  static const Color badgeSurface = orange300;
  static const Color onBadge = textSecondary;
  // Texto tenue sobre superficie oscura.
  static const Color textMuted = gray400;

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
    displayLarge: TextStyle(fontSize: AppTextSizes.xl9, color: AppColors.textStandout),
    displayMedium: TextStyle(fontSize: AppTextSizes.xl8, color: AppColors.textStandout),
    displaySmall: TextStyle(fontSize: AppTextSizes.xl7, color: AppColors.textStandout),
    // Headline
    headlineLarge: TextStyle(fontSize: AppTextSizes.xl6, color: AppColors.textStandout),
    headlineMedium: TextStyle(fontSize: AppTextSizes.xl5, color: AppColors.textStandout),
    headlineSmall: TextStyle(fontSize: AppTextSizes.xl4, color: AppColors.textStandout),
    // Title
    titleLarge: TextStyle(fontSize: AppTextSizes.xl3, color: AppColors.textStandout),
    titleMedium: TextStyle(fontSize: AppTextSizes.xl2, color: AppColors.textStandout),
    titleSmall: TextStyle(fontSize: AppTextSizes.xl, color: AppColors.textStandout),
    // Body
    bodyLarge: TextStyle(fontSize: AppTextSizes.lg, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: AppTextSizes.base, color: AppColors.textPrimary),
    bodySmall: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.textPrimary),
    // Label
    labelLarge: TextStyle(fontSize: AppTextSizes.sm, color: AppColors.textPrimary),
    labelMedium: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.textPrimary),
    labelSmall: TextStyle(fontSize: AppTextSizes.xs, color: AppColors.textPrimary),
  );

  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary400,
      secondary: AppColors.accent,
      surface: AppColors.surface,
      onPrimary: AppColors.textSecondary,
      onSecondary: AppColors.textSecondary,
      onSurface: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.surface,
    // Top bar único para toda la app (estilo del dashboard).
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondarySurface,
      foregroundColor: AppColors.gray50,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: AppTextSizes.base,
        fontWeight: FontWeight.w600,
        color: AppColors.gray50,
      ),
    ),
    // Botón "atrás" con chevron en vez de la flecha por defecto.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) => const Icon(Icons.chevron_left),
    ),
    // Botón relleno (primario): colores EXPLÍCITOS, no hereda onPrimary.
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary400,
        foregroundColor: AppColors.textSecondary,
        disabledBackgroundColor: AppColors.gray700,
        disabledForegroundColor: AppColors.gray400,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontSize: AppTextSizes.base,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    // Botón outline (secundario).
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textStandout,
        side: const BorderSide(color: AppColors.gray500),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontSize: AppTextSizes.base,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
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
        borderSide: const BorderSide(color: AppColors.gray300, width: 2),
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
          color = AppColors.error;
        } else if (states.contains(WidgetState.focused)) {
          color = AppColors.textStandout;
        }
        return TextStyle(fontSize: AppTextSizes.sm, color: color);
      }),
      prefixIconColor: WidgetStateColor.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? AppColors.deactivated
            : AppColors.gray400,
      ),
    ),
    // Inter overlays the family onto the base sizes/colors above.
    textTheme: GoogleFonts.interTextTheme(_baseTextTheme),
  );
}
