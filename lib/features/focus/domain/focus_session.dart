enum FocusMode { focus, shortBreak, longBreak }

class FocusClock {
  const FocusClock._();

  static Duration remaining(DateTime expectedEnd, DateTime now) {
    final result = expectedEnd.difference(now);
    return result.isNegative ? Duration.zero : result;
  }

  static String timeText(Duration value) {
    final seconds = (value.inMilliseconds / 1000).ceil().clamp(0, 86400);
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
  }
}

class FocusSettings {
  const FocusSettings({
    this.focus = 25,
    this.shortBreak = 5,
    this.longBreak = 15,
    this.cycle = 4,
    this.autoBreak = false,
    this.autoFocus = false,
    this.sound = true,
    this.vibration = true,
  });

  final int focus, shortBreak, longBreak, cycle;
  final bool autoBreak, autoFocus, sound, vibration;

  bool get valid =>
      focus >= 1 &&
      focus <= 120 &&
      shortBreak >= 1 &&
      shortBreak <= 30 &&
      longBreak >= 1 &&
      longBreak <= 60 &&
      cycle >= 2 &&
      cycle <= 8;

  Duration duration(FocusMode mode) => Duration(
    minutes: switch (mode) {
      FocusMode.focus => focus,
      FocusMode.shortBreak => shortBreak,
      FocusMode.longBreak => longBreak,
    },
  );

  FocusSettings copyWith({
    int? focus,
    int? shortBreak,
    int? longBreak,
    int? cycle,
    bool? autoBreak,
    bool? autoFocus,
    bool? sound,
    bool? vibration,
  }) => FocusSettings(
    focus: focus ?? this.focus,
    shortBreak: shortBreak ?? this.shortBreak,
    longBreak: longBreak ?? this.longBreak,
    cycle: cycle ?? this.cycle,
    autoBreak: autoBreak ?? this.autoBreak,
    autoFocus: autoFocus ?? this.autoFocus,
    sound: sound ?? this.sound,
    vibration: vibration ?? this.vibration,
  );

  factory FocusSettings.fromJson(Map<String, dynamic> json) => FocusSettings(
    focus: (json['focus'] as int? ?? 25).clamp(1, 120),
    shortBreak: (json['shortBreak'] as int? ?? 5).clamp(1, 30),
    longBreak: (json['longBreak'] as int? ?? 15).clamp(1, 60),
    cycle: (json['cycle'] as int? ?? 4).clamp(2, 8),
    autoBreak: json['autoBreak'] as bool? ?? false,
    autoFocus: json['autoFocus'] as bool? ?? false,
    sound: json['sound'] as bool? ?? true,
    vibration: json['vibration'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'focus': focus,
    'shortBreak': shortBreak,
    'longBreak': longBreak,
    'cycle': cycle,
    'autoBreak': autoBreak,
    'autoFocus': autoFocus,
    'sound': sound,
    'vibration': vibration,
  };
}

FocusMode nextFocusMode(FocusMode mode, int completedFocus, int cycle) {
  if (mode != FocusMode.focus) return FocusMode.focus;
  return cycle > 0 && completedFocus > 0 && completedFocus % cycle == 0
      ? FocusMode.longBreak
      : FocusMode.shortBreak;
}

class FocusActivity {
  const FocusActivity(
    this.id,
    this.title, {
    this.icon = 0,
    this.color = 0,
    this.archived = false,
  });

  final String id, title;
  final int icon, color;
  final bool archived;

  factory FocusActivity.fromJson(Map<String, dynamic> json) => FocusActivity(
    json['id'] as String,
    json['title'] as String,
    icon: json['icon'] as int,
    color: json['color'] as int,
    archived: json['archived'] as bool,
  );
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'icon': icon,
    'color': color,
    'archived': archived,
  };
}

class FocusInterval {
  const FocusInterval(this.start, this.end);
  final DateTime start, end;
  Duration get duration => end.difference(start);

  Duration between(DateTime first, DateTime last) {
    final from = start.isAfter(first) ? start : first;
    final to = end.isBefore(last) ? end : last;
    return to.isAfter(from) ? to.difference(from) : Duration.zero;
  }

  factory FocusInterval.fromJson(List<dynamic> values) =>
      FocusInterval(_date(values[0]), _date(values[1]));
  List<int> toJson() => [
    start.millisecondsSinceEpoch,
    end.millisecondsSinceEpoch,
  ];
}

class FocusSession {
  const FocusSession({
    required this.id,
    required this.mode,
    required this.planned,
    required this.started,
    this.intervals = const [],
    this.segmentStart,
    this.expectedEnd,
    this.finished,
    this.completed = false,
    this.activityKey,
    this.activityLabel,
    this.goalId,
    this.goalLabel,
  });

  final String id;
  final FocusMode mode;
  final Duration planned;
  final DateTime started;
  final List<FocusInterval> intervals;
  final DateTime? segmentStart, expectedEnd, finished;
  final bool completed;
  final String? activityKey, activityLabel, goalLabel;
  final int? goalId;

  bool get running => expectedEnd != null;
  Duration get actual =>
      intervals.fold(Duration.zero, (sum, interval) => sum + interval.duration);
  Duration get pausedRemaining =>
      actual >= planned ? Duration.zero : planned - actual;
  Duration remaining(DateTime now) => expectedEnd == null
      ? pausedRemaining
      : FocusClock.remaining(expectedEnd!, now);

  FocusSession resume(DateTime now) =>
      _copy(segmentStart: now, expectedEnd: now.add(pausedRemaining));

  FocusSession pause(DateTime now) {
    if (!running) return this;
    final start = segmentStart!;
    final end = now.isAfter(expectedEnd!) ? expectedEnd! : now;
    return _copy(
      intervals: [
        ...intervals,
        if (end.isAfter(start)) FocusInterval(start, end),
      ],
    );
  }

  FocusSession finish(DateTime now, {required bool completed}) {
    final end = expectedEnd != null && now.isAfter(expectedEnd!)
        ? expectedEnd!
        : now;
    return pause(end)._copy(finished: end, completed: completed);
  }

  FocusSession _copy({
    List<FocusInterval>? intervals,
    DateTime? segmentStart,
    DateTime? expectedEnd,
    DateTime? finished,
    bool completed = false,
  }) => FocusSession(
    id: id,
    mode: mode,
    planned: planned,
    started: started,
    intervals: intervals ?? this.intervals,
    segmentStart: segmentStart,
    expectedEnd: expectedEnd,
    finished: finished,
    completed: completed,
    activityKey: activityKey,
    activityLabel: activityLabel,
    goalId: goalId,
    goalLabel: goalLabel,
  );

  Duration between(DateTime first, DateTime last) => intervals.fold(
    Duration.zero,
    (sum, item) => sum + item.between(first, last),
  );

  factory FocusSession.fromJson(Map<String, dynamic> json) => FocusSession(
    id: json['id'] as String,
    mode: FocusMode.values.byName(json['mode'] as String),
    planned: Duration(milliseconds: json['planned'] as int),
    started: _date(json['started']),
    intervals: [
      for (final value in json['intervals'] as List)
        FocusInterval.fromJson(value as List),
    ],
    segmentStart: _optionalDate(json['segmentStart']),
    expectedEnd: _optionalDate(json['expectedEnd']),
    finished: _optionalDate(json['finished']),
    completed: json['completed'] as bool,
    activityKey: json['activityKey'] as String?,
    activityLabel: json['activityLabel'] as String?,
    goalId: json['goalId'] as int?,
    goalLabel: json['goalLabel'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'mode': mode.name,
    'planned': planned.inMilliseconds,
    'started': started.millisecondsSinceEpoch,
    'intervals': intervals.map((item) => item.toJson()).toList(),
    'segmentStart': segmentStart?.millisecondsSinceEpoch,
    'expectedEnd': expectedEnd?.millisecondsSinceEpoch,
    'finished': finished?.millisecondsSinceEpoch,
    'completed': completed,
    'activityKey': activityKey,
    'activityLabel': activityLabel,
    'goalId': goalId,
    'goalLabel': goalLabel,
  };
}

DateTime _date(dynamic value) =>
    DateTime.fromMillisecondsSinceEpoch(value as int);
DateTime? _optionalDate(dynamic value) => value == null ? null : _date(value);

DateTime focusDay(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime focusNextDay(DateTime date) =>
    DateTime(date.year, date.month, date.day + 1);
