import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:daymark/features/sticky_notes/data/sticky_notes_repository.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';

import '../../../test_support/sticky_notes_fixtures.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;
  late DriftStickyNotesRepository repository;

  setUp(() {
    database = AppDatabase.test();
    repository = DriftStickyNotesRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('lists an empty collection without a network', () async {
    expect(await repository.listNotes(), isEmpty);
  });

  test('saves and lists a note', () async {
    await repository.saveNote(StickyNote.create('Offline note'));

    final notes = await repository.listNotes();

    expect(notes, hasLength(1));
    expect(notes.single.content, 'Offline note');
  });

  test('rejects invalid notes before persistence', () async {
    expect(
      () => repository.saveNote(StickyNote.create(' \t')),
      throwsA(isA<InvalidStickyNoteException>()),
    );
    expect(await repository.listNotes(), isEmpty);
  });

  test('retains notes when the database is reopened', () async {
    final file = createTemporaryStickyNotesDatabaseFile();
    final firstDatabase = openTemporaryStickyNotesDatabase(file);
    await DriftStickyNotesRepository(firstDatabase)
        .saveNote(StickyNote.create('Persistent note'));
    await firstDatabase.close();

    final reopenedDatabase = openTemporaryStickyNotesDatabase(file);
    final notes = await DriftStickyNotesRepository(reopenedDatabase)
        .listNotes();
    await reopenedDatabase.close();
    await file.delete();

    expect(notes.single.content, 'Persistent note');
  });
}
