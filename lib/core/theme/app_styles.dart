import 'package:flutter/material.dart';

enum AppStyle { soft, playful, minimal }

class AppStyleTokens {
  const AppStyleTokens({
    required this.fontFamily,
    required this.headingFontFamily,
    required this.fontFamilyFallback,
    required this.cardRadius,
    required this.buttonRadius,
    required this.controlRadius,
    required this.elevation,
    required this.spacing,
    required this.headingWeight,
    required this.letterSpacing,
  });

  final double cardRadius;
  final String fontFamily;
  final String headingFontFamily;
  final List<String> fontFamilyFallback;
  final double buttonRadius;
  final double controlRadius;
  final double elevation;
  final double spacing;
  final FontWeight headingWeight;
  final double letterSpacing;
}

const appStyles = <AppStyle, AppStyleTokens>{
  AppStyle.soft: AppStyleTokens(
    fontFamily: 'sans-serif',
    headingFontFamily: 'serif',
    fontFamilyFallback: ['sans-serif'],
    cardRadius: 24,
    buttonRadius: 18,
    controlRadius: 16,
    elevation: 2,
    spacing: 20,
    headingWeight: FontWeight.w700,
    letterSpacing: 0,
  ),
  AppStyle.playful: AppStyleTokens(
    fontFamily: 'sans-serif',
    headingFontFamily: 'cursive',
    fontFamilyFallback: ['sans-serif'],
    cardRadius: 14,
    buttonRadius: 20,
    controlRadius: 14,
    elevation: 4,
    spacing: 24,
    headingWeight: FontWeight.w800,
    letterSpacing: 0.2,
  ),
  AppStyle.minimal: AppStyleTokens(
    fontFamily: 'sans-serif',
    headingFontFamily: 'sans-serif',
    fontFamilyFallback: ['sans-serif'],
    cardRadius: 10,
    buttonRadius: 10,
    controlRadius: 10,
    elevation: 0,
    spacing: 16,
    headingWeight: FontWeight.w600,
    letterSpacing: -0.1,
  ),
};

AppStyleTokens styleTokens(AppStyle style) => appStyles[style]!;
