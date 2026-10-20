import 'package:flutter_test/flutter_test.dart';

import 'package:daymark/core/theme/app_styles.dart';
import 'package:daymark/core/theme/theme_presets.dart';
import 'package:daymark/features/settings/data/theme_preferences_repository.dart';
import 'package:daymark/features/settings/presentation/theme_view_model.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';

void main() {
  test('loads defaults, changes preferences, and resets them', () async {
    final database = AppDatabase.test();
    final viewModel = ThemeViewModel(ThemePreferencesRepository(database));

    await viewModel.load();
    expect(viewModel.isLoading, isFalse);
    expect(viewModel.style, AppStyle.soft);
    expect(viewModel.palette, AppPalette.vanilla);

    await viewModel.setStyle(AppStyle.minimal);
    await viewModel.setPalette(AppPalette.sky);
    expect(viewModel.style, AppStyle.minimal);
    expect(viewModel.palette, AppPalette.sky);

    await viewModel.reset();
    expect(viewModel.style, AppStyle.soft);
    expect(viewModel.palette, AppPalette.vanilla);
    await database.close();
  });
}
