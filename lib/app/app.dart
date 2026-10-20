import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../features/sticky_notes/data/local/app_database.dart';
import '../features/sticky_notes/data/sticky_notes_repository.dart';
import '../features/sticky_notes/presentation/sticky_notes_page.dart';
import '../features/sticky_notes/presentation/sticky_notes_view_model.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/settings/data/theme_preferences_repository.dart';
import '../features/settings/presentation/theme_view_model.dart';
import '../core/localization/app_localizations.dart';
import '../core/theme/app_theme.dart';

class DaymarkApp extends StatefulWidget {
  const DaymarkApp({required this.database, super.key});

  final AppDatabase database;

  @override
  State<DaymarkApp> createState() => _DaymarkAppState();
}

class _DaymarkAppState extends State<DaymarkApp> {
  late final DriftStickyNotesRepository _repository;
  late final ThemeViewModel _themeViewModel;
  var _locale = const Locale('es');

  @override
  void initState() {
    super.initState();
    _repository = DriftStickyNotesRepository(widget.database);
    _themeViewModel = ThemeViewModel(
      ThemePreferencesRepository(widget.database),
    )..load();
    _themeViewModel.addListener(_onThemeChanged);
  }

  void _onThemeChanged() => setState(() {});

  @override
  void dispose() {
    widget.database.close();
    _themeViewModel.removeListener(_onThemeChanged);
    _themeViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_themeViewModel.isLoading) {
      return const MaterialApp(
        title: 'daymark.',
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp(
      title: 'daymark.',
      locale: _locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildAppTheme(
        style: _themeViewModel.style,
        palette: _themeViewModel.palette,
      ),
      home: ChangeNotifierProvider(
        create: (_) => StickyNotesViewModel(_repository)..load(),
        child: ChangeNotifierProvider.value(
          value: _themeViewModel,
          child: HomeShell(
            stickyNotesPage: const StickyNotesPage(),
            locale: _locale,
            onLocaleChanged: (locale) => setState(() => _locale = locale),
          ),
        ),
      ),
    );
  }
}
