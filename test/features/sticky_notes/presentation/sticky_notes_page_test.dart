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

void main() {
  testWidgets('shows empty state and creates a note', (tester) async {
    final repository = _FakeRepository();
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    expect(find.text('No notes yet.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Offline note');
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();

    expect(find.text('Offline note'), findsOneWidget);
    expect(find.text('No notes yet.'), findsNothing);
  });

  testWidgets('shows validation feedback for empty input', (tester) async {
    await tester.pumpWidget(_buildPage(_FakeRepository()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add note'));
    await tester.pump();

    expect(find.text('Note content cannot be empty.'), findsOneWidget);
  });

  testWidgets('shows save failure without displaying the failed note', (tester) async {
    final repository = _FakeRepository()..saveError = Exception('failed');
    await tester.pumpWidget(_buildPage(repository));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Not saved');
    await tester.tap(find.text('Add note'));
    await tester.pumpAndSettle();

    expect(find.text('Unable to save the note. Please try again.'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);
  });
}
