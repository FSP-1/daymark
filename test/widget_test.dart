import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  testWidgets('opens Sticky Notes from Home navigation', (tester) async {
    final database = AppDatabase.test();
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('daymark.'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('notes-nav')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('note-content')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });

  testWidgets(
    'opens appearance settings and exposes style and palette choices',
    (tester) async {
      final database = AppDatabase.test();
      await tester.pumpWidget(DaymarkApp(database: database));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Estilo visual'), findsAtLeastNWidgets(1));
      expect(find.text('Paleta de color'), findsOneWidget);
      expect(find.text('Suave'), findsAtLeastNWidgets(1));
      await tester.tap(find.byKey(const Key('style-selector')));
      await tester.pumpAndSettle();
      expect(find.text('Suave'), findsAtLeastNWidgets(1));
      expect(find.text('Juguetón'), findsOneWidget);
      expect(find.text('Minimalista'), findsOneWidget);
      await tester.tap(find.text('Juguetón'));
      await tester.pumpAndSettle();
      expect(
        find.text('Titulares expresivos, formas creativas y un toque alegre.'),
        findsOneWidget,
      );
      await tester.drag(
        find.byKey(const Key('settings-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('palette-sage')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await database.close();
    },
  );
}
