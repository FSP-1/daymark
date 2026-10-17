class SearchFilter {
  const SearchFilter({this.text = '', this.fromDate, this.toDate});

  final String text;
  final DateTime? fromDate;
  final DateTime? toDate;

  bool get isEmpty => text.trim().isEmpty && fromDate == null && toDate == null;

  bool matches({required String searchableText, required DateTime date}) {
    final normalizedQuery = text.trim().toLowerCase();
    final matchesText =
        normalizedQuery.isEmpty ||
        searchableText.toLowerCase().contains(normalizedQuery);
    final day = DateTime(date.year, date.month, date.day);
    final matchesFrom = fromDate == null || !day.isBefore(_dateOnly(fromDate!));
    final boundedToDate = toDate == null
        ? null
        : _dateOnly(toDate!).isAfter(_dateOnly(DateTime.now()))
        ? _dateOnly(DateTime.now())
        : _dateOnly(toDate!);
    final matchesTo = boundedToDate == null || !day.isAfter(boundedToDate);
    return matchesText && matchesFrom && matchesTo;
  }

  DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}

Iterable<T> filterItems<T>(
  Iterable<T> items,
  SearchFilter filter, {
  required String Function(T item) textSelector,
  required DateTime Function(T item) dateSelector,
}) {
  if (filter.isEmpty) {
    return items;
  }
  return items.where(
    (item) => filter.matches(
      searchableText: textSelector(item),
      date: dateSelector(item),
    ),
  );
}
