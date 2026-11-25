import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../../core/notifications/platform_notification_service.dart';
import '../data/focus_repository.dart';
import '../domain/focus_session.dart';

class FocusViewModel extends ChangeNotifier with WidgetsBindingObserver {
  FocusViewModel(
    this.repository, {
    DateTime Function()? clock,
    this.notifications,
    this.notificationText,
    bool observeLifecycle = true,
  }) : _clock = clock ?? DateTime.now,
       _observeLifecycle = observeLifecycle {
    if (observeLifecycle) WidgetsBinding.instance.addObserver(this);
  }

  final FocusRepository repository;
  final PlatformNotificationService? notifications;
  final (String, String) Function()? notificationText;
  final DateTime Function() _clock;
  final bool _observeLifecycle;
  static const _notificationId = 19872231;
  final _random = Random.secure();
  Future<void> _notificationWork = Future.value();
  StreamSubscription<List<FocusSession>>? _historySubscription;
  Timer? _ticker;
  FocusPreferences _state = const FocusPreferences();
  List<FocusSession> history = const [];
  bool loading = true, busy = false, failed = false, historyFailed = false;
  bool _disposed = false, _foreground = true, _permissionRequested = false;
  String? activityKey, activityLabel;

  DateTime get now => _clock();
  FocusSettings get settings => _state.settings;
  FocusMode get mode => _state.mode;
  FocusSession? get active => _state.active;
  int get cycleCount => _state.cycleCount;
  List<FocusActivity> get activities => _state.activities;
  Set<int> get dailyActivityIds => Set.unmodifiable(_state.dailyActivityIds);

  Future<void> setDailyLinked(int id, bool linked) => _perform(() async {
    final ids = {..._state.dailyActivityIds};
    if (linked ? !ids.add(id) : !ids.remove(id)) return;
    await _commit(_state.copyWith(dailyActivityIds: ids));
    if (!linked && active == null && activityKey == 'daily:$id') {
      activityKey = null;
      activityLabel = null;
    }
  });
  Duration get planned => active?.planned ?? settings.duration(mode);
  Duration get remaining => active?.remaining(now) ?? planned;

  Future<void> restore() async {
    loading = true;
    failed = false;
    _notify();
    _historySubscription ??= repository.watchHistory().listen(
      (records) {
        history = records;
        historyFailed = false;
        _notify();
      },
      onError: (Object _) {
        historyFailed = true;
        _notify();
      },
    );
    try {
      _state = await repository.load();
      if (_disposed) return;
      activityKey = active?.activityKey;
      activityLabel = active?.activityLabel;
      loading = false;
      if (active?.running == true && remaining == Duration.zero) {
        await refresh(recovered: true);
      } else {
        _syncTicker();
        if (active case final FocusSession session when session.running) {
          _schedule(session);
        }
      }
    } catch (_) {
      failed = true;
    } finally {
      loading = false;
      _notify();
    }
  }

  Future<void> selectMode(FocusMode value) async {
    if (active == null) {
      await _perform(() => _commit(_state.copyWith(mode: value)));
    }
  }

  void selectActivity(String? key, String? label) {
    if (active != null || busy) return;
    activityKey = key;
    activityLabel = label;
    _notify();
  }

  Future<bool> updateSettings(FocusSettings value) async {
    if (!value.valid || busy || loading || _disposed) return false;
    await _perform(() => _commit(_state.copyWith(settings: value)));
    return !failed;
  }

  Future<void> saveActivity(
    String title, {
    FocusActivity? existing,
    int icon = 0,
    int color = 0,
    bool archive = false,
  }) async {
    if (title.trim().isEmpty) return;
    await _perform(() async {
      final activity = FocusActivity(
        existing?.id ?? _id(),
        title.trim(),
        icon: icon,
        color: color,
        archived: archive,
      );
      await _commit(
        _state.copyWith(
          activities: [
            ...activities.where((item) => item.id != activity.id),
            activity,
          ],
        ),
      );
      if (activityKey == 'custom:${activity.id}' && active == null) {
        if (archive) activityKey = null;
        activityLabel = archive ? null : activity.title;
      }
    });
  }

  Future<void> startOrResume() => _perform(() async {
    if (active?.running == true) return;
    final session = (active ?? _newSession(mode, now)).resume(now);
    await _commit(_state.copyWith(active: session));
    _schedule(session, request: true);
  });

  Future<void> pause() => _perform(() async {
    final session = active;
    if (session == null || !session.running) return;
    if (session.remaining(now) == Duration.zero) {
      await _finish(session, completed: true, automatic: false);
    } else {
      await _commit(_state.copyWith(active: session.pause(now)));
      _cancelAlert();
    }
  });

  Future<void> reset() => _perform(() async {
    if (active == null) return;
    await _commit(_state.copyWith(clearActive: true));
    _cancelAlert();
  });

  Future<void> stop() => _perform(() async {
    final session = active;
    if (session == null) return;
    final done = session.running && session.remaining(now) == Duration.zero;
    await _finish(session, completed: done, automatic: false);
  });

  Future<void> skipBreak() async {
    if (mode == FocusMode.focus) return;
    await _perform(() async {
      final session = active;
      if (session == null) {
        await _commit(_state.copyWith(mode: FocusMode.focus));
      } else {
        await _finish(session, completed: false, automatic: false);
      }
    });
  }

  Future<void> refresh({bool recovered = false}) async {
    final session = active;
    if (session == null || !session.running) return;
    if (session.remaining(now) > Duration.zero) {
      _notify();
      return;
    }
    await _perform(
      () => _finish(
        session,
        completed: true,
        automatic:
            !recovered &&
            _foreground &&
            now.difference(session.expectedEnd!) < const Duration(seconds: 3),
      ),
    );
  }

  Future<void> deleteSession(String id) =>
      _perform(() => repository.delete(id));

  Future<void> _finish(
    FocusSession session, {
    required bool completed,
    required bool automatic,
  }) async {
    final record = session.finish(now, completed: completed);
    final count = cycleCount + (completed && mode == FocusMode.focus ? 1 : 0);
    final next = completed
        ? nextFocusMode(mode, count, settings.cycle)
        : mode == FocusMode.focus
        ? mode
        : FocusMode.focus;
    final auto =
        completed &&
        automatic &&
        (next == FocusMode.focus ? settings.autoFocus : settings.autoBreak);
    final nextSession = auto ? _newSession(next, now).resume(now) : null;
    await _commit(
      _state.copyWith(
        mode: next,
        cycleCount: count,
        active: nextSession,
        clearActive: nextSession == null,
      ),
      record: record.actual > Duration.zero ? record : null,
    );
    if (_foreground || !completed) _cancelAlert();
    if (completed && automatic) {
      if (settings.sound) unawaited(SystemSound.play(SystemSoundType.alert));
      if (settings.vibration) unawaited(HapticFeedback.mediumImpact());
    }
    if (nextSession != null) _schedule(nextSession);
  }

  FocusSession _newSession(FocusMode mode, DateTime start) => FocusSession(
    id: _id(),
    mode: mode,
    planned: settings.duration(mode),
    started: start,
    activityKey: mode == FocusMode.focus ? activityKey : null,
    activityLabel: mode == FocusMode.focus ? activityLabel : null,
  );

  String _id() => '${now.microsecondsSinceEpoch}-${_random.nextInt(1 << 32)}';

  Future<void> _commit(FocusPreferences next, {FocusSession? record}) async {
    await repository.save(next, record: record);
    _state = next;
    _syncTicker();
  }

  Future<void> _perform(Future<void> Function() action) async {
    if (busy || loading || _disposed) return;
    busy = true;
    failed = false;
    _notify();
    try {
      await action();
    } catch (_) {
      failed = true;
    } finally {
      busy = false;
      _notify();
    }
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (!_disposed && active?.running == true) {
      _ticker = Timer.periodic(const Duration(milliseconds: 250), (_) {
        if (_foreground) unawaited(refresh());
      });
    }
  }

  void _schedule(FocusSession session, {bool request = false}) {
    final service = notifications;
    if (service == null) return;
    final settings = this.settings;
    final (title, body) =
        notificationText?.call() ?? ('Focus', 'Your session has ended.');
    _queueAlert(() async {
      if (_disposed || active?.expectedEnd != session.expectedEnd) return;
      final capability = request && !_permissionRequested
          ? await service.requestPermission()
          : await service.capability();
      if (request) _permissionRequested = true;
      if (capability.canSchedule &&
          !_disposed &&
          active?.expectedEnd == session.expectedEnd) {
        await service.scheduleFocus(
          id: _notificationId,
          end: session.expectedEnd!,
          title: title,
          body: body,
          sound: settings.sound,
          vibration: settings.vibration,
        );
      }
    });
  }

  void _cancelAlert() {
    final service = notifications;
    if (service != null) {
      _queueAlert(() async {
        await service.cancel(_notificationId);
      });
    }
  }

  void _queueAlert(Future<void> Function() work) {
    _notificationWork = _notificationWork.then((_) async {
      try {
        await work();
      } catch (_) {
        /* Notifications are optional. */
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground =
        state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive;
    if (state == AppLifecycleState.resumed) unawaited(refresh(recovered: true));
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (_observeLifecycle) WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _historySubscription?.cancel();
    super.dispose();
  }
}
