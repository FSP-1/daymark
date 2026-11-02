import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';

void main() {
  test('validates names and schedule invariants', () {
    final now = DateTime(2026, 11, 1);
    final anytime = DailyActivity(
      id: null,
      name: 'Read',
      schedule: const DailySchedule.anytime(),
      notificationsEnabled: false,
      createdAt: now,
      updatedAt: now,
    );
    expect(anytime.isValid, isTrue);
    expect(anytime.copyWith(name: '  ').isValid, isFalse);
    expect(anytime.copyWith(notificationsEnabled: true).isValid, isFalse);
    expect(
      anytime
          .copyWith(schedule: const DailySchedule.specific(hour: 25, minute: 0))
          .isValid,
      isFalse,
    );
  });
}
