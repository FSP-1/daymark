import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/features/daily/data/daily_repository.dart';
import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart'
    show AppDatabase;

void main() {
  test('persists activities and date-specific completion', () async {
    final database = AppDatabase.test();
    final repository = DriftDailyRepository(database);
    final now = DateTime(2026, 11, 1);
    final activity = await repository.saveActivity(
      DailyActivity(
        id: null,
        name: 'Walk',
        schedule: const DailySchedule.anytime(),
        notificationsEnabled: false,
        createdAt: now,
        updatedAt: now,
        iconKey: 'walk',
      ),
    );

    expect((await repository.listActivities()).single.iconKey, 'walk');
    await repository.setCompleted(
      activityId: activity.id!,
      localDate: '2026-11-01',
      completed: true,
    );
    expect(await repository.completedActivityIds('2026-11-01'), {activity.id});
    expect(await repository.completedActivityIds('2026-11-02'), isEmpty);
    await repository.setCompleted(
      activityId: activity.id!,
      localDate: '2026-11-01',
      completed: false,
    );
    expect(await repository.completedActivityIds('2026-11-01'), isEmpty);

    await repository.deleteActivity(activity.id!);
    expect(await repository.listActivities(), isEmpty);
    await database.close();
  });
}
