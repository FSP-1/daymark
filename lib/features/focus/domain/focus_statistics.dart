import 'focus_session.dart';

class FocusStatistics {
  FocusStatistics(this.sessions, this.start, this.end);

  final Iterable<FocusSession> sessions;
  final DateTime start, end;

  Duration get concentration => _total(FocusMode.focus, true);
  Duration get breaks => _total(FocusMode.focus, false);

  int get completed => sessions
      .where(
        (session) =>
            session.mode == FocusMode.focus &&
            session.completed &&
            session.finished != null &&
            !session.finished!.isBefore(start) &&
            session.finished!.isBefore(end),
      )
      .length;

  Duration _total(FocusMode mode, bool include) => sessions
      .where((session) => (session.mode == mode) == include)
      .fold(Duration.zero, (sum, session) => sum + session.between(start, end));

  Map<String?, Duration> get byActivity {
    final result = <String?, Duration>{};
    for (final session in sessions.where(
      (entry) => entry.mode == FocusMode.focus,
    )) {
      final duration = session.between(start, end);
      if (duration > Duration.zero) {
        result.update(
          session.activityLabel,
          (old) => old + duration,
          ifAbsent: () => duration,
        );
      }
    }
    return result;
  }
}

String focusDurationText(Duration value) {
  final minutes = value.inMinutes;
  if (minutes == 0 && value > Duration.zero) {
    return '${value.inSeconds.clamp(1, 59)} s';
  }
  return minutes < 60
      ? '$minutes min'
      : '${minutes ~/ 60} h ${minutes % 60} min';
}
