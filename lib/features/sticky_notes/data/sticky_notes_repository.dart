import 'package:drift/drift.dart';

import 'local/app_database.dart';
import '../domain/sticky_note.dart';
import '../domain/sticky_notes_repository.dart';

class InvalidStickyNoteException implements Exception {
  const InvalidStickyNoteException();
}

class DriftStickyNotesRepository implements StickyNotesRepository {
  const DriftStickyNotesRepository(this.database);

  final AppDatabase database;

  @override
  Future<List<StickyNote>> listNotes() async {
    final rows = await (database.select(database.notes)
          ..orderBy([(note) => OrderingTerm.asc(note.id)]))
        .get();
    return rows
        .map(
          (row) => StickyNote.fromStorage(
            id: row.id,
            content: row.content,
          ),
        )
        .toList();
  }

  @override
  Future<StickyNote> saveNote(StickyNote note) async {
    if (!note.isValid) {
      throw const InvalidStickyNoteException();
    }

    final id = await database.into(database.notes).insert(
          NotesCompanion.insert(content: note.content),
        );
    return StickyNote.fromStorage(id: id, content: note.content);
  }
}
