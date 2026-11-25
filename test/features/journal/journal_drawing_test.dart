import 'dart:ui' show PointerDeviceKind;

import 'package:daymark/core/drawing/drawing_canvas.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/presentation/journal_page.dart';
import 'package:daymark/features/journal/presentation/journal_view_model.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('journal drawing gestures stay inside the dialog', (
    tester,
  ) async {
    final database = AppDatabase.test();
    addTearDown(database.close);
    final model = JournalViewModel(DriftJournalRepository(database));
    addTearDown(model.dispose);
    model.status = JournalStatus.empty;
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: JournalPage()),
      ),
    );
    await tester.tap(find.widgetWithText(FloatingActionButton, 'New entry'));
    await tester.pumpAndSettle();

    final create = find.text('Create drawing');
    expect(find.byType(DrawingCanvas), findsNothing);
    final scroll = tester.state<ScrollableState>(find.byType(Scrollable).first);
    await tester.ensureVisible(create);
    await tester.pumpAndSettle();
    final offset = scroll.position.pixels;
    await tester.tap(create);
    await tester.pumpAndSettle();
    final surface = find.descendant(
      of: find.byType(DrawingCanvas),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onPanStart != null,
      ),
    );
    await tester.drag(surface, const Offset(30, -70), touchSlopY: 0);
    await tester.drag(
      surface,
      const Offset(-40, 70),
      kind: PointerDeviceKind.mouse,
      touchSlopY: 0,
    );
    expect(scroll.position.pixels, offset);
    await tester.tap(find.text('Save drawing'));
    await tester.pumpAndSettle();

    final preview = find.byType(DrawingPreview);
    final saved = tester.widget<DrawingPreview>(preview).strokes;
    expect(saved, hasLength(2));
    expect(saved.every((stroke) => stroke.points.length > 1), isTrue);
    final edit = find.text('Edit drawing');
    await tester.ensureVisible(edit);
    await tester.pumpAndSettle();
    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear drawing'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.widget<DrawingPreview>(preview).strokes, saved);

    await tester.tap(edit);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete drawing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(preview, findsNothing);
    expect(create, findsOneWidget);
  });
}
