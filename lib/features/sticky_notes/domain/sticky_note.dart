enum StickyNoteValidationError { empty }

enum NoteFormat { text, checklist, numbered }

class StickyNote {
  const StickyNote._({
    this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.createdAt,
    required this.drawingData,
    required this.associatedDate,
    required this.format,
    required this.checkedItems,
    required this.validationError,
  });

  factory StickyNote.create({
    String? content,
    String? title,
    String? subtitle,
    DateTime? createdAt,
    String? drawingData,
    DateTime? associatedDate,
    NoteFormat format = NoteFormat.text,
  }) {
    final noteContent = content ?? '';
    return StickyNote._(
      title: title,
      subtitle: subtitle,
      content: noteContent,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      associatedDate: _dateOnly(associatedDate),
      format: format,
      checkedItems: const {},
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
    NoteFormat format = NoteFormat.text,
    Set<int> checkedItems = const {},
  }) {
    return StickyNote._(
      id: id,
      title: title,
      subtitle: subtitle,
      content: content,
      createdAt: createdAt ?? DateTime.now(),
      drawingData: drawingData,
      associatedDate: _dateOnly(associatedDate),
      format: format,
      checkedItems: Set.unmodifiable(checkedItems),
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
  final NoteFormat format;
  final Set<int> checkedItems;
  List<String> get items => listItems(content);

  static List<String> listItems(String text) => text
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
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
    NoteFormat? format,
    Set<int>? checkedItems,
  }) {
    final nextContent = content ?? this.content;
    final nextFormat = format ?? this.format;
    return StickyNote._(
      id: id,
      title: clearTitle ? null : title ?? this.title,
      subtitle: clearSubtitle ? null : subtitle ?? this.subtitle,
      content: nextContent,
      createdAt: createdAt ?? this.createdAt,
      drawingData: clearDrawing ? null : drawingData ?? this.drawingData,
      format: nextFormat,
      checkedItems: nextFormat == NoteFormat.checklist
          ? Set.unmodifiable(checkedItems ?? _checksFor(nextContent))
          : const {},
      associatedDate: clearAssociatedDate
          ? null
          : _dateOnly(associatedDate) ?? this.associatedDate,
      validationError: nextContent.trim().isEmpty
          ? StickyNoteValidationError.empty
          : null,
    );
  }

  Set<int> _checksFor(String nextContent) {
    if (nextContent == content) return checkedItems;
    final positions = <String, List<int>>{};
    for (final (index, item) in items.indexed) {
      (positions[item] ??= []).add(index);
    }
    final used = <String, int>{};
    return {
      for (final (index, item) in listItems(nextContent).indexed)
        if (_takeCheck(item, positions, used)) index,
    };
  }

  bool _takeCheck(
    String item,
    Map<String, List<int>> positions,
    Map<String, int> used,
  ) {
    final previous = positions[item];
    final occurrence = used.update(
      item,
      (value) => value + 1,
      ifAbsent: () => 0,
    );
    return previous != null &&
        occurrence < previous.length &&
        checkedItems.contains(previous[occurrence]);
  }

  static DateTime? _dateOnly(DateTime? date) =>
      date == null ? null : DateTime(date.year, date.month, date.day);
}
