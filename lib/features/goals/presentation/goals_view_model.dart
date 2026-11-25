import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/goal_repository.dart';
import '../domain/goal.dart';

enum GoalFilter { all, active, completed }

class GoalsViewModel extends ChangeNotifier {
  GoalsViewModel(this.repository) {
    load();
  }

  final GoalRepository repository;
  StreamSubscription<List<Goal>>? _subscription;
  List<Goal> goals = const [];
  bool loading = true;
  bool failed = false;
  bool _disposed = false;
  final _busy = <int>{};

  bool busy(Goal goal) => _busy.contains(goal.id);

  void load() {
    _subscription?.cancel();
    loading = true;
    failed = false;
    _subscription = repository.watchGoals().listen(
      (items) {
        loading = false;
        failed = false;
        goals = items;
        _notify();
      },
      onError: (Object error) {
        loading = false;
        failed = true;
        _notify();
      },
    );
    _notify();
  }

  List<Goal> filtered(GoalFilter filter) => switch (filter) {
    GoalFilter.all => goals,
    GoalFilter.active => goals.where((goal) => !goal.completed).toList(),
    GoalFilter.completed => goals.where((goal) => goal.completed).toList(),
  };

  Future<bool> save(
    Goal goal, {
    int? counterActivityId,
    bool updateCounterLink = false,
  }) => _mutate(
    goal.id,
    () => repository.save(
      goal,
      counterActivityId: counterActivityId,
      updateCounterLink: updateCounterLink,
    ),
  );
  Future<bool> delete(Goal goal) =>
      _mutate(goal.id, () => repository.delete(goal.id!));

  Future<bool> _mutate(int? id, Future<Object?> Function() action) async {
    if (id != null && !_busy.add(id)) return false;
    _notify();
    try {
      await action();
      return true;
    } catch (_) {
      return false;
    } finally {
      _busy.remove(id);
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    super.dispose();
  }
}
