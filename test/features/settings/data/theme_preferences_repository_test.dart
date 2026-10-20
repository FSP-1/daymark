import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/theme/app_styles.dart';
import 'package:daymark/core/theme/theme_presets.dart';
import 'package:daymark/features/settings/data/theme_preferences_repository.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  late AppDatabase database;
  late ThemePreferencesRepository repository;

  setUp(() {
    database = AppDatabase.test();
    repository = ThemePreferencesRepository(database);
  });

  tearDown(() => database.close());

  test('uses safe defaults when preferences are missing', () async {
    final preferences = await repository.load();

    expect(preferences.style, AppStyle.soft);
    expect(preferences.palette, AppPalette.vanilla);
  });

  test('persists and restores style and palette independently', () async {
    await repository.saveStyle(AppStyle.playful);
    await repository.savePalette(AppPalette.rose);

    final preferences = await repository.load();

    expect(preferences.style, AppStyle.playful);
    expect(preferences.palette, AppPalette.rose);
  });
}
