import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';

void main() {
  group('StickyNote validation', () {
    test('accepts text containing a non-whitespace character', () {
      final note = StickyNote.create('  Remember milk  ');

      expect(note.isValid, isTrue);
    });

    test('rejects empty text', () {
      final note = StickyNote.create('');

      expect(note.isValid, isFalse);
      expect(note.validationError, StickyNoteValidationError.empty);
    });

    test('rejects whitespace-only text', () {
      final note = StickyNote.create(' \n\t ');

      expect(note.isValid, isFalse);
      expect(note.validationError, StickyNoteValidationError.empty);
    });
  });
}
