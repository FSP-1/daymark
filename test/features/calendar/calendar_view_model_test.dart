import 'package:daymark/features/calendar/presentation/calendar_view_model.dart';
import 'package:daymark/features/journal/domain/journal_entry.dart';
import 'package:daymark/features/sticky_notes/domain/sticky_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates a localized week offset and includes leap day', () {
    final february = DateTime(2024, 2);
    final mondayFirst = CalendarViewModel.monthDays(february, 1);
    expect(mondayFirst.take(3), everyElement(isNull));
    expect(mondayFirst[3], february);
    expect(mondayFirst.last, DateTime(2024, 2, 29));
    expect(CalendarViewModel.monthDays(february, 0)[4], february);
    expect(
      CalendarViewModel.monthDays(DateTime(2025, 2), 1).last,
      DateTime(2025, 2, 28),
    );
  });

  test('navigates months and years and resets to the local day', () {
    var now = DateTime(2024, 12, 31, 23, 59);
    final model = CalendarViewModel(clock: () => now);
    addTearDown(model.dispose);
    expect(model.selected, DateTime(2024, 12, 31));
    model.move(1);
    expect(model.displayed, DateTime(2025, 1));
    expect(model.canWriteJournal, isFalse);
    model.showAnnual(true);
    model.move(-1);
    model.openMonth(2);
    expect(model.selected, DateTime(2024, 2, 29));
    expect(model.annual, isFalse);
    expect(model.canWriteJournal, isTrue);
    now = DateTime(2025);
    model.refreshToday();
    expect(model.today, DateTime(2025));
    expect(model.selected, DateTime(2024, 2, 29));
    model.goToToday();
    expect(model.selected, DateTime(2025));
  });

  test(
    'groups both content types by assigned day without using creation dates',
    () {
      final day = DateTime(2024, 2, 29);
      final assigned = StickyNote.create(
        content: 'One',
        associatedDate: DateTime(2024, 2, 29, 23),
      );
      final unassigned = StickyNote.create(content: 'Two', createdAt: day);
      final entry = JournalEntryModel.create(content: 'Three', entryDate: day);
      final content = CalendarContent([assigned, unassigned], [entry, entry]);
      expect(content.notesByDay[day], [assigned]);
      expect(content.entriesByDay[day], [entry, entry]);
    },
  );
}
