import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/theme/app_styles.dart';
import 'package:daymark/core/theme/app_theme.dart';
import 'package:daymark/core/theme/theme_presets.dart';

void main() {
  test('defines exactly three styles and six palettes', () {
    expect(AppStyle.values, hasLength(3));
    expect(AppPalette.values, hasLength(6));
    expect(appStyles.keys, containsAll(AppStyle.values));
    expect(appPalettes.keys, containsAll(AppPalette.values));
  });

  test('composes a valid theme for every style and palette combination', () {
    for (final style in AppStyle.values) {
      for (final palette in AppPalette.values) {
        final theme = buildAppTheme(style: style, palette: palette);
        expect(theme.colorScheme.primary, paletteTokens(palette).primary);
        expect(theme.cardTheme.shape, isA<OutlinedBorder>());
      }
    }
  });

  test('styles provide distinct centralized heading typography', () {
    final soft = styleTokens(AppStyle.soft);
    final playful = styleTokens(AppStyle.playful);
    final minimal = styleTokens(AppStyle.minimal);

    expect(soft.headingFontFamily, isNot(playful.headingFontFamily));
    expect(playful.headingFontFamily, isNot(minimal.headingFontFamily));
    expect(soft.cardRadius, isNot(minimal.cardRadius));
    expect(playful.spacing, isNot(minimal.spacing));
  });
}
