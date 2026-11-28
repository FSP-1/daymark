import 'package:daymark/features/daily/domain/daily_activity.dart';
import 'package:daymark/features/daily/domain/daily_schedule.dart';
import 'package:daymark/features/daily/presentation/widgets/daily_activity_card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wraps reminder metadata on narrow screens', (tester) async {
    var deleteTapped = false;
    final activity = DailyActivity(
      id: 1,
      name: 'A very long activity name that stays readable',
      schedule: const DailySchedule.specific(hour: 8, minute: 30),
      notificationsEnabled: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(320, 640)),
        child: MaterialApp(
          home: Scaffold(
            body: DailyActivityCard(
              activity: activity,
              completed: false,
              onTap: () {},
              onCompleted: () {},
              onEdit: () {},
              onDelete: () => deleteTapped = true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(
      find.text('A very long activity name that stays readable'),
      findsOneWidget,
    );
    expect(find.byType(DailyReminderIndicator), findsOneWidget);
    await tester.tap(find.byIcon(Icons.delete_outline));
    expect(deleteTapped, isTrue);
  });
}
