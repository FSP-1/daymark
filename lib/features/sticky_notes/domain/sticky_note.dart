enum StickyNoteValidationError { empty }

class StickyNote {
  const StickyNote._({
    this.id,
    required this.content,
    required this.validationError,
  });

  factory StickyNote.create(String content) {
    return StickyNote._(
      content: content,
      validationError: content.trim().isEmpty
          ? StickyNoteValidationError.empty
          : null,
    );
  }

  factory StickyNote.fromStorage({
    required int id,
    required String content,
  }) {
    return StickyNote._(
      id: id,
      content: content,
      validationError: null,
    );
  }

  final int? id;
  final String content;
  final StickyNoteValidationError? validationError;

  bool get isValid => validationError == null;
}
