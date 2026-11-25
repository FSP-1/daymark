import 'package:drift/drift.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/theme_presets.dart';
import '../../sticky_notes/data/local/app_database.dart';

class ThemePreferences {
  const ThemePreferences({required this.style, required this.palette});

  final AppStyle style;
  final AppPalette palette;
}

class ThemePreferencesRepository {
  ThemePreferencesRepository(this.database);

  final AppDatabase database;

  Future<ThemePreferences> load() async {
    final row = await database
        .select(database.appPreferences)
        .getSingleOrNull();
    final style = _parseStyle(row?.style);
    final palette = _parsePalette(row?.palette);
    return ThemePreferences(style: style, palette: palette);
  }

  Future<void> saveStyle(AppStyle style) => _save(style.name, null);

  Future<void> savePalette(AppPalette palette) => _save(null, palette.name);

  Future<void> _save(String? style, String? palette) =>
      database.transaction(() async {
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
            style: style == null ? const Value.absent() : Value(style),
            palette: palette == null ? const Value.absent() : Value(palette),
          ),
        );
      });

  AppStyle _parseStyle(String? value) => AppStyle.values.firstWhere(
    (candidate) => candidate.name == value,
    orElse: () => AppStyle.soft,
  );

  AppPalette _parsePalette(String? value) => AppPalette.values.firstWhere(
    (candidate) => candidate.name == value,
    orElse: () => AppPalette.vanilla,
  );
}
