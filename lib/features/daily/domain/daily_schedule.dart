enum DailyScheduleMode { anytime, specificTime }

class DailySchedule {
  const DailySchedule.anytime()
    : mode = DailyScheduleMode.anytime,
      hour = null,
      minute = null;

  const DailySchedule.specific({required this.hour, required this.minute})
    : mode = DailyScheduleMode.specificTime;

  final DailyScheduleMode mode;
  final int? hour;
  final int? minute;

  bool get hasSpecificTime => mode == DailyScheduleMode.specificTime;

  bool get isValid => mode == DailyScheduleMode.anytime
      ? hour == null && minute == null
      : hour != null &&
            minute != null &&
            hour! >= 0 &&
            hour! <= 23 &&
            minute! >= 0 &&
            minute! <= 59;
}
