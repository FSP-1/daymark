class JournalEntryModel {
  const JournalEntryModel({
    this.id,
    this.title,
    required this.content,
    required this.entryDate,
    this.drawingData,
    required this.createdAt,
    required this.updatedAt,
  });

  factory JournalEntryModel.create({
    String? title,
    String content = '',
    DateTime? entryDate,
    String? drawingData,
  }) {
    final now = DateTime.now();
    return JournalEntryModel(
      title: _clean(title),
      content: content,
      entryDate: _dateOnly(entryDate ?? now),
      drawingData: drawingData,
      createdAt: now,
      updatedAt: now,
    );
  }

  final int? id;
  final String? title;
  final String content;
  final DateTime entryDate;
  final String? drawingData;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isValid => content.trim().isNotEmpty || drawingData?.isNotEmpty == true;

  JournalEntryModel copyWith({
    String? title,
    String? content,
    DateTime? entryDate,
    String? drawingData,
    bool clearDrawing = false,
    DateTime? updatedAt,
  }) => JournalEntryModel(
    id: id,
    title: _clean(title ?? this.title),
    content: content ?? this.content,
    entryDate: _dateOnly(entryDate ?? this.entryDate),
    drawingData: clearDrawing ? null : drawingData ?? this.drawingData,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static String? _clean(String? value) =>
      value?.trim().isEmpty == true ? null : value?.trim();

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
