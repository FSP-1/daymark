import 'dart:io';

import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/domain/journal_entry.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:daymark/features/sticky_notes/data/sticky_notes_repository.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'version 7 notes survive migration and can be assigned or unassigned',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'daymark-calendar-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/daymark.sqlite');
      final old = AppDatabase.testAt(file);
      final createdAt = DateTime(2024, 2, 29, 13);
      await DriftStickyNotesRepository(old).saveNote(
        StickyNote.create(
          title: 'Original',
          content: 'Note',
          createdAt: createdAt,
          drawingData: '[]',
        ),
      );
      await old.customStatement(
        'ALTER TABLE notes DROP COLUMN associated_date',
      );
      await old.customStatement(
        'ALTER TABLE app_preferences DROP COLUMN navigation',
      );
      await old.customStatement('DROP TABLE goal_milestones');
      await old.customStatement('DROP TABLE goals');
      await old.customStatement('DROP TABLE daily_goal_credits');
      await old.customStatement(
        'ALTER TABLE daily_activities DROP COLUMN goal_id',
      );
      await old.customStatement('PRAGMA user_version = 7');
      await old.close();

      final database = AppDatabase.testAt(file);
      addTearDown(database.close);
      final repository = DriftStickyNotesRepository(database);
      final original = (await repository.listNotes()).single;
      expect(original.title, 'Original');
      expect(original.content, 'Note');
      expect(original.drawingData, '[]');
      expect(original.createdAt, createdAt);
      expect(original.associatedDate, isNull);
      final future = DateTime.now().add(const Duration(days: 7));
      final day = DateTime(future.year, future.month, future.day);
      await repository.saveNote(original.copyWith(associatedDate: future));
      final assigned = (await repository.listNotes()).single;
      expect(assigned.associatedDate, day);
      await repository.saveNote(assigned.copyWith(clearAssociatedDate: true));
      expect((await repository.listNotes()).single.associatedDate, isNull);
    },
  );

  test(
    'journal persistence accepts today and rejects future creation and updates',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final repository = DriftJournalRepository(database);
      final today = DateTime.now();
      final future = DateTime(today.year, today.month, today.day + 1);
      final saved = await repository.saveEntry(
        JournalEntryModel.create(content: 'Today', entryDate: today),
      );
      final invalid = JournalEntryModel.create(
        content: 'Future',
        entryDate: future,
      );
      expect(invalid.isValid, isFalse);
      await expectLater(
        repository.saveEntry(invalid),
        throwsA(isA<InvalidJournalEntryException>()),
      );
      await expectLater(
        repository.updateEntry(saved.copyWith(entryDate: future)),
        throwsA(isA<InvalidJournalEntryException>()),
      );
      expect(
        (await repository.listEntries()).single.entryDate,
        saved.entryDate,
      );
    },
  );
}
