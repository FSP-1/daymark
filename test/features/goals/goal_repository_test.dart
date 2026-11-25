import 'package:daymark/features/calendar/presentation/calendar_view_model.dart';
import 'package:daymark/features/goals/data/goal_repository.dart';
import 'package:daymark/features/goals/domain/goal.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'stores steps in order, tracks completion, and removes steps with a goal',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final repository = GoalRepository(database);
      final start = DateTime(2025, 1, 1);
      final target = DateTime(2026, 1, 1);
      final goal = Goal(
        title: 'Study',
        startDate: start,
        targetDate: target,
        milestones: [
          GoalMilestone(title: 'Read'),
          GoalMilestone(title: 'Practice'),
        ],
      );
      final id = await repository.save(goal);
      final saved = (await repository.watchGoals().first).single;
      expect(saved.id, id);
      expect(saved.targetDate, target);
      expect(CalendarContent([], [], [saved]).goalsByDay[target], [saved]);

      final ordered = saved.withProgress(
        steps: [
          saved.milestones[1].toggle(),
          saved.milestones[0].rename('Read chapter').toggle(),
        ],
      );
      await repository.save(ordered);
      final completed = (await repository.watchGoals().first).single;
      expect(completed.completedAt, isNotNull);
      expect(completed.milestones.map((step) => step.title), [
        'Practice',
        'Read chapter',
      ]);
      expect(completed.milestones.last.id, saved.milestones.first.id);
      await repository.save(
        completed.withProgress(steps: [completed.milestones.first.toggle()]),
      );
      final reopened = (await repository.watchGoals().first).single;
      expect(reopened.completedAt, isNull);
      expect(reopened.milestones, hasLength(1));
      await repository.delete(id);
      expect(await repository.watchGoals().first, isEmpty);
      expect(await database.select(database.goalMilestones).get(), isEmpty);
    },
  );
}
