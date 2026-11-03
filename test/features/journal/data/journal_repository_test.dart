import 'package:drift/drift.dart' as drift;
import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_entry.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  drift.driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase database;
  late DriftJournalRepository repository;

  setUp(() {
    database = AppDatabase.test();
    repository = DriftJournalRepository(database);
  });

  tearDown(() => database.close());

  test('supports multiple entries on the same date', () async {
    final date = DateTime(2026, 11, 3);
    await repository.saveEntry(
      JournalEntryModel.create(content: 'First', entryDate: date),
    );
    await repository.saveEntry(
      JournalEntryModel.create(content: 'Second', entryDate: date),
    );

    expect(await repository.listEntries(), hasLength(2));
  });

  test('persists clearing a drawing during update', () async {
    final saved = await repository.saveEntry(
      JournalEntryModel.create(
        content: 'A memory',
        drawingData: '[{"points":[]}]',
      ),
    );

    await repository.updateEntry(saved.copyWith(clearDrawing: true));

    expect((await repository.listEntries()).single.drawingData, isNull);
  });
}
