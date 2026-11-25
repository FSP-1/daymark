import 'package:flutter/foundation.dart';

import '../../journal/domain/journal_entry.dart';
import '../../sticky_notes/domain/sticky_note.dart';
import '../../goals/domain/goal.dart';
import '../../focus/domain/focus_session.dart';

class CalendarViewModel extends ChangeNotifier {
  CalendarViewModel({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    today = dateOnly(_clock());
    selected = today;
    displayed = DateTime(today.year, today.month);
  }

  final DateTime Function() _clock;
  late DateTime today;
  late DateTime selected;
  late DateTime displayed;
  bool annual = false;

  bool get canWriteJournal => !selected.isAfter(today);

  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static List<DateTime?> monthDays(DateTime month, int firstWeekday) {
    final first = DateTime(month.year, month.month);
    final offset = (first.weekday % 7 - firstWeekday) % 7;
    return [
      for (var index = 0; index < offset; index++) null,
      for (
        var day = 1;
        day <= DateTime(month.year, month.month + 1, 0).day;
        day++
      )
        DateTime(month.year, month.month, day),
    ];
  }

  void refreshToday() {
    final next = dateOnly(_clock());
    if (next == today) return;
    today = next;
    notifyListeners();
  }

  void goToToday() {
    today = dateOnly(_clock());
    selected = today;
    displayed = DateTime(today.year, today.month);
    annual = false;
    notifyListeners();
  }

  void select(DateTime date) {
    selected = dateOnly(date);
    notifyListeners();
  }

  void showAnnual(bool value) {
    annual = value;
    notifyListeners();
  }

  void openMonth(int month) {
    annual = false;
    _showMonth(DateTime(displayed.year, month));
  }

  bool canMove(int direction) {
    final month = _adjacentMonth(direction);
    return month.year >= 1 && month.year <= 9999;
  }

  void move(int direction) {
    if (canMove(direction)) _showMonth(_adjacentMonth(direction));
  }

  DateTime _adjacentMonth(int direction) => annual
      ? DateTime(displayed.year + direction, displayed.month)
      : DateTime(displayed.year, displayed.month + direction);

  void _showMonth(DateTime month) {
    displayed = month;
    final last = DateTime(month.year, month.month + 1, 0).day;
    selected = DateTime(month.year, month.month, selected.day.clamp(1, last));
    notifyListeners();
  }
}

class CalendarContent {
  CalendarContent(
    Iterable<StickyNote> notes,
    Iterable<JournalEntryModel> entries, [
    Iterable<Goal> goals = const [],
    Iterable<FocusSession> sessions = const [],
  ]) {
    for (final note in notes) {
      final date = note.associatedDate;
      if (date != null) {
        (notesByDay[CalendarViewModel.dateOnly(date)] ??= []).add(note);
      }
    }
    for (final entry in entries) {
      (entriesByDay[CalendarViewModel.dateOnly(entry.entryDate)] ??= []).add(
        entry,
      );
    }
    for (final goal in goals) {
      final date = goal.targetDate;
      if (date != null) {
        (goalsByDay[CalendarViewModel.dateOnly(date)] ??= []).add(goal);
      }
    }
    for (final session in sessions) {
      final days = <DateTime>{
        for (final interval in session.intervals)
          for (
            var day = focusDay(interval.start);
            day.isBefore(interval.end);
            day = focusNextDay(day)
          )
            day,
      };
      for (final day in days) {
        (focusByDay[day] ??= []).add(session);
      }
    }
  }

  final notesByDay = <DateTime, List<StickyNote>>{};
  final entriesByDay = <DateTime, List<JournalEntryModel>>{};
  final goalsByDay = <DateTime, List<Goal>>{};
  final focusByDay = <DateTime, List<FocusSession>>{};
}
