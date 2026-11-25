import 'package:daymark/features/goals/domain/goal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final start = DateTime(2025, 1, 1);

  test(
    'checklist calculates progress and reopens when a step is unchecked',
    () {
      final goal = Goal(title: 'Project', startDate: start);
      expect(goal.progress, 0);
      final step = GoalMilestone(title: 'Start');
      final complete = goal.withProgress(steps: [step.toggle()]);
      expect(complete.completed, isTrue);
      expect(complete.withProgress(steps: [step]).completed, isFalse);
      expect(goal.withProgress(steps: [step, step.toggle()]).percentage, 50);
    },
  );

  test('counter only accepts positive whole-number targets', () {
    final counter = Goal(
      title: 'Books',
      startDate: start,
      tracking: GoalTracking.counter,
      targetValue: 12,
      dailyCredits: 5,
    );
    expect(counter.percentage, 42);
    expect(
      Goal(
        title: 'Fractional',
        startDate: start,
        tracking: GoalTracking.counter,
        targetValue: 1.5,
      ).valid,
      isFalse,
    );
    expect(
      Goal(
        title: 'Zero',
        startDate: start,
        tracking: GoalTracking.counter,
        targetValue: 0,
      ).valid,
      isFalse,
    );
  });

  test('deadlines validate independently of status and use calendar dates', () {
    final deadline = DateTime(2025, 1, 4);
    final goal = Goal(
      title: 'Date',
      startDate: start,
      targetDate: deadline,
      tracking: GoalTracking.manual,
    );
    expect(goal.valid, isTrue);
    expect(goal.overdue(DateTime(2025, 1, 4, 20)), isFalse);
    expect(goal.overdue(DateTime(2025, 1, 5)), isTrue);
    expect(
      goal.withProgress(percent: 100).overdue(DateTime(2025, 1, 5)),
      isFalse,
    );
    expect(Goal(title: ' ', startDate: start).valid, isFalse);
    expect(
      Goal(title: 'Early', startDate: start, targetDate: DateTime(2024)).valid,
      isFalse,
    );
  });
}
