import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  testWidgets('opens Daily and exposes the empty state', (tester) async {
    final database = AppDatabase.test();
    await tester.runAsync(() => database.customSelect('SELECT 1').get());
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.tap(find.byKey(const Key('daily-nav')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('daily-title')), findsOneWidget);
    expect(find.text('Aún no hay actividades diarias'), findsOneWidget);
    expect(find.byKey(const Key('daily-add')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await database.close();
  });
}
