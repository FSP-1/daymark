import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';

void main() {
  group('StickyNote validation', () {
    test('accepts text containing a non-whitespace character', () {
      final note = StickyNote.create(content: '  Remember milk  ');

      expect(note.isValid, isTrue);
    });

    test('rejects empty text', () {
      final note = StickyNote.create(content: '');

      expect(note.isValid, isFalse);
      expect(note.validationError, StickyNoteValidationError.empty);
    });

    test('rejects whitespace-only text', () {
      final note = StickyNote.create(content: ' \n\t ');

      expect(note.isValid, isFalse);
      expect(note.validationError, StickyNoteValidationError.empty);
    });

    test('keeps optional title and subtitle with a creation date', () {
      final createdAt = DateTime(2026, 10, 17, 15, 30);
      final note = StickyNote.create(
        content: 'Content',
        title: 'Title',
        subtitle: 'Subtitle',
        createdAt: createdAt,
      );

      expect(note.title, 'Title');
      expect(note.subtitle, 'Subtitle');
      expect(note.createdAt, createdAt);
    });
  });
}
