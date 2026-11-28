import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'dart:io';

part 'app_database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().nullable()();

  TextColumn get subtitle => text().nullable()();

  TextColumn get content => text()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  TextColumn get drawingData => text().nullable()();

  TextColumn get associatedDate => text().nullable()();

  TextColumn get listData => text().nullable()();
}

class AppPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get style => text().withDefault(const Constant('soft'))();

  TextColumn get palette => text().withDefault(const Constant('vanilla'))();

  TextColumn get navigation => text().nullable()();
}

class DailyActivities extends Table {
  IntColumn get goalId => integer().nullable()();
  IntColumn get id => integer().autoIncrement()();

  TextColumn get name => text()();

  TextColumn get iconKey => text().withDefault(const Constant('repeat'))();

  TextColumn get scheduleMode => text()();

  IntColumn get scheduledHour => integer().nullable()();

  IntColumn get scheduledMinute => integer().nullable()();

  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

class DailyCompletions extends Table {
  IntColumn get activityId => integer()();

  TextColumn get localDate => text()();

  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {activityId, localDate};
}

class JournalEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().nullable()();

  TextColumn get content => text()();

  DateTimeColumn get entryDate => dateTime()();

  TextColumn get drawingData => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('GoalRow')
class Goals extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get category => text()();
  TextColumn get iconId => text()();
  TextColumn get color => text()();
  TextColumn get trackingType => text()();
  TextColumn get startDate => text()();
  TextColumn get targetDate => text().nullable()();
  RealColumn get targetValue => real()();
  RealColumn get currentValue => real()();
  TextColumn get unit => text()();
  IntColumn get manualProgress => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

@DataClassName('GoalMilestoneRow')
class GoalMilestones extends Table {
  IntColumn get activityId => integer().nullable()();
  IntColumn get id => integer().autoIncrement()();
  IntColumn get goalId => integer().references(Goals, #id)();
  TextColumn get title => text()();
  IntColumn get sortOrder => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

class DailyGoalCredits extends Table {
  IntColumn get activityId => integer()();
  TextColumn get localDate => text()();
  IntColumn get goalId => integer()();
  IntColumn get milestoneId => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {activityId, localDate};
}

class FocusStateRows extends Table {
  IntColumn get id => integer()();
  TextColumn get payload => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FocusSessionRows extends Table {
  TextColumn get id => text()();
  TextColumn get payload => text()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Notes,
    AppPreferences,
    DailyActivities,
    DailyCompletions,
    JournalEntries,
    Goals,
    GoalMilestones,
    DailyGoalCredits,
    FocusStateRows,
    FocusSessionRows,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 13) {
        await migrator.addColumn(notes, notes.listData);
      }
      if (from < 12) {
        await migrator.createTable(focusStateRows);
        await migrator.createTable(focusSessionRows);
      }
      if (from < 2) {
        await migrator.addColumn(notes, notes.title);
        await migrator.addColumn(notes, notes.subtitle);
        await migrator.addColumn(notes, notes.createdAt);
      }
      if (from < 3) {
        await migrator.addColumn(notes, notes.drawingData);
      }
      if (from < 4) {
        await migrator.createTable(appPreferences);
      }
      if (from < 5) {
        await migrator.createTable(dailyActivities);
        await migrator.createTable(dailyCompletions);
      } else if (from < 6) {
        await migrator.addColumn(dailyActivities, dailyActivities.iconKey);
      }
      if (from < 7) {
        await migrator.createTable(journalEntries);
      }
      if (from < 8) {
        await migrator.addColumn(notes, notes.associatedDate);
      }
      if (from < 9) {
        if (from >= 4) {
          await migrator.addColumn(appPreferences, appPreferences.navigation);
        }
        await migrator.createTable(goals);
        await migrator.createTable(goalMilestones);
      }
      if (from < 10) {
        if (from >= 5) {
          await migrator.addColumn(dailyActivities, dailyActivities.goalId);
        }
        await migrator.createTable(dailyGoalCredits);
      }
      if (from >= 9 && from < 11) {
        await migrator.addColumn(goalMilestones, goalMilestones.activityId);
      }
      if (from >= 10 && from < 11) {
        await customStatement('''
          INSERT INTO goal_milestones (goal_id, title, sort_order, created_at, activity_id)
          SELECT a.goal_id, a.name,
            COALESCE((SELECT MAX(m.sort_order) FROM goal_milestones m WHERE m.goal_id = a.goal_id AND m.activity_id IS NULL), -1) + a.id,
            a.created_at, a.id
          FROM daily_activities a JOIN goals g ON g.id = a.goal_id
          WHERE g.tracking_type = 'checklist'
        ''');
      }
    },
  );

  factory AppDatabase.test() => AppDatabase(NativeDatabase.memory());

  factory AppDatabase.testAt(File file) => AppDatabase(NativeDatabase(file));

  factory AppDatabase.production() {
    return AppDatabase(driftDatabase(name: 'daymark'));
  }
}
