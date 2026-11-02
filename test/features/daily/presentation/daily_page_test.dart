import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  testWidgets('opens Daily and exposes the empty state', (tester) async {
    final database = AppDatabase.test();
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('daily-nav')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('daily-title')), findsOneWidget);
    expect(find.text('Aún no hay actividades diarias'), findsOneWidget);
    expect(find.byKey(const Key('daily-add')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });
}
