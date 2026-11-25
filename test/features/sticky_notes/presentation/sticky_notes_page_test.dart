import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:daymark/core/drawing/drawing_canvas.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_notes_repository.dart';
import 'package:daymark/features/sticky_notes/presentation/sticky_notes_page.dart';
import 'package:daymark/features/sticky_notes/presentation/sticky_notes_view_model.dart';

class _FakeRepository implements StickyNotesRepository {
  _FakeRepository([Iterable<StickyNote> initialNotes = const []])
    : notes = initialNotes.toList();

  final List<StickyNote> notes;
  Object? saveError;

  @override
  Future<List<StickyNote>> listNotes() async => List.unmodifiable(notes);

  @override
  Future<StickyNote> saveNote(StickyNote note) async {
    if (saveError != null) throw saveError!;
    final saved = StickyNote.fromStorage(
      id: note.id ?? notes.length + 1,
      content: note.content,
      title: note.title,
      subtitle: note.subtitle,
      createdAt: note.createdAt,
      drawingData: note.drawingData,
    );
    final index = notes.indexWhere((item) => item.id == saved.id);
    if (index == -1) {
      notes.add(saved);
    } else {
      notes[index] = saved;
    }
    return saved;
  }

  @override
  Future<void> deleteNote(int id) async {
    notes.removeWhere((note) => note.id == id);
  }
}

Widget _buildPage(_FakeRepository repository) {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => StickyNotesViewModel(repository)..load(),
      child: const StickyNotesPage(),
    ),
  );
}

Future<void> _tapAddNote(WidgetTester tester) async {
  tester.testTextInput.hide();
  await tester.pump();
  await tester.ensureVisible(find.byKey(const Key('add-note')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('add-note')));
}

Future<void> _openEditor(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('add-note-action')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows empty state and creates a note', (tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);

    await _openEditor(tester);
    await tester.enterText(
      find.byKey(const Key('note-content')),
      'Offline note',
    );
    await _tapAddNote(tester);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Offline note'));

    expect(find.text('Offline note'), findsOneWidget);
    expect(find.text('No notes yet'), findsNothing);
  });

  testWidgets('shows validation feedback for empty input', (tester) async {
    await tester.pumpWidget(_buildPage(_FakeRepository()));
    await tester.pumpAndSettle();

    await _openEditor(tester);
    await _tapAddNote(tester);
    await tester.pumpAndSettle();

    expect(find.text('Note content cannot be empty.'), findsOneWidget);
  });

  testWidgets('shows save failure without displaying the failed note', (
    tester,
  ) async {
    final repository = _FakeRepository()..saveError = Exception('failed');
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    await _openEditor(tester);
    await tester.enterText(find.byKey(const Key('note-content')), 'Not saved');
    await _tapAddNote(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to save the note. Please try again.'),
      findsOneWidget,
    );
    expect(repository.notes, isEmpty);
  });

  testWidgets('accepts optional title and displays creation date', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    await _openEditor(tester);
    await tester.enterText(find.byKey(const Key('note-title')), 'Title');
    await tester.enterText(find.byKey(const Key('note-content')), 'Content');
    await _tapAddNote(tester);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('Content'));

    expect(find.text('Title'), findsAtLeastNWidgets(1));
    expect(find.textContaining('Content'), findsOneWidget);
    final localizations = MaterialLocalizations.of(
      tester.element(find.byType(StickyNotesPage)),
    );
    expect(
      find.textContaining(localizations.formatMediumDate(DateTime.now())),
      findsOneWidget,
    );
  });

  testWidgets('uses an icon instead of a drawing preview', (tester) async {
    final repository = _FakeRepository([
      StickyNote.fromStorage(
        id: 1,
        content: 'Drawn note',
        drawingData: 'drawing',
      ),
    ]);
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.draw_outlined), findsOneWidget);
    expect(find.byType(DrawingPreview), findsNothing);
  });

  testWidgets('saves and deletes a drawing through the note dialog', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();
    await _openEditor(tester);
    expect(find.byType(DrawingCanvas), findsNothing);

    await tester.tap(find.text('Create drawing'));
    await tester.pumpAndSettle();
    final surface = find.descendant(
      of: find.byType(DrawingCanvas),
      matching: find.byWidgetPredicate(
        (widget) => widget is GestureDetector && widget.onPanStart != null,
      ),
    );
    await tester.drag(surface, const Offset(20, 70), touchSlopY: 0);
    await tester.tap(find.text('Save drawing'));
    await tester.pumpAndSettle();
    expect(find.byType(DrawingPreview), findsOneWidget);
    expect(repository.notes, isEmpty);

    await tester.enterText(find.byKey(const Key('note-content')), 'Drawn note');
    await _tapAddNote(tester);
    await tester.pumpAndSettle();
    final drawingData = repository.notes.single.drawingData;
    expect(drawingData, isNotNull);

    await tester.tap(find.text('Drawn note'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit drawing'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Clear drawing'));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(DrawingPreview), findsOneWidget);

    await tester.tap(find.text('Edit drawing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete drawing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.byType(DrawingPreview), findsNothing);
    expect(repository.notes.single.drawingData, drawingData);

    await _tapAddNote(tester);
    await tester.pumpAndSettle();
    expect(repository.notes.single.drawingData, isNull);
  });

  testWidgets('filters notes by text', (tester) async {
    final repository = _FakeRepository([
      StickyNote.create(content: 'Shopping', createdAt: DateTime(2026, 10, 17)),
      StickyNote.create(content: 'Project', createdAt: DateTime(2026, 10, 18)),
    ]);
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('note-search')), 'shopping');
    await tester.pump();
    await tester.scrollUntilVisible(
      find.text('Shopping'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Shopping'), findsOneWidget);
    expect(find.text('Project'), findsNothing);
  });
}
