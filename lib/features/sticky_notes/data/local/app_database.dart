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
}

class AppPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get style => text().withDefault(const Constant('soft'))();

  TextColumn get palette => text().withDefault(const Constant('vanilla'))();
}

class DailyActivities extends Table {
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

@DriftDatabase(
  tables: [
    Notes,
    AppPreferences,
    DailyActivities,
    DailyCompletions,
    JournalEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
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
      }
      if (from < 6) {
        await migrator.addColumn(dailyActivities, dailyActivities.iconKey);
      }
      if (from < 7) {
        await migrator.createTable(journalEntries);
      }
    },
  );

  factory AppDatabase.test() => AppDatabase(NativeDatabase.memory());

  factory AppDatabase.testAt(File file) => AppDatabase(NativeDatabase(file));

  factory AppDatabase.production() {
    return AppDatabase(driftDatabase(name: 'daymark'));
  }
}
