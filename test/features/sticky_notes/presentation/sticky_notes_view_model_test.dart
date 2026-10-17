import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_notes_repository.dart';
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
    if (saveError != null) {
      throw saveError!;
    }
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

void main() {
  test('loads notes and reports empty state', () async {
    final viewModel = StickyNotesViewModel(_FakeRepository());

    await viewModel.load();

    expect(viewModel.status, StickyNotesStatus.empty);
    expect(viewModel.notes, isEmpty);
  });

  test('creates a valid note and refreshes the list', () async {
    final viewModel = StickyNotesViewModel(_FakeRepository());

    await viewModel.createNote('First note');

    expect(viewModel.status, StickyNotesStatus.ready);
    expect(viewModel.notes.single.content, 'First note');
  });

  test('reports validation without saving invalid content', () async {
    final repository = _FakeRepository();
    final viewModel = StickyNotesViewModel(repository);

    await viewModel.createNote('  ');

    expect(viewModel.status, StickyNotesStatus.validationError);
    expect(repository.notes, isEmpty);
    expect(viewModel.errorMessage, 'Note content cannot be empty.');
  });

  test('reports save failure while retaining existing notes', () async {
    final repository = _FakeRepository([
      StickyNote.fromStorage(id: 1, content: 'Saved'),
    ])..saveError = Exception('storage failed');
    final viewModel = StickyNotesViewModel(repository);
    await viewModel.load();

    await viewModel.createNote('New note');

    expect(viewModel.status, StickyNotesStatus.error);
    expect(viewModel.notes.single.content, 'Saved');
    expect(
      viewModel.errorMessage,
      'Unable to save the note. Please try again.',
    );
  });

  test('filters notes by text and date and clears filters', () async {
    final repository = _FakeRepository([
      StickyNote.create(
        content: 'Shopping',
        title: 'Weekend',
        createdAt: DateTime(2026, 10, 17),
      ),
      StickyNote.create(
        content: 'Project',
        title: 'Work',
        createdAt: DateTime(2026, 10, 18),
      ),
    ]);
    final viewModel = StickyNotesViewModel(repository);
    await viewModel.load();

    viewModel.setFilter(
      text: 'shopping',
      fromDate: DateTime(2026, 10, 17),
      toDate: DateTime(2026, 10, 17),
    );

    expect(viewModel.visibleNotes.single.content, 'Shopping');
    viewModel.clearFilter();
    expect(viewModel.visibleNotes, hasLength(2));
  });
}
