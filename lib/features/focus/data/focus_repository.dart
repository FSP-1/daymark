import 'dart:convert';

import 'package:drift/drift.dart';

import '../../sticky_notes/data/local/app_database.dart';
import '../domain/focus_session.dart';

class FocusPreferences {
  const FocusPreferences({
    this.settings = const FocusSettings(),
    this.mode = FocusMode.focus,
    this.cycleCount = 0,
    this.active,
    this.activities = const [],
    this.dailyActivityIds = const {},
  });

  final FocusSettings settings;
  final FocusMode mode;
  final int cycleCount;
  final FocusSession? active;
  final List<FocusActivity> activities;
  final Set<int> dailyActivityIds;

  FocusPreferences copyWith({
    FocusSettings? settings,
    FocusMode? mode,
    int? cycleCount,
    FocusSession? active,
    bool clearActive = false,
    List<FocusActivity>? activities,
    Set<int>? dailyActivityIds,
  }) => FocusPreferences(
    settings: settings ?? this.settings,
    mode: mode ?? this.mode,
    cycleCount: cycleCount ?? this.cycleCount,
    active: clearActive ? null : active ?? this.active,
    activities: activities ?? this.activities,
    dailyActivityIds: dailyActivityIds ?? this.dailyActivityIds,
  );

  factory FocusPreferences.fromJson(Map<String, dynamic> json) =>
      FocusPreferences(
        settings: FocusSettings.fromJson(
          json['settings'] as Map<String, dynamic>,
        ),
        mode: FocusMode.values.byName(json['mode'] as String),
        cycleCount: json['cycleCount'] as int,
        active: json['active'] == null
            ? null
            : FocusSession.fromJson(json['active'] as Map<String, dynamic>),
        activities: [
          for (final item in json['activities'] as List)
            FocusActivity.fromJson(item as Map<String, dynamic>),
        ],
        dailyActivityIds: (json['dailyActivityIds'] as List? ?? const [])
            .whereType<int>()
            .toSet(),
      );
  Map<String, dynamic> toJson() => {
    'settings': settings.toJson(),
    'mode': mode.name,
    'cycleCount': cycleCount,
    'active': active?.toJson(),
    'activities': activities.map((item) => item.toJson()).toList(),
    'dailyActivityIds': dailyActivityIds.toList(),
  };
}

class FocusRepository {
  const FocusRepository(this.database);
  final AppDatabase database;

  Future<FocusPreferences> load() async {
    final row = await database
        .select(database.focusStateRows)
        .getSingleOrNull();
    if (row == null) return const FocusPreferences();
    return FocusPreferences.fromJson(
      jsonDecode(row.payload) as Map<String, dynamic>,
    );
  }

  Future<void> save(FocusPreferences state, {FocusSession? record}) =>
      database.transaction(() async {
        if (record != null) {
          await database
              .into(database.focusSessionRows)
              .insert(
                FocusSessionRowsCompanion.insert(
                  id: record.id,
                  payload: jsonEncode(record.toJson()),
                ),
                mode: InsertMode.insertOrIgnore,
              );
        }
        await database
            .into(database.focusStateRows)
            .insertOnConflictUpdate(
              FocusStateRowsCompanion.insert(
                id: const Value(1),
                payload: jsonEncode(state.toJson()),
              ),
            );
      });

  Stream<List<FocusSession>> watchHistory() => database
      .select(database.focusSessionRows)
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            FocusSession.fromJson(
              jsonDecode(row.payload) as Map<String, dynamic>,
            ),
        ]..sort((a, b) => b.started.compareTo(a.started)),
      );

  Future<void> delete(String id) async {
    await (database.delete(
      database.focusSessionRows,
    )..where((row) => row.id.equals(id))).go();
  }
}
