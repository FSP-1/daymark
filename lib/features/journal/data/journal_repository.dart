import 'package:drift/drift.dart';

import '../../sticky_notes/data/local/app_database.dart';
import '../domain/journal_entry.dart';

class InvalidJournalEntryException implements Exception {
  const InvalidJournalEntryException();
}

class DriftJournalRepository {
  const DriftJournalRepository(this.database);

  final AppDatabase database;

  Future<List<JournalEntryModel>> listEntries() async {
    final rows = await (database.select(database.journalEntries)
          ..orderBy([
            (entry) => OrderingTerm.desc(entry.entryDate),
            (entry) => OrderingTerm.desc(entry.updatedAt),
          ]))
        .get();
    return rows.map(_fromRow).toList();
  }

  Future<JournalEntryModel> saveEntry(JournalEntryModel entry) async {
    if (!entry.isValid) throw const InvalidJournalEntryException();
    final savedAt = DateTime.now();
    final id = await database.into(database.journalEntries).insert(
          JournalEntriesCompanion.insert(
            title: Value(entry.title),
            content: entry.content,
            entryDate: entry.entryDate,
            drawingData: Value(entry.drawingData),
            createdAt: Value(entry.createdAt),
            updatedAt: Value(savedAt),
          ),
        );
    return JournalEntryModel(
      id: id,
      title: entry.title,
      content: entry.content,
      entryDate: entry.entryDate,
      drawingData: entry.drawingData,
      createdAt: entry.createdAt,
      updatedAt: savedAt,
    );
  }

  Future<JournalEntryModel> updateEntry(JournalEntryModel entry) async {
    if (entry.id == null || !entry.isValid) {
      throw const InvalidJournalEntryException();
    }
    final savedAt = DateTime.now();
    await (database.update(database.journalEntries)
          ..where((row) => row.id.equals(entry.id!)))
        .write(
          JournalEntriesCompanion(
            title: Value(entry.title),
            content: Value(entry.content),
            entryDate: Value(entry.entryDate),
            drawingData: Value(entry.drawingData),
            updatedAt: Value(savedAt),
          ),
        );
    return entry.copyWith(updatedAt: savedAt);
  }

  Future<void> deleteEntry(int id) async {
    await (database.delete(database.journalEntries)
          ..where((row) => row.id.equals(id)))
        .go();
  }

  JournalEntryModel _fromRow(JournalEntry row) => JournalEntryModel(
        id: row.id,
        title: row.title,
        content: row.content,
        entryDate: row.entryDate,
        drawingData: row.drawingData,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
