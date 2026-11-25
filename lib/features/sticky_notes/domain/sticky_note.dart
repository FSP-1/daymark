enum StickyNoteValidationError { empty }

class StickyNote {
  const StickyNote._({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.createdAt,
    required this.drawingData,
    required this.associatedDate,
    required this.validationError,
  });

  factory StickyNote.create({
    String? content,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? drawingData,
    DateTime? associatedDate,
  }) {
    final noteContent = content ?? '';
    return StickyNote._(
      title: title,
      subtitle: subtitle,
      content: noteContent,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      associatedDate: _dateOnly(associatedDate),
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
    DateTime? associatedDate,
  }) {
    return StickyNote._(
      id: id,
      title: title,
      subtitle: subtitle,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      associatedDate: _dateOnly(associatedDate),
      validationError: null,
    );
  }

  final int? id;
  final String? title;
  final String? subtitle;
  final String content;
  final DateTime createdAt;
  final String? drawingData;
  final DateTime? associatedDate;
  final StickyNoteValidationError? validationError;

  bool get isValid => validationError == null;

  StickyNote copyWith({
    String? content,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? drawingData,
    DateTime? associatedDate,
    bool clearTitle = false,
    bool clearSubtitle = false,
    bool clearDrawing = false,
    bool clearAssociatedDate = false,
  }) {
    final nextContent = content ?? this.content;
    return StickyNote._(
      id: id,
      title: clearTitle ? null : title ?? this.title,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      content: nextContent,
      createdAt: createdAt ?? this.createdAt,
      drawingData: clearDrawing ? null : drawingData ?? this.drawingData,
      associatedDate: clearAssociatedDate
          ? null
          : _dateOnly(associatedDate) ?? this.associatedDate,
      validationError: nextContent.trim().isEmpty
          ? StickyNoteValidationError.empty
          : null,
    );
  }

  static DateTime? _dateOnly(DateTime? date) =>
      date == null ? null : DateTime(date.year, date.month, date.day);
}
