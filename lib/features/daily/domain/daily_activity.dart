import 'daily_schedule.dart';

class DailyActivity {
  const DailyActivity({
    required this.id,
    required this.name,
    required this.schedule,
    required this.notificationsEnabled,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String name;
  final DailySchedule schedule;
  final bool notificationsEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isValid =>
      name.trim().isNotEmpty &&
      schedule.isValid &&
      (schedule.hasSpecificTime || !notificationsEnabled);

  DailyActivity copyWith({
    int? id,
    String? name,
    DailySchedule? schedule,
    bool? notificationsEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailyActivity(
      id: id ?? this.id,
      name: name ?? this.name,
      schedule: schedule ?? this.schedule,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
