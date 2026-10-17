import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/filtering/search_filter.dart';

class _Item {
  const _Item(this.text, this.createdAt);

  final String text;
  final DateTime createdAt;
}

void main() {
  final today = DateTime.now();
  final items = [
    _Item('Shopping list', today.subtract(const Duration(days: 2))),
    _Item('Project notes', today.subtract(const Duration(days: 1))),
    _Item('Shopping ideas', today),
  ];

  test('filters by text through a reusable selector', () {
    final result = filterItems(
      items,
      SearchFilter(text: 'shopping'),
      textSelector: (item) => item.text,
      dateSelector: (item) => item.createdAt,
    );

    expect(result, hasLength(2));
  });

  test('filters by inclusive date range', () {
    final result = filterItems(
      items,
      SearchFilter(
        fromDate: today.subtract(const Duration(days: 1)),
        toDate: today.subtract(const Duration(days: 1)),
      ),
      textSelector: (item) => item.text,
      dateSelector: (item) => item.createdAt,
    );

    expect(result.single.text, 'Project notes');
  });

  test('combines text and date criteria and restores all when clear', () {
    final filtered = filterItems(
      items,
      SearchFilter(text: 'shopping', fromDate: today, toDate: today),
      textSelector: (item) => item.text,
      dateSelector: (item) => item.createdAt,
    );
    final all = filterItems(
      items,
      const SearchFilter(),
      textSelector: (item) => item.text,
      dateSelector: (item) => item.createdAt,
    );

    expect(filtered.single.text, 'Shopping ideas');
    expect(all, hasLength(3));
  });
}
