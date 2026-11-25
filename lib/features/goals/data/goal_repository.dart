import 'package:drift/drift.dart';

import '../../sticky_notes/data/local/app_database.dart';
import '../domain/goal.dart';

class GoalRepository {
  const GoalRepository(this.database);

  final AppDatabase database;

  Stream<List<Goal>> watchGoals() {
    final query =
        database.select(database.goals).join([
          leftOuterJoin(
            database.goalMilestones,
            database.goalMilestones.goalId.equalsExp(database.goals.id),
          ),
          leftOuterJoin(
            database.dailyGoalCredits,
            database.dailyGoalCredits.goalId.equalsExp(database.goals.id) &
                (database.dailyGoalCredits.milestoneId.isNull() |
                    database.dailyGoalCredits.milestoneId.equalsExp(
                      database.goalMilestones.id,
                    )),
          ),
        ])..orderBy([
          OrderingTerm.desc(database.goals.id),
          OrderingTerm.asc(database.goalMilestones.sortOrder),
        ]);
    return query.watch().map((rows) {
      final goalRows = <int, GoalRow>{};
      final steps = <int, Map<int, GoalMilestoneRow>>{};
      final credits = <int, Map<(int, String), DailyGoalCredit>>{};
      for (final row in rows) {
        final goal = row.readTable(database.goals);
        goalRows[goal.id] = goal;
        final step = row.readTableOrNull(database.goalMilestones);
        if (step != null) {
          (steps[goal.id] ??= {})[step.id] = step;
        }
        final credit = row.readTableOrNull(database.dailyGoalCredits);
        if (credit != null) {
          (credits[goal.id] ??= {})[(credit.activityId, credit.localDate)] =
              credit;
        }
      }
      return [
        for (final row in goalRows.values)
          Goal(
            id: row.id,
            title: row.title,
            description: row.description,
            icon: GoalIcon.values.byName(row.iconId),
            color: GoalColor.values.byName(row.color),
            tracking: GoalTracking.values.byName(row.trackingType),
            startDate: DateTime.parse(row.startDate),
            targetDate: row.targetDate == null
                ? null
                : DateTime.parse(row.targetDate!),
            targetValue: row.targetValue,
            manualProgress: row.manualProgress,
            dailyCredits: credits[row.id]?.length ?? 0,
            milestones: [
              for (final step
                  in steps[row.id]?.values ?? const <GoalMilestoneRow>[])
                GoalMilestone(
                  id: step.id,
                  title: step.title,
                  createdAt: step.createdAt,
                  completedAt: step.completedAt,
                  activityId: step.activityId,
                  fromDaily:
                      credits[row.id]?.values.any(
                        (credit) => credit.milestoneId == step.id,
                      ) ??
                      false,
                ),
            ],
            createdAt: row.createdAt,
            updatedAt: row.updatedAt,
            completionDate:
                row.completedAt ?? _latestCreditDate(credits[row.id]?.values),
          ),
      ];
    });
  }

  Future<int> save(
    Goal goal, {
    int? counterActivityId,
    bool updateCounterLink = false,
  }) {
    if (!goal.valid || goal.tracking == GoalTracking.manual) {
      throw ArgumentError('Invalid goal');
    }
    return database.transaction(() async {
      final now = DateTime.now();
      final existing = goal.id == null
          ? null
          : await (database.select(
              database.goals,
            )..where((row) => row.id.equals(goal.id!))).getSingle();
      final values = GoalsCompanion.insert(
        title: goal.title.trim(),
        description: goal.description.trim(),
        category: existing?.category ?? '',
        iconId: goal.icon.name,
        color: goal.color.name,
        trackingType: goal.tracking.name,
        startDate: _dateKey(goal.startDate),
        targetDate: Value(
          goal.targetDate == null ? null : _dateKey(goal.targetDate!),
        ),
        targetValue: goal.targetValue,
        currentValue: existing?.trackingType == GoalTracking.counter.name
            ? existing!.currentValue
            : 0,
        unit: existing?.unit ?? '',
        manualProgress: goal.manualProgress,
        createdAt: existing?.createdAt ?? now,
        updatedAt: now,
        completedAt: Value(goal.completed ? goal.completedAt ?? now : null),
      );
      final id = goal.id ?? await database.into(database.goals).insert(values);
      if (existing != null) {
        await (database.update(
          database.goals,
        )..where((row) => row.id.equals(id))).write(values);
        if (existing.trackingType != goal.tracking.name) {
          await (database.delete(
            database.dailyGoalCredits,
          )..where((row) => row.goalId.equals(id))).go();
        }
      }
      if (goal.tracking == GoalTracking.counter) {
        if (updateCounterLink) {
          final activityId = counterActivityId;
          if (activityId == null) {
            throw ArgumentError('A Daily activity is required');
          }
          await _linkActivity(id, activityId);
          await _unlinkOtherActivities(id, [activityId]);
        } else {
          final link =
              await (database.select(database.dailyActivities)
                    ..where((row) => row.goalId.equals(id))
                    ..limit(1))
                  .getSingleOrNull();
          if (link == null) throw ArgumentError('A Daily activity is required');
        }
      }
      final milestones = goal.tracking == GoalTracking.checklist
          ? goal.milestones
          : const <GoalMilestone>[];
      final retained = milestones
          .map((step) => step.id)
          .whereType<int>()
          .toList();
      await (database.delete(database.goalMilestones)..where(
            (row) =>
                row.goalId.equals(id) &
                (retained.isEmpty
                    ? const Constant(true)
                    : row.id.isNotIn(retained)),
          ))
          .go();
      final activityIds = <int>[];
      for (final (index, step) in milestones.indexed) {
        final activityId = step.activityId;
        if (activityId != null) {
          if (activityIds.contains(activityId))
            throw ArgumentError('Repeated Daily activity');
          await _linkActivity(id, activityId);
          activityIds.add(activityId);
        }
        final values = GoalMilestonesCompanion.insert(
          goalId: id,
          title: step.title.trim(),
          sortOrder: index,
          createdAt: step.createdAt,
          completedAt: Value(step.completedAt),
          activityId: Value(activityId),
        );
        if (step.id == null) {
          await database.into(database.goalMilestones).insert(values);
        } else {
          final changed =
              await (database.update(database.goalMilestones)..where(
                    (row) => row.goalId.equals(id) & row.id.equals(step.id!),
                  ))
                  .write(values);
          if (changed != 1) throw StateError('Goal milestone no longer exists');
        }
      }
      if (goal.tracking == GoalTracking.checklist) {
        await _unlinkOtherActivities(id, activityIds);
      }
      return id;
    });
  }

  Future<void> _linkActivity(int goalId, int activityId) async {
    final changed =
        await (database.update(database.dailyActivities)..where(
              (row) =>
                  row.id.equals(activityId) &
                  (row.goalId.isNull() | row.goalId.equals(goalId)),
            ))
            .write(DailyActivitiesCompanion(goalId: Value(goalId)));
    if (changed != 1) throw StateError('Daily activity is unavailable');
  }

  Future<void> _unlinkOtherActivities(int goalId, List<int> retained) async {
    await (database.update(database.dailyActivities)..where(
          (row) =>
              row.goalId.equals(goalId) &
              (retained.isEmpty
                  ? const Constant(true)
                  : row.id.isNotIn(retained)),
        ))
        .write(const DailyActivitiesCompanion(goalId: Value(null)));
  }

  Future<void> delete(int id) => database.transaction(() async {
    await (database.update(database.dailyActivities)
          ..where((row) => row.goalId.equals(id)))
        .write(const DailyActivitiesCompanion(goalId: Value(null)));
    await (database.delete(
      database.dailyGoalCredits,
    )..where((row) => row.goalId.equals(id))).go();
    await (database.delete(
      database.goalMilestones,
    )..where((row) => row.goalId.equals(id))).go();
    await (database.delete(
      database.goals,
    )..where((row) => row.id.equals(id))).go();
  });

  String _dateKey(DateTime date) =>
      Goal.day(date).toIso8601String().split('T').first;

  DateTime? _latestCreditDate(Iterable<DailyGoalCredit>? credits) {
    String? latest;
    for (final credit in credits ?? const <DailyGoalCredit>[]) {
      if (latest == null || credit.localDate.compareTo(latest) > 0) {
        latest = credit.localDate;
      }
    }
    return latest == null ? null : DateTime.tryParse(latest);
  }
}
