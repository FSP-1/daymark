import 'package:flutter/material.dart';

enum AppPalette { vanilla, sage, rose, sky, lavender, peach }

class AppPaletteTokens {
  const AppPaletteTokens({
    required this.background,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.divider,
    required this.onPrimary,
  });

  final Color background;
  final Color surface;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color divider;
  final Color onPrimary;
}

const appPalettes = <AppPalette, AppPaletteTokens>{
  AppPalette.vanilla: AppPaletteTokens(
    background: Color(0xfffffbf3),
    surface: Color(0xfffffdf8),
    primary: Color(0xff8c6f47),
    secondary: Color(0xffd8b568),
    accent: Color(0xffffd978),
    textPrimary: Color(0xff3f352b),
    textSecondary: Color(0xff75685b),
    border: Color(0xffe4d6c1),
    divider: Color(0xffeee4d5),
    onPrimary: Colors.white,
  ),
  AppPalette.sage: AppPaletteTokens(
    background: Color(0xfff5f8f1),
    surface: Color(0xfffcfefa),
    primary: Color(0xff55735e),
    secondary: Color(0xff8eab8f),
    accent: Color(0xffc8ddae),
    textPrimary: Color(0xff293c30),
    textSecondary: Color(0xff637568),
    border: Color(0xffcbdacb),
    divider: Color(0xffe0eadf),
    onPrimary: Colors.white,
  ),
  AppPalette.rose: AppPaletteTokens(
    background: Color(0xfffff7f7),
    surface: Color(0xfffffcfc),
    primary: Color(0xff9a5665),
    secondary: Color(0xffc88791),
    accent: Color(0xffefb8bc),
    textPrimary: Color(0xff4c2d35),
    textSecondary: Color(0xff80636a),
    border: Color(0xffe5c9ce),
    divider: Color(0xfff0dde0),
    onPrimary: Colors.white,
  ),
  AppPalette.sky: AppPaletteTokens(
    background: Color(0xfff4f8fc),
    surface: Color(0xfffcfeff),
    primary: Color(0xff4f718a),
    secondary: Color(0xff89afc9),
    accent: Color(0xffb9d9ed),
    textPrimary: Color(0xff2d3f4d),
    textSecondary: Color(0xff607887),
    border: Color(0xffcbdde8),
    divider: Color(0xffe0edf3),
    onPrimary: Colors.white,
  ),
  AppPalette.lavender: AppPaletteTokens(
    background: Color(0xfff8f5fc),
    surface: Color(0xfffefcff),
    primary: Color(0xff705c91),
    secondary: Color(0xffa590bd),
    accent: Color(0xffd8c7eb),
    textPrimary: Color(0xff3d304d),
    textSecondary: Color(0xff71647c),
    border: Color(0xffdcd1e8),
    divider: Color(0xffece5f3),
    onPrimary: Colors.white,
  ),
  AppPalette.peach: AppPaletteTokens(
    background: Color(0xfffff7f1),
    surface: Color(0xfffffcf9),
    primary: Color(0xffa7644c),
    secondary: Color(0xffd99473),
    accent: Color(0xffffc39f),
    textPrimary: Color(0xff4b332b),
    textSecondary: Color(0xff80675d),
    border: Color(0xffead1c2),
    divider: Color(0xfff2e1d6),
    onPrimary: Colors.white,
  ),
};

AppPaletteTokens paletteTokens(AppPalette palette) => appPalettes[palette]!;
