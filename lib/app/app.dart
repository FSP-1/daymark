import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../features/sticky_notes/data/local/app_database.dart';
import '../features/sticky_notes/data/sticky_notes_repository.dart';
import '../features/sticky_notes/presentation/sticky_notes_page.dart';
import '../features/sticky_notes/presentation/sticky_notes_view_model.dart';

class DaymarkApp extends StatefulWidget {
  const DaymarkApp({required this.database, super.key});

  final AppDatabase database;

  @override
  State<DaymarkApp> createState() => _DaymarkAppState();
}

class _DaymarkAppState extends State<DaymarkApp> {
  late final DriftStickyNotesRepository _repository;

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
      title: 'Daymark',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: ChangeNotifierProvider(
        create: (_) => StickyNotesViewModel(_repository)..load(),
        child: const StickyNotesPage(),
      ),
    );
  }
}
