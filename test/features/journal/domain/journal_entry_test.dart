import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/journal/domain/journal_entry.dart';

void main() {
  test('can explicitly remove an existing drawing', () {
    final entry = JournalEntryModel.create(
      content: '',
      drawingData: '[{"points":[]}]',
    );

    final cleared = entry.copyWith(clearDrawing: true);

    expect(cleared.drawingData, isNull);
    expect(cleared.isValid, isFalse);
  });

  test('copyWith preserves the persisted timestamp unless supplied', () {
    final created = DateTime(2026, 11, 3, 10);
    final entry = JournalEntryModel(
      id: 1,
      content: 'A memory',
      entryDate: DateTime(2026, 11, 3),
      createdAt: created,
      updatedAt: created,
    );

    expect(entry.copyWith(content: 'Updated').updatedAt, created);
    expect(
      entry.copyWith(updatedAt: DateTime(2026, 11, 3, 11)).updatedAt,
      DateTime(2026, 11, 3, 11),
    );
  });
}
