import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/loading/app_loading_screen.dart';
import 'package:daymark/core/loading/loading_overlay.dart';
import 'package:daymark/core/localization/app_localizations.dart';
import 'package:daymark/core/theme/app_theme.dart';
import 'package:daymark/core/theme/app_styles.dart';
import 'package:daymark/core/theme/theme_presets.dart';

Widget _testApp(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: buildAppTheme(style: AppStyle.playful, palette: AppPalette.sky),
    localizationsDelegates: const [AppLocalizations.delegate],
    supportedLocales: const [Locale('en'), Locale('es')],
    locale: const Locale('en'),
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: child,
    ),
  );
}

void main() {
  testWidgets('renders the branded localized loading composition', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const AppLoadingScreen()));
    await tester.pump();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);
    expect(
      tester
          .widget<ColoredBox>(
            find.descendant(
              of: find.byType(AppLoadingScreen),
              matching: find.byType(ColoredBox),
            ),
          )
          .color,
      paletteTokens(AppPalette.sky).background,
    );
  });

  testWidgets('reduced motion keeps the symbol static', (tester) async {
    await tester.pumpWidget(
      _testApp(const AppLoadingScreen(), disableAnimations: true),
    );
    final rotation = find.byType(RotationTransition);

    expect(rotation, findsNothing);
  });

  testWidgets('blocking overlay prevents interaction with its child', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(
        Scaffold(
          body: LoadingOverlay(
            isLoading: true,
            child: GestureDetector(
              onTap: () => taps++,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    await tester.tapAt(const Offset(20, 20));
    expect(taps, 0);
  });
}
