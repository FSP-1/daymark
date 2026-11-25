import 'package:flutter/foundation.dart';

import 'feature_id.dart';
import 'navigation_preferences.dart';

class NavigationViewModel extends ChangeNotifier {
  NavigationViewModel(this.preferences);

  static const maxOptional = 4;
  static const defaults = [
    FeatureId.notes,
    FeatureId.calendar,
    FeatureId.daily,
    FeatureId.journal,
  ];

  final NavigationPreferences preferences;
  List<FeatureId> _pinned = defaults;
  FeatureId _selected = FeatureId.home;
  Future<void> _pendingSave = Future.value();
  bool _disposed = false;
  bool failed = false;
  bool loading = true;

  List<FeatureId> get pinned => List.unmodifiable(_pinned);
  List<FeatureId> get destinations => [FeatureId.home, ..._pinned];
  FeatureId get selected => _selected;

  Future<void> load() async {
    try {
      final saved = await preferences.load();
      if (saved != null) {
        _pinned = saved
            .where((id) => id != FeatureId.home)
            .toSet()
            .take(maxOptional)
            .toList();
      }
    } catch (_) {
      failed = true;
    } finally {
      loading = false;
      _notify();
    }
  }

  void select(FeatureId id) {
    if (id == _selected || !destinations.contains(id)) return;
    _selected = id;
    _notify();
  }

  Future<void> setPinned(FeatureId id, bool visible) async {
    if (id == FeatureId.home ||
        _pinned.contains(id) == visible ||
        (visible && _pinned.length >= maxOptional)) {
      return;
    }
    await _change(
      visible
          ? [..._pinned, id]
          : _pinned.where((value) => value != id).toList(),
    );
  }

  Future<void> move(FeatureId id, int offset) async {
    final previous = _pinned.indexOf(id);
    final next = previous + offset;
    if (previous < 0 || next < 0 || next >= _pinned.length) return;
    final reordered = [..._pinned]
      ..removeAt(previous)
      ..insert(next, id);
    await _change(reordered);
  }

  Future<void> restoreDefaults() => _change(defaults);

  Future<void> _change(List<FeatureId> next) {
    _pinned = next;
    if (!destinations.contains(_selected)) _selected = FeatureId.home;
    failed = false;
    _notify();
    _pendingSave = _pendingSave.then((_) async {
      try {
        await preferences.save(next);
      } catch (_) {
        if (identical(next, _pinned)) {
          failed = true;
          _notify();
        }
      }
    });
    return _pendingSave;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
