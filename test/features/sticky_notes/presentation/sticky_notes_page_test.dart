import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

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
      id: notes.length + 1,
      content: note.content,
      title: note.title,
      subtitle: note.subtitle,
      createdAt: note.createdAt,
    );
    notes.add(saved);
    return saved;
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
  await tester.drag(
    find.byKey(const Key('sticky-notes-scroll')),
    const Offset(0, -500),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const Key('add-note')));
}

void main() {
  testWidgets('shows empty state and creates a note', (tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet'), findsOneWidget);

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

    final viewModel = tester
        .element(find.byType(StickyNotesPage))
        .read<StickyNotesViewModel>();
    await viewModel.createNote('');
    await tester.pumpAndSettle();

    expect(find.text('Note content cannot be empty.'), findsOneWidget);
  });

  testWidgets('shows save failure without displaying the failed note', (
    tester,
  ) async {
    final repository = _FakeRepository()..saveError = Exception('failed');
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('note-content')), 'Not saved');
    final viewModel = tester
        .element(find.byType(StickyNotesPage))
        .read<StickyNotesViewModel>();
    await viewModel.createNote('Not saved');
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to save the note. Please try again.'),
      findsOneWidget,
    );
    expect(find.byType(ListTile), findsNothing);
  });

  testWidgets('accepts optional title and displays creation date', (
    tester,
  ) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

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
