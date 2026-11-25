import 'dart:convert';

import 'package:drift/drift.dart';

import '../../features/sticky_notes/data/local/app_database.dart';
import 'feature_id.dart';

class NavigationPreferences {
  const NavigationPreferences(this.database);
  final AppDatabase database;

  Future<List<FeatureId>?> load() async {
    final row = await (database.select(
      database.appPreferences,
    )..where((row) => row.id.equals(1))).getSingleOrNull();
    final raw = row?.navigation;
    if (raw == null) return null;
    try {
      final values = jsonDecode(raw);
      if (values is! List) return null;
      return [
        for (final id in values)
          if (FeatureId.values.any((feature) => feature.name == id))
            FeatureId.values.byName(id as String),
      ];
    } on FormatException {
      return null;
    }
  }

  Future<void> save(List<FeatureId> value) => database.transaction(() async {
    await database
        .into(database.appPreferences)
        .insert(
          const AppPreferencesCompanion(id: Value(1)),
          mode: InsertMode.insertOrIgnore,
        );
    await (database.update(
      database.appPreferences,
    )..where((row) => row.id.equals(1))).write(
      AppPreferencesCompanion(
        navigation: Value(
          jsonEncode(
            value
                .where((id) => id != FeatureId.home)
                .map((id) => id.name)
                .toList(),
          ),
        ),
      ),
    );
  });
}
