import 'package:daymark/app/app.dart';
import 'package:daymark/features/daily/presentation/daily_activity_icons.dart';
import 'package:daymark/features/focus/data/focus_repository.dart';
import 'package:daymark/features/focus/presentation/focus_page.dart';
import 'package:daymark/features/focus/presentation/focus_view_model.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('Home reopens the same running Focus session', (tester) async {
    final database = AppDatabase.test();
    await tester.runAsync(
      () => database
          .into(database.dailyActivities)
          .insert(
            DailyActivitiesCompanion.insert(
              name: 'Lectura',
              scheduleMode: 'anytime',
            ),
          ),
    );
    await tester.pumpWidget(DaymarkApp(database: database));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final card = find.byKey(const Key('focus-fast-travel'));
    await tester.scrollUntilVisible(
      card,
      340,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(card);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focus-page')), findsOneWidget);
    final manage = find.byKey(const Key('focus-manage-activities'));
    await tester.ensureVisible(manage);
    await tester.pumpAndSettle();
    await tester.tap(manage);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('focus-add-daily')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lectura'));
    await tester.pumpAndSettle();
    expect(find.text('Lectura'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Actividad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Actividad'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lectura · Daily'));
    await tester.pumpAndSettle();
    final activity = find.widgetWithText(ListTile, 'Lectura');
    expect(
      (tester.widget<ListTile>(activity).leading as Icon).icon,
      DailyActivityIcons.iconFor(DailyActivityIcons.defaultKey),
    );
    expect(find.widgetWithText(ListTile, 'Objetivos'), findsNothing);
    final toggle = find.byKey(const Key('focus-toggle'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    final model = tester.element(toggle).read<FocusViewModel>();
    final id = model.active!.id;
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    final banner = find.byKey(const Key('focus-active-banner'));
    await tester.ensureVisible(banner);
    await tester.pumpAndSettle();
    await tester.tap(banner);
    await tester.pumpAndSettle();
    expect(
      tester
          .element(find.byKey(const Key('focus-page')))
          .read<FocusViewModel>()
          .active!
          .id,
      id,
    );
    expect(find.text('Pausar'), findsOneWidget);
    await model.reset();
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await database.close();
  });

  testWidgets('shows the countdown, pause and history on a narrow display', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = AppDatabase.test();
    addTearDown(database.close);
    var now = DateTime(2026, 10, 10, 18);
    final model = FocusViewModel(
      FocusRepository(database),
      clock: () => now,
      observeLifecycle: false,
    );
    addTearDown(model.dispose);
    await tester.runAsync(model.restore);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: model,
        child: const MaterialApp(home: Scaffold(body: FocusPage())),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('25:00'), findsOneWidget);
    expect(find.byType(ChoiceChip), findsNWidgets(2));
    await tester.tap(find.widgetWithText(ChoiceChip, 'Break'));
    await tester.pumpAndSettle();
    expect(find.text('05:00'), findsOneWidget);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Concentration'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('How Focus works'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Focus alternates concentration sessions'),
      findsOneWidget,
    );
    await tester.tap(find.text('How Focus works'));
    await tester.pumpAndSettle();
    final manage = find.byKey(const Key('focus-manage-activities'));
    await tester.ensureVisible(manage);
    await tester.pumpAndSettle();
    await tester.tap(manage);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focus-activities-page')), findsOneWidget);
    expect(find.byKey(const Key('focus-add-daily')), findsOneWidget);
    await tester.tap(find.text('New activity'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Reading');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reading'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Study');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Study'), findsOneWidget);
    await tester.tap(find.byTooltip('Archive'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Archive'));
    await tester.pumpAndSettle();
    expect(find.text('Study'), findsNothing);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    final toggle = find.byKey(const Key('focus-toggle'));
    await tester.ensureVisible(toggle);
    await tester.pumpAndSettle();
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    now = now.add(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('24:55'), findsOneWidget);
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    expect(find.text('Resume'), findsOneWidget);
    await tester.ensureVisible(find.byTooltip('History'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('History'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('focus-history')), findsOneWidget);
    expect(model.active?.running, isFalse);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  });
}
