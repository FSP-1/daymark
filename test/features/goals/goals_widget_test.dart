import 'package:daymark/app/app.dart';
import 'package:daymark/features/daily/data/daily_repository.dart';
import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';
import 'package:daymark/features/sticky_notes/data/local/app_database.dart'
    show AppDatabase;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets(
    'sets up checklist activities and a required counter activity from Goals',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(480, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final database = AppDatabase.test();
      final daily = DriftDailyRepository(database);
      await tester.runAsync(() async {
        final today = DateTime.now();
        for (final name in ['Planificar', 'Construir', 'Leer']) {
          await daily.saveActivity(
            DailyActivity(
              id: null,
              name: name,
              schedule: const DailySchedule.anytime(),
              notificationsEnabled: false,
              createdAt: today,
              updatedAt: today,
            ),
          );
        }
      });
      await tester.pumpWidget(DaymarkApp(database: database));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      final shortcut = find.byKey(const Key('goals-fast-travel'));
      await tester.scrollUntilVisible(
        shortcut,
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(shortcut);
      await tester.pumpAndSettle();

      Future<void> tapVisible(Finder finder) async {
        await tester.pumpAndSettle();
        await tester.ensureVisible(finder);
        await tester.pumpAndSettle();
        await tester.tap(finder);
        await tester.pumpAndSettle();
      }

      Future<void> selectDaily(String name) async {
        await tapVisible(find.byKey(const Key('goal-choose-daily')));
        await tester.tap(find.widgetWithText(SimpleDialogOption, name));
        await tester.pumpAndSettle();
      }

      final create = find.byKey(const Key('goal-create'));
      await tester.tap(find.byKey(const Key('information-action')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Por pasos funciona como una lista'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Cuantitativo cuenta cuántos días'),
        findsOneWidget,
      );
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      final title = find.byKey(const Key('goal-title'));
      final save = find.byKey(const Key('goal-save'));
      await tapVisible(create);
      await tester.enterText(title, 'Proyecto');
      FocusManager.instance.primaryFocus?.unfocus();
      expect(find.text('Fecha de inicio'), findsNothing);
      expect(find.byKey(const Key('goal-create-daily')), findsNothing);
      await selectDaily('Planificar');
      await selectDaily('Construir');
      final draftStep = find.byKey(const Key('goal-draft-step'));
      await tester.ensureVisible(draftStep);
      await tester.enterText(draftStep, 'Publicar');
      await tester.tap(save);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Proyecto'));
      await tester.pumpAndSettle();
      expect(find.text('0 de 3 pasos completados'), findsOneWidget);
      expect(find.text('Planificar'), findsOneWidget);
      expect(find.text('Construir'), findsOneWidget);
      expect(find.text('Publicar'), findsOneWidget);
      expect(
        tester
            .widgetList<Checkbox>(find.byType(Checkbox))
            .where((item) => item.onChanged != null),
        hasLength(1),
      );
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      await tapVisible(create);
      await tester.enterText(title, 'Lectura');
      FocusManager.instance.primaryFocus?.unfocus();
      expect(find.text('Manual'), findsNothing);
      await tapVisible(find.widgetWithText(ChoiceChip, 'Cuantitativo'));
      await tester.pumpAndSettle();
      expect(find.text('Unidad'), findsNothing);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Elige una actividad existente de Daily antes de guardar el objetivo.',
        ),
        findsOneWidget,
      );
      await selectDaily('Leer');
      await tester.tap(save);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Lectura'));
      await tester.pumpAndSettle();
      expect(find.text('0 de 1'), findsOneWidget);
      expect(find.text('Avanzar'), findsNothing);
      expect(
        (await daily.listActivities()).map((item) => item.name),
        unorderedEquals(['Planificar', 'Construir', 'Leer']),
      );

      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    },
  );
}
