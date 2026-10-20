import 'package:flutter/material.dart';

import 'app_styles.dart';
import 'theme_presets.dart';

ThemeData buildAppTheme({
  required AppStyle style,
  required AppPalette palette,
}) {
  final colors = paletteTokens(palette);
  final styleTokensValue = styleTokens(style);
  final scheme = ColorScheme.light(
    primary: colors.primary,
    onPrimary: colors.onPrimary,
    secondary: colors.secondary,
    onSecondary: colors.textPrimary,
    surface: colors.surface,
    onSurface: colors.textPrimary,
    error: const Color(0xffb3261e),
    onError: Colors.white,
  );
  final base = ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: colors.background,
    useMaterial3: true,
  );
  final textTheme = base.textTheme.apply(
    bodyColor: colors.textPrimary,
    displayColor: colors.textPrimary,
    fontFamily: styleTokensValue.fontFamily,
    fontFamilyFallback: styleTokensValue.fontFamilyFallback,
  );
  final headingStyle = TextStyle(
    fontFamily: styleTokensValue.headingFontFamily,
    fontFamilyFallback: styleTokensValue.fontFamilyFallback,
    fontWeight: styleTokensValue.headingWeight,
    letterSpacing: styleTokensValue.letterSpacing,
  );

  return base.copyWith(
    textTheme: textTheme.copyWith(
      displayLarge: textTheme.displayLarge?.merge(headingStyle),
      displayMedium: textTheme.displayMedium?.merge(headingStyle),
      displaySmall: textTheme.displaySmall?.merge(headingStyle),
      headlineLarge: textTheme.headlineLarge?.merge(headingStyle),
      headlineMedium: textTheme.headlineMedium?.merge(headingStyle),
      headlineSmall: textTheme.headlineSmall?.merge(headingStyle),
      titleLarge: textTheme.titleLarge?.merge(headingStyle),
      titleMedium: textTheme.titleMedium?.merge(headingStyle),
    ),
    cardTheme: CardThemeData(
      color: colors.surface,
      margin: EdgeInsets.only(bottom: styleTokensValue.spacing / 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(styleTokensValue.cardRadius),
        side: BorderSide(color: colors.border),
      ),
      elevation: styleTokensValue.elevation,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colors.background,
      foregroundColor: colors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colors.surface,
      labelStyle: TextStyle(color: colors.textSecondary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(styleTokensValue.controlRadius),
        borderSide: BorderSide(color: colors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(styleTokensValue.controlRadius),
        borderSide: BorderSide(color: colors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(styleTokensValue.controlRadius),
        borderSide: BorderSide(color: colors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(styleTokensValue.buttonRadius),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colors.surface,
      indicatorColor: colors.accent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(color: colors.textPrimary),
      ),
    ),
    dividerTheme: DividerThemeData(color: colors.divider),
  );
}
