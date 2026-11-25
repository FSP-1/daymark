import 'package:daymark/features/daily/data/daily_repository.dart';
import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_repository.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';
import 'package:daymark/features/goals/data/goal_repository.dart';
import 'package:daymark/features/goals/domain/goal.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart'
    show AppDatabase;
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2025);

  test('a counter requires one Daily and counts completed, nonconsecutive days once', () async {
    final database = AppDatabase.test();
    addTearDown(database.close);
    final goals = GoalRepository(database);
    final daily = DriftDailyRepository(database);
    final draft = Goal(
      title: 'Read',
      startDate: start,
      tracking: GoalTracking.counter,
      targetValue: 2,
    );

    await expectLater(goals.save(draft), throwsArgumentError);
    expect(await goals.watchGoals().first, isEmpty);
    final activity = await daily.saveActivity(
      DailyActivity(
        id: null,
        name: 'Read daily',
        schedule: const DailySchedule.anytime(),
        notificationsEnabled: false,
        createdAt: start,
        updatedAt: start,
      ),
    );
    final id = await goals.save(
      draft,
      counterActivityId: activity.id,
      updateCounterLink: true,
    );
    expect((await daily.listActivities()).single.goalId, id);
    await expectLater(
      daily.deleteActivity(activity.id!),
      throwsA(isA<RequiredGoalActivity>()),
    );
    Future<void> check(String date, bool value) => daily.setCompleted(
      activityId: activity.id!,
      localDate: date,
      completed: value,
    );
    await check('2025-01-01', true);
    await check('2025-01-01', true);
    expect((await goals.watchGoals().first).single.totalValue, 1);
    await check('2025-01-04', true);
    expect((await goals.watchGoals().first).single.completed, isTrue);
    await check('2025-01-01', false);
    expect((await goals.watchGoals().first).single.completed, isFalse);
    final replacement = await daily.saveActivity(
      DailyActivity(
        id: null,
        name: 'Read on weekends',
        schedule: const DailySchedule.anytime(),
        notificationsEnabled: false,
        createdAt: start,
        updatedAt: start,
      ),
    );
    await goals.save(
      (await goals.watchGoals().first).single,
      counterActivityId: replacement.id,
      updateCounterLink: true,
    );
    expect(
      (await daily.listActivities())
          .singleWhere((item) => item.id == activity.id)
          .goalId,
      isNull,
    );
    await daily.setCompleted(
      activityId: replacement.id!,
      localDate: '2025-01-07',
      completed: true,
    );
    expect((await goals.watchGoals().first).single.completed, isTrue);
    await goals.delete(id);
    expect(
      (await daily.listActivities()).every((item) => item.goalId == null),
      isTrue,
    );
  });

  test(
    'multiple Daily activities update only their respective checklist items',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final goals = GoalRepository(database);
      final daily = DriftDailyRepository(database);
      final existing = await daily.saveActivity(
        DailyActivity(
          id: null,
          name: 'Plan activity',
          schedule: const DailySchedule.anytime(),
          notificationsEnabled: false,
          createdAt: start,
          updatedAt: start,
        ),
      );
      final build = await daily.saveActivity(
        DailyActivity(
          id: null,
          name: 'Build',
          schedule: const DailySchedule.anytime(),
          notificationsEnabled: false,
          createdAt: start,
          updatedAt: start,
        ),
      );
      final id = await goals.save(
        Goal(
          title: 'Project',
          startDate: start,
          milestones: [
            GoalMilestone(title: 'Plan', activityId: existing.id),
            GoalMilestone(title: 'Build', activityId: build.id),
            GoalMilestone(title: 'Publish'),
          ],
        ),
      );
      final activities = await daily.listActivities();
      expect(activities.map((item) => item.goalId), [id, id]);
      await daily.setCompleted(
        activityId: build.id!,
        localDate: '2025-01-04',
        completed: true,
      );
      final goal = (await goals.watchGoals().first).single;
      expect(goal.milestones.map((step) => step.complete), [
        false,
        true,
        false,
      ]);
      expect(goal.milestones.map((step) => step.linked), [true, true, false]);
      await daily.setCompleted(
        activityId: existing.id!,
        localDate: '2025-01-04',
        completed: true,
      );
      expect((await goals.watchGoals().first).single.completedSteps, 2);
      await daily.setCompleted(
        activityId: build.id!,
        localDate: '2025-01-04',
        completed: false,
      );
      expect(
        (await goals.watchGoals().first).single.milestones.map(
          (step) => step.complete,
        ),
        [true, false, false],
      );
    },
  );
}
