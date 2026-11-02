import 'package:drift/drift.dart';

import '../../sticky_notes/data/local/app_database.dart' as db;
import '../domain/daily_activity.dart';
import '../domain/daily_repository.dart';
import '../domain/daily_schedule.dart';

class DriftDailyRepository implements DailyRepository {
  DriftDailyRepository(this.database);

  final db.AppDatabase database;

  @override
  Future<List<DailyActivity>> listActivities() async {
    final rows = await (database.select(
      database.dailyActivities,
    )..orderBy([(table) => OrderingTerm.asc(table.createdAt)])).get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<DailyActivity> saveActivity(DailyActivity activity) async {
    if (!activity.isValid) {
      throw ArgumentError('Invalid daily activity');
    }
    final now = DateTime.now();
    final companion = db.DailyActivitiesCompanion(
      id: activity.id == null ? const Value.absent() : Value(activity.id!),
      name: Value(activity.name.trim()),
      iconKey: Value(activity.iconKey),
      scheduleMode: Value(activity.schedule.mode.name),
      scheduledHour: Value(activity.schedule.hour),
      scheduledMinute: Value(activity.schedule.minute),
      notificationsEnabled: Value(
        activity.schedule.hasSpecificTime && activity.notificationsEnabled,
      ),
      createdAt: Value(activity.createdAt),
      updatedAt: Value(now),
    );
    final id = activity.id == null
        ? await database.into(database.dailyActivities).insert(companion)
        : await (database.update(
            database.dailyActivities,
          )..where((row) => row.id.equals(activity.id!))).write(companion);
    final savedId = activity.id ?? id;
    final row = await (database.select(
      database.dailyActivities,
    )..where((table) => table.id.equals(savedId))).getSingle();
    return _toDomain(row);
  }

  @override
  Future<void> deleteActivity(int id) async {
    await database.transaction(() async {
      await (database.delete(
        database.dailyCompletions,
      )..where((row) => row.activityId.equals(id))).go();
      await (database.delete(
        database.dailyActivities,
      )..where((row) => row.id.equals(id))).go();
    });
  }

  @override
  Future<Set<int>> completedActivityIds(String localDate) async {
    final rows = await (database.select(
      database.dailyCompletions,
    )..where((row) => row.localDate.equals(localDate))).get();
    return rows.map((row) => row.activityId).toSet();
  }

  @override
  Future<void> setCompleted({
    required int activityId,
    required String localDate,
    required bool completed,
  }) async {
    final query = database.dailyCompletions;
    if (completed) {
      await query.insertOnConflictUpdate(
        db.DailyCompletionsCompanion.insert(
          activityId: activityId,
          localDate: localDate,
          completedAt: Value(DateTime.now()),
        ),
      );
    } else {
      await (database.delete(query)..where(
            (row) =>
                row.activityId.equals(activityId) &
                row.localDate.equals(localDate),
          ))
          .go();
    }
  }

  DailyActivity _toDomain(db.DailyActivity row) {
    final mode = DailyScheduleMode.values.firstWhere(
      (value) => value.name == row.scheduleMode,
      orElse: () => DailyScheduleMode.anytime,
    );
    final schedule = mode == DailyScheduleMode.specificTime
        ? DailySchedule.specific(
            hour: row.scheduledHour ?? 0,
            minute: row.scheduledMinute ?? 0,
          )
        : const DailySchedule.anytime();
    return DailyActivity(
      id: row.id,
      name: row.name,
      iconKey: row.iconKey,
      schedule: schedule,
      notificationsEnabled:
          row.notificationsEnabled && schedule.hasSpecificTime,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}
