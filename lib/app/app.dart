import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../features/sticky_notes/data/local/app_database.dart';
import '../features/sticky_notes/data/sticky_notes_repository.dart';
import '../features/sticky_notes/presentation/sticky_notes_view_model.dart';
import '../features/home/presentation/home_shell.dart';
import '../features/settings/data/theme_preferences_repository.dart';
import '../features/settings/presentation/theme_view_model.dart';
import '../core/localization/app_localizations.dart';
import '../core/navigation/navigation_preferences.dart';
import '../core/navigation/navigation_view_model.dart';
import '../core/loading/app_loading_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/notifications/platform_notification_service.dart';
import '../features/daily/data/daily_notification_coordinator.dart';
import '../features/daily/data/daily_repository.dart';
import '../features/daily/presentation/daily_view_model.dart';
import '../features/journal/data/journal_repository.dart';
import '../features/journal/presentation/journal_view_model.dart';
import '../features/goals/data/goal_repository.dart';
import '../features/goals/presentation/goals_view_model.dart';

class DaymarkApp extends StatefulWidget {
  const DaymarkApp({required this.database, super.key});

  final AppDatabase database;

  @override
  State<DaymarkApp> createState() => _DaymarkAppState();
}

class _DaymarkAppState extends State<DaymarkApp> {
  late final DriftStickyNotesRepository _repository;
  late final ThemeViewModel _themeViewModel;
  late final NavigationViewModel _navigation;
  var _locale = const Locale('es');

  @override
  void initState() {
    super.initState();
    _repository = DriftStickyNotesRepository(widget.database);
    _themeViewModel = ThemeViewModel(
      ThemePreferencesRepository(widget.database),
    )..load();
    _themeViewModel.addListener(_onThemeChanged);
    _navigation = NavigationViewModel(NavigationPreferences(widget.database))
      ..load();
    _navigation.addListener(_onNavigationLoaded);
  }

  void _onThemeChanged() => setState(() {});

  void _onNavigationLoaded() {
    if (_navigation.loading) return;
    _navigation.removeListener(_onNavigationLoaded);
    setState(() {});
  }

  @override
  void dispose() {
    widget.database.close();
    _themeViewModel.removeListener(_onThemeChanged);
    _themeViewModel.dispose();
    _navigation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeViewModel),
        ChangeNotifierProvider.value(value: _navigation),
        ChangeNotifierProvider(
          create: (_) => StickyNotesViewModel(_repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => DailyViewModel(
            repository: DriftDailyRepository(widget.database),
            notifications: DailyNotificationCoordinator(
              PlatformNotificationService(),
            ),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              JournalViewModel(DriftJournalRepository(widget.database))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => GoalsViewModel(GoalRepository(widget.database)),
        ),
      ],
      child: MaterialApp(
        title: 'daymark.',
        locale: _locale,
        supportedLocales: const [Locale('es'), Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          ...GlobalMaterialLocalizations.delegates,
        ],
        theme: buildAppTheme(
          style: _themeViewModel.style,
          palette: _themeViewModel.palette,
        ),
        home: _themeViewModel.isLoading || _navigation.loading
            ? const Scaffold(body: AppLoadingScreen())
            : HomeShell(
                locale: _locale,
                onLocaleChanged: (locale) => setState(() => _locale = locale),
              ),
      ),
    );
  }
}
