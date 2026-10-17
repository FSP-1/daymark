import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  testWidgets('opens Sticky Notes from Home navigation', (tester) async {
    final database = AppDatabase.test();
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Daymark'), findsOneWidget);
    await tester.tap(find.byKey(const Key('notes-nav')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('note-content')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });
}
