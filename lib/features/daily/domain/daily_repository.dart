import 'daily_activity.dart';

abstract interface class DailyRepository {
  Future<List<DailyActivity>> listActivities();

  Future<DailyActivity> saveActivity(DailyActivity activity);

  Future<void> deleteActivity(int id);

  Future<Set<int>> completedActivityIds(String localDate);

  Future<void> setCompleted({
    required int activityId,
    required String localDate,
    required bool completed,
  });
}
