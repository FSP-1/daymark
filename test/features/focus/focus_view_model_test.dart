import 'package:daymark/features/calendar/presentation/calendar_view_model.dart';
import 'package:daymark/features/focus/data/focus_repository.dart';
import 'package:daymark/features/focus/domain/focus_session.dart';
import 'package:daymark/features/focus/domain/focus_statistics.dart';
import 'package:daymark/features/focus/presentation/focus_view_model.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'persists Daily links and keeps recorded labels after unlinking',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final repository = FocusRepository(database);
      var now = DateTime(2026, 10, 10, 18);
      final model = FocusViewModel(
        repository,
        clock: () => now,
        observeLifecycle: false,
      );
      addTearDown(model.dispose);
      await model.restore();
      await model.setDailyLinked(7, true);
      expect((await repository.load()).dailyActivityIds, {7});
      model.selectActivity('daily:7', 'Read');
      await model.startOrResume();
      now = now.add(const Duration(minutes: 1));
      await model.stop();
      await model.setDailyLinked(7, false);
      expect(model.activityKey, isNull);
      expect((await repository.load()).dailyActivityIds, isEmpty);
      expect(
        (await repository.watchHistory().first).single.activityLabel,
        'Read',
      );
    },
  );

  test('restores the running deadline, records once, and does not auto-start after recovery', () async {
    final database = AppDatabase.test();
    addTearDown(database.close);
    final repository = FocusRepository(database);
    var now = DateTime(2026, 10, 10, 18);
    final first = FocusViewModel(
      repository,
      clock: () => now,
      observeLifecycle: false,
    );
    await first.restore();
    await first.updateSettings(
      const FocusSettings(
        focus: 1,
        autoBreak: true,
        sound: false,
        vibration: false,
      ),
    );
    first.selectActivity('daily:1', 'Read');
    await first.startOrResume();
    final id = first.active!.id;
    final expected = now.add(const Duration(minutes: 1));
    expect(first.active!.expectedEnd, expected);
    first.dispose();

    now = now.add(const Duration(hours: 1));
    final restored = FocusViewModel(
      repository,
      clock: () => now,
      observeLifecycle: false,
    );
    addTearDown(restored.dispose);
    await restored.restore();
    await restored.refresh(recovered: true);
    expect(restored.active, isNull);
    expect(restored.mode, FocusMode.shortBreak);
    expect(restored.cycleCount, 1);
    final history = await repository.watchHistory().first;
    expect(history, hasLength(1));
    expect(history.single.id, id);
    expect(history.single.finished, expected);
    expect(history.single.activityLabel, 'Read');
    expect(history.single.goalLabel, isNull);
  });

  test(
    'restores a pause and splits active intervals at local midnight',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final repository = FocusRepository(database);
      var now = DateTime(2026, 10, 10, 23, 59, 50);
      final first = FocusViewModel(
        repository,
        clock: () => now,
        observeLifecycle: false,
      );
      await first.restore();
      await first.updateSettings(const FocusSettings(focus: 1));
      await first.startOrResume();
      now = now.add(const Duration(seconds: 20));
      await first.pause();
      expect(first.remaining, const Duration(seconds: 40));
      first.dispose();
      now = now.add(const Duration(minutes: 10));

      final restored = FocusViewModel(
        repository,
        clock: () => now,
        observeLifecycle: false,
      );
      addTearDown(restored.dispose);
      await restored.restore();
      expect(restored.remaining, const Duration(seconds: 40));
      expect(restored.active!.running, isFalse);
      await restored.startOrResume();
      now = now.add(const Duration(seconds: 15));
      await restored.stop();
      final history = await repository.watchHistory().first;
      expect(history.single.actual, const Duration(seconds: 35));
      expect(history.single.completed, isFalse);
      final yesterday = DateTime(2026, 10, 10);
      final today = DateTime(2026, 10, 11);
      expect(
        FocusStatistics(history, yesterday, today).concentration.inSeconds,
        10,
      );
      expect(
        FocusStatistics(
          history,
          today,
          focusNextDay(today),
        ).concentration.inSeconds,
        25,
      );
      final calendar = CalendarContent([], [], [], history);
      expect(calendar.focusByDay[yesterday], hasLength(1));
      expect(calendar.focusByDay[today], hasLength(1));
      await restored.deleteSession(history.single.id);
      expect(await repository.watchHistory().first, isEmpty);
    },
  );

  test(
    'selects the fourth-session long break and respects settings bounds',
    () {
      expect(nextFocusMode(FocusMode.focus, 3, 4), FocusMode.shortBreak);
      expect(nextFocusMode(FocusMode.focus, 4, 4), FocusMode.longBreak);
      expect(nextFocusMode(FocusMode.longBreak, 4, 4), FocusMode.focus);
      expect(
        FocusSettings.fromJson({'focus': 999, 'shortBreak': 0}).focus,
        120,
      );
      expect(
        FocusSettings.fromJson({'focus': 999, 'shortBreak': 0}).shortBreak,
        1,
      );
      expect(FocusClock.timeText(const Duration(hours: 2)), '120:00');
    },
  );
}
