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

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

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
    },
  );

  factory AppDatabase.test() => AppDatabase(NativeDatabase.memory());

  factory AppDatabase.testAt(File file) => AppDatabase(NativeDatabase(file));

  factory AppDatabase.production() {
    return AppDatabase(driftDatabase(name: 'daymark'));
  }
}
