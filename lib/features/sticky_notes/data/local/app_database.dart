import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'dart:io';

part 'app_database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get content => text()();
}

@DriftDatabase(tables: [Notes])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) => migrator.createAll(),
      );

  factory AppDatabase.test() => AppDatabase(NativeDatabase.memory());

  factory AppDatabase.testAt(File file) => AppDatabase(NativeDatabase(file));

  factory AppDatabase.production() {
    return AppDatabase(
      driftDatabase(name: 'daymark'),
    );
  }
}
