import 'package:flutter/foundation.dart';

import '../data/journal_repository.dart';
import '../domain/journal_entry.dart';

enum JournalStatus { loading, empty, ready, error, validationError }

class JournalViewModel extends ChangeNotifier {
  JournalViewModel(this.repository);

  final DriftJournalRepository repository;
  JournalStatus status = JournalStatus.loading;
  List<JournalEntryModel> entries = const [];
  String? errorMessage;

  Future<void> load() async {
    status = JournalStatus.loading;
    notifyListeners();
    try {
      entries = await repository.listEntries();
      status = entries.isEmpty ? JournalStatus.empty : JournalStatus.ready;
      errorMessage = null;
    } catch (_) {
      status = JournalStatus.error;
      errorMessage = 'loadJournal';
    }
    notifyListeners();
  }

  Future<JournalEntryModel?> save(JournalEntryModel entry) async {
    if (!entry.isValid) {
      status = JournalStatus.validationError;
      errorMessage = 'emptyJournal';
      notifyListeners();
      return null;
    }
    try {
      late final JournalEntryModel saved;
      if (entry.id == null) {
        saved = await repository.saveEntry(entry);
      } else {
        saved = await repository.updateEntry(entry);
      }
      await load();
      return saved;
    } catch (_) {
      status = JournalStatus.error;
      errorMessage = 'saveJournal';
      notifyListeners();
      return null;
    }
  }

  Future<bool> delete(JournalEntryModel entry) async {
    if (entry.id == null) return false;
    try {
      await repository.deleteEntry(entry.id!);
      await load();
      return true;
    } catch (_) {
      status = JournalStatus.error;
      errorMessage = 'deleteJournal';
      notifyListeners();
      return false;
    }
  }
}
