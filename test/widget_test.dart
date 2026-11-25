import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:daymark/app/app.dart';
import 'package:daymark/features/calendar/presentation/calendar_page.dart';
import 'package:daymark/features/journal/data/journal_repository.dart';
import 'package:daymark/features/journal/presentation/journal_view_model.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:daymark/features/sticky_notes/data/sticky_notes_repository.dart';
import 'package:daymark/features/sticky_notes/presentation/sticky_notes_view_model.dart';

void main() {
  testWidgets('opens main navigation destinations', (tester) async {
    final database = AppDatabase.test();
    await tester.runAsync(() => database.customSelect('SELECT 1').get());
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(find.text('daymark.'), findsAtLeastNWidgets(1));
    final settings = find.byKey(const Key('settings-action'));
    final information = find.byKey(const Key('information-action'));
    final settingsPosition = tester.getCenter(settings);
    final informationPosition = tester.getCenter(information);
    expect(informationPosition.dx, greaterThan(settingsPosition.dx));
    expect(informationPosition.dy, settingsPosition.dy);
    for (final destination in ['daily', 'journal', 'calendar', 'notes']) {
      await tester.tap(find.byKey(Key('$destination-nav')));
      await tester.pumpAndSettle();
      expect(tester.getCenter(settings), settingsPosition);
      expect(tester.getCenter(information), informationPosition);
    }
    await tester.tap(find.byKey(const Key('notes-nav')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add-note-action')), findsOneWidget);
    await tester.tap(find.byKey(const Key('add-note-action')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('note-content')), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pumpAndSettle();
    expect(
      tester
          .widgetList<NavigationDestination>(find.byType(NavigationDestination))
          .map((destination) => destination.label),
      ['Inicio', 'Notas', 'Calendario', 'Daily', 'Diario'],
    );
    await tester.tap(find.byKey(const Key('calendar-nav')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);
    await tester.tap(information);
    await tester.pumpAndSettle();
    expect(find.text('Información'), findsOneWidget);
    expect(find.text('Vuelve a hoy en la vista mensual.'), findsOneWidget);
    expect(find.text('Herramientas de dibujo'), findsOneWidget);
    expect(find.text('Deshace el último trazo.'), findsNothing);
    expect(find.text('Busca notas por texto.'), findsNothing);
    expect(find.text('Navegación de la app'), findsOneWidget);
    expect(
      find.text('Inicio abre los accesos a las funciones de Daymark.'),
      findsNothing,
    );
    await tester.ensureVisible(find.text('Herramientas de dibujo'));
    await tester.tap(find.text('Herramientas de dibujo'));
    await tester.pumpAndSettle();
    expect(find.text('Deshace el último trazo.'), findsOneWidget);
    expect(find.byIcon(Icons.undo), findsOneWidget);
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('journal-nav')));
    await tester.pumpAndSettle();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byKey(const Key('calendar-page')), findsNothing);
    expect(find.text('Diario'), findsAtLeastNWidgets(2));
    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('calendar-fast-travel')));
    await tester.tap(find.byKey(const Key('calendar-fast-travel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsOneWidget);
    await tester.tap(find.byType(NavigationDestination).first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('journal-fast-travel')));
    await tester.tap(find.byKey(const Key('journal-fast-travel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('calendar-page')), findsNothing);
    expect(find.text('Diario'), findsAtLeastNWidgets(2));
    await tester.tap(settings);
    await tester.pumpAndSettle();

    expect(find.text('Estilo visual'), findsAtLeastNWidgets(1));
    expect(find.text('Paleta de color'), findsOneWidget);
    expect(find.text('Suave'), findsAtLeastNWidgets(1));
    await tester.tap(find.byKey(const Key('style-selector')));
    await tester.pumpAndSettle();
    expect(find.text('Suave'), findsAtLeastNWidgets(1));
    expect(find.text('Juguetón'), findsOneWidget);
    expect(find.text('Minimalista'), findsOneWidget);
    await tester.tap(find.text('Juguetón'));
    await tester.pumpAndSettle();
    expect(
      find.text('Titulares expresivos, formas creativas y un toque alegre.'),
      findsOneWidget,
    );
    await tester.drag(
      find.byKey(const Key('settings-scroll')),
      const Offset(0, -500),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('palette-sage')), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets('Calendar opens existing editors with the selected date', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 740));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = AppDatabase.test();
    final noteRepository = DriftStickyNotesRepository(database);
    final journalRepository = DriftJournalRepository(database);
    final notes = StickyNotesViewModel(noteRepository);
    final journal = JournalViewModel(journalRepository);
    addTearDown(database.close);
    addTearDown(notes.dispose);
    addTearDown(journal.dispose);
    await tester.runAsync(() async {
      await notes.load();
      await journal.load();
    });
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: notes),
          ChangeNotifierProvider.value(value: journal),
        ],
        child: const MaterialApp(home: CalendarPage()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('calendar-month-1')));
    await tester.pumpAndSettle();
    final calendar = find.byKey(const Key('calendar-page'));
    final localizations = MaterialLocalizations.of(tester.element(calendar));
    final now = DateTime.now();
    final january = DateTime(now.year);
    expect(find.text(localizations.formatMonthYear(january)), findsOneWidget);

    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next period'));
    await tester.pumpAndSettle();
    final nextMonth = DateTime(now.year, now.month + 1);
    final future = DateTime(nextMonth.year, nextMonth.month, 1);
    await tester.tap(find.byKey(ValueKey(future)));
    await tester.pumpAndSettle();
    final write = find.byKey(const Key('calendar-write-journal'));
    await tester.ensureVisible(write);
    expect(tester.widget<OutlinedButton>(write).onPressed, isNull);
    final add = find.byKey(const Key('calendar-add-note'));
    await tester.ensureVisible(add);
    await tester.tap(add);
    await tester.pumpAndSettle();
    expect(find.text(localizations.formatFullDate(future)), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('note-title')),
      'Plan de viaje',
    );
    await tester.enterText(
      find.byKey(const Key('note-content')),
      'Preparar equipaje',
    );
    final saveNote = find.byKey(const Key('add-note'));
    await tester.ensureVisible(saveNote);
    await tester.tap(saveNote);
    await tester.pumpAndSettle();
    expect(
      (await DriftStickyNotesRepository(
        database,
      ).listNotes()).single.associatedDate,
      future,
    );
    final note = find.text('Plan de viaje');
    await tester.ensureVisible(note);
    await tester.tap(note);
    await tester.pumpAndSettle();
    expect(find.text('Preparar equipaje'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text(localizations.formatFullDate(future)), findsOneWidget);

    final calendarScroll = find
        .descendant(of: calendar, matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
      find.byTooltip('Today'),
      -250,
      scrollable: calendarScroll,
    );
    await tester.tap(find.byTooltip('Today'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Previous period'));
    await tester.pumpAndSettle();
    final past = DateTime(now.year, now.month - 1);
    await tester.tap(find.byKey(ValueKey(past)));
    await tester.pumpAndSettle();
    await tester.ensureVisible(write);
    await tester.tap(write);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('journal-content')),
      'Un recuerdo',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      (await DriftJournalRepository(database).listEntries()).single.entryDate,
      past,
    );

    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
