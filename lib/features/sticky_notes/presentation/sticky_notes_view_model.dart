import 'package:flutter/foundation.dart';

import '../../../core/filtering/search_filter.dart';
import '../domain/sticky_note.dart';
import '../domain/sticky_notes_repository.dart';

enum StickyNotesStatus { loading, empty, ready, validationError, error }

class StickyNotesViewModel extends ChangeNotifier {
  StickyNotesViewModel(this.repository);

  final StickyNotesRepository repository;

  StickyNotesStatus status = StickyNotesStatus.loading;
  List<StickyNote> notes = const [];
  String? errorMessage;
  SearchFilter filter = const SearchFilter();

  List<StickyNote> get visibleNotes => filterItems(
    notes,
    filter,
    textSelector: (note) =>
        [note.title, note.subtitle, note.content].whereType<String>().join(' '),
    dateSelector: (note) => note.createdAt,
  ).toList();

  Future<void> load() async {
    status = StickyNotesStatus.loading;
    errorMessage = null;
    notifyListeners();
    try {
      notes = await repository.listNotes();
      status = notes.isEmpty
          ? StickyNotesStatus.empty
          : StickyNotesStatus.ready;
    } catch (_) {
      status = StickyNotesStatus.error;
      errorMessage = 'Unable to load notes. Please try again.';
    }
    notifyListeners();
  }

  Future<void> createNote(
    String content, {
    String? title,
    String? subtitle,
    String? drawingData,
  }) async {
    final note = StickyNote.create(
      content: content,
      title: title,
      subtitle: subtitle,
      drawingData: drawingData,
    );
    if (!note.isValid) {
      status = StickyNotesStatus.validationError;
      errorMessage = 'Note content cannot be empty.';
      notifyListeners();
      return;
    }

    errorMessage = null;
    try {
      await repository.saveNote(note);
      notes = await repository.listNotes();
      status = notes.isEmpty
          ? StickyNotesStatus.empty
          : StickyNotesStatus.ready;
    } catch (_) {
      status = StickyNotesStatus.error;
      errorMessage = 'Unable to save the note. Please try again.';
    }
    notifyListeners();
  }

  void setFilter({String text = '', DateTime? fromDate, DateTime? toDate}) {
    filter = SearchFilter(text: text, fromDate: fromDate, toDate: toDate);
    notifyListeners();
  }

  void clearFilter() {
    filter = const SearchFilter();
    notifyListeners();
  }
}
