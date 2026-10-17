enum StickyNoteValidationError { empty }

class StickyNote {
  const StickyNote._({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.createdAt,
    required this.drawingData,
    required this.validationError,
  });

  factory StickyNote.create({
    String? content,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? drawingData,
  }) {
    final noteContent = content ?? '';
    return StickyNote._(
      title: title,
      subtitle: subtitle,
      content: noteContent,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      validationError: noteContent.trim().isEmpty
          ? StickyNoteValidationError.empty
          : null,
    );
  }

  factory StickyNote.fromStorage({
    required int id,
    required String content,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? drawingData,
  }) {
    return StickyNote._(
      id: id,
      title: title,
      subtitle: subtitle,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      validationError: null,
    );
  }

  final int? id;
  final String? title;
  final String? subtitle;
  final String content;
  final DateTime createdAt;
  final String? drawingData;
  final StickyNoteValidationError? validationError;

  bool get isValid => validationError == null;
}
