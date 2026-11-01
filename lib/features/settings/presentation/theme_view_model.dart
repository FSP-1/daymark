import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_styles.dart';
import '../../../core/theme/theme_presets.dart';
import '../data/theme_preferences_repository.dart';

class ThemeViewModel extends ChangeNotifier {
  ThemeViewModel(this.repository);

  final ThemePreferencesRepository repository;
  AppStyle style = AppStyle.soft;
  AppPalette palette = AppPalette.vanilla;
  bool isLoading = true;
  Object? error;

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final preferences = await repository.load();
      style = preferences.style;
      palette = preferences.palette;
    } catch (exception, stackTrace) {
      error = exception;
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: exception,
          stack: stackTrace,
          library: 'daymark',
          context: ErrorDescription('restoring appearance preferences'),
        ),
      );
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> setStyle(AppStyle value) async {
    style = value;
    notifyListeners();
    await repository.saveStyle(value);
  }

  Future<void> setPalette(AppPalette value) async {
    palette = value;
    notifyListeners();
    await repository.savePalette(value);
  }

  Future<void> reset() async {
    style = AppStyle.soft;
    palette = AppPalette.vanilla;
    notifyListeners();
    await repository.saveStyle(style);
    await repository.savePalette(palette);
  }
}
