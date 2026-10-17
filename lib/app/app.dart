import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import '../features/sticky_notes/data/local/app_database.dart';
import '../features/sticky_notes/data/sticky_notes_repository.dart';
import '../features/sticky_notes/presentation/sticky_notes_page.dart';
import '../features/sticky_notes/presentation/sticky_notes_view_model.dart';
import '../features/home/presentation/home_shell.dart';
import '../core/localization/app_localizations.dart';

class DaymarkApp extends StatefulWidget {
  const DaymarkApp({required this.database, super.key});

  final AppDatabase database;

  @override
  State<DaymarkApp> createState() => _DaymarkAppState();
}

class _DaymarkAppState extends State<DaymarkApp> {
  late final DriftStickyNotesRepository _repository;
  var _locale = const Locale('es');

  @override
  void initState() {
    super.initState();
    _repository = DriftStickyNotesRepository(widget.database);
  }

  @override
  void dispose() {
    widget.database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff7b6aa6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xfffffbf3),
        cardTheme: CardThemeData(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          elevation: 1,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xfffffdf8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0x18000000)),
          ),
        ),
      ),
      home: ChangeNotifierProvider(
        create: (_) => StickyNotesViewModel(_repository)..load(),
        child: HomeShell(
          stickyNotesPage: const StickyNotesPage(),
          locale: _locale,
          onLocaleChanged: (locale) => setState(() => _locale = locale),
        ),
      ),
    );
  }
}
