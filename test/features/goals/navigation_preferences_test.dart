import 'package:daymark/core/navigation/feature_id.dart';
import 'package:daymark/core/navigation/navigation_preferences.dart';
import 'package:daymark/core/navigation/navigation_view_model.dart';
import 'package:daymark/core/theme/app_styles.dart';
import 'package:daymark/features/settings/data/theme_preferences_repository.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'persists valid ordered destinations alongside theme preferences',
    () async {
      final database = AppDatabase.test();
      addTearDown(database.close);
      final store = NavigationPreferences(database);
      final themes = ThemePreferencesRepository(database);
      final model = NavigationViewModel(store);
      addTearDown(model.dispose);
      await model.load();
      expect(model.pinned, NavigationViewModel.defaults);
      await model.setPinned(FeatureId.goals, true);
      expect(model.pinned, isNot(contains(FeatureId.goals)));
      model.select(FeatureId.journal);
      await model.setPinned(FeatureId.journal, false);
      expect(model.selected, FeatureId.home);
      await model.setPinned(FeatureId.goals, true);
      await model.move(FeatureId.goals, -1);
      await themes.saveStyle(AppStyle.playful);

      final restored = NavigationViewModel(store);
      addTearDown(restored.dispose);
      await restored.load();
      expect(restored.pinned, [
        FeatureId.notes,
        FeatureId.calendar,
        FeatureId.goals,
        FeatureId.daily,
      ]);
      expect((await themes.load()).style, AppStyle.playful);
      for (final id in restored.pinned) {
        await restored.setPinned(id, false);
      }
      expect(restored.destinations, [FeatureId.home]);
      expect(await store.load(), isEmpty);
      await restored.restoreDefaults();
      expect(await store.load(), NavigationViewModel.defaults);
    },
  );

  test('ignores unknown, repeated, and permanent identifiers', () async {
    final database = AppDatabase.test();
    addTearDown(database.close);
    await database.customStatement(
      'INSERT INTO app_preferences (id, navigation) VALUES (1, ?)',
      ['["unknown","home","daily","daily","goals"]'],
    );
    final model = NavigationViewModel(NavigationPreferences(database));
    addTearDown(model.dispose);
    await model.load();
    expect(model.pinned, [FeatureId.daily, FeatureId.goals]);
  });
}
