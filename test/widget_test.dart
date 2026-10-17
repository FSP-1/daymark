import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  testWidgets('renders the sticky notes screen', (tester) async {
    final database = AppDatabase.test();
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pumpAndSettle();

    expect(find.text('Sticky Notes'), findsOneWidget);
    expect(find.text('No notes yet.'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await database.close();
  });
}
