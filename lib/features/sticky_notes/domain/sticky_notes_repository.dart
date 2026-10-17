import 'sticky_note.dart';

abstract interface class StickyNotesRepository {
  Future<List<StickyNote>> listNotes();

  Future<StickyNote> saveNote(StickyNote note);
}
