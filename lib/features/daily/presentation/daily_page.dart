import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../domain/daily_activity.dart';
import '../domain/daily_schedule.dart';
import 'daily_view_model.dart';

class DailyPage extends StatefulWidget {
  const DailyPage({super.key});

  @override
  State<DailyPage> createState() => _DailyPageState();
}

class _DailyPageState extends State<DailyPage> {
  Timer? _dateRefreshTimer;

  @override
  void initState() {
    super.initState();
    _dateRefreshTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        unawaited(context.read<DailyViewModel>().refreshForDateIfNeeded());
      }
    });
  }

  @override
  void dispose() {
    _dateRefreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final viewModel = context.watch<DailyViewModel>();
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.daily('title'), key: const Key('daily-title')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('daily-add'),
        onPressed: () => _showEditor(context),
        icon: const Icon(Icons.add),
        label: Text(strings.daily('add')),
      ),
      body: switch (viewModel.status) {
        DailyStatus.idle ||
        DailyStatus.loading => const Center(child: CircularProgressIndicator()),
        DailyStatus.error when viewModel.activities.isEmpty => Center(
          child: Text(strings.error(viewModel.errorMessage ?? 'loadDaily')),
        ),
        _ => _DailyList(viewModel: viewModel),
      },
    );
  }

  Future<void> _showEditor(
    BuildContext context, {
    DailyActivity? activity,
  }) async {
    final viewModel = context.read<DailyViewModel>();
    await showDialog<void>(
      context: context,
      builder: (_) => ChangeNotifierProvider.value(
        value: viewModel,
        child: _DailyEditorDialog(activity: activity),
      ),
    );
  }
}

class _DailyList extends StatelessWidget {
  const _DailyList({required this.viewModel});

  final DailyViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (viewModel.activities.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.repeat,
                size: 52,
                color: Theme.of(context).colorScheme.secondary,
              ),
              const SizedBox(height: 12),
              Text(
                strings.daily('empty'),
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                strings.daily('emptyDescription'),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: viewModel.activities.length,
      itemBuilder: (context, index) {
        final activity = viewModel.activities[index];
        final completed = viewModel.isCompleted(activity);
        final schedule = activity.schedule.hasSpecificTime
            ? MaterialLocalizations.of(context).formatTimeOfDay(
                TimeOfDay(
                  hour: activity.schedule.hour!,
                  minute: activity.schedule.minute!,
                ),
              )
            : strings.daily('anytime');
        return Card(
          child: ListTile(
            leading: Semantics(
              label: completed
                  ? strings.daily('completed')
                  : strings.daily('incomplete'),
              checked: completed,
              child: Checkbox(
                value: completed,
                onChanged: (_) => viewModel.toggleCompleted(activity),
              ),
            ),
            title: Text(
              activity.name,
              style: completed
                  ? const TextStyle(decoration: TextDecoration.lineThrough)
                  : null,
            ),
            subtitle: Text(
              activity.schedule.hasSpecificTime
                  ? '$schedule · ${activity.notificationsEnabled ? strings.daily('notificationEnabled') : strings.daily('notificationDisabled')}'
                  : '${strings.daily('anytime')} · '
                        '${completed ? strings.daily('completed') : strings.daily('incomplete')}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  final viewModel = context.read<DailyViewModel>();
                  await showDialog<void>(
                    context: context,
                    builder: (_) => ChangeNotifierProvider.value(
                      value: viewModel,
                      child: _DailyEditorDialog(activity: activity),
                    ),
                  );
                } else {
                  await _confirmDelete(context, activity);
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(strings.daily('edit')),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(strings.daily('delete')),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    DailyActivity activity,
  ) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(strings.daily('deleteConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.daily('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.daily('delete')),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<DailyViewModel>().delete(activity);
    }
  }
}

class _DailyEditorDialog extends StatefulWidget {
  const _DailyEditorDialog({this.activity});

  final DailyActivity? activity;

  @override
  State<_DailyEditorDialog> createState() => _DailyEditorDialogState();
}

class _DailyEditorDialogState extends State<_DailyEditorDialog> {
  late final TextEditingController _nameController;
  late DailySchedule _schedule;
  late bool _notificationsEnabled;
  TimeOfDay? _time;
  bool _isSaving = false;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final activity = widget.activity;
    _nameController = TextEditingController(text: activity?.name);
    _schedule = activity?.schedule ?? const DailySchedule.anytime();
    _notificationsEnabled = activity?.notificationsEnabled ?? false;
    if (_schedule.hasSpecificTime) {
      _time = TimeOfDay(hour: _schedule.hour!, minute: _schedule.minute!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final isSpecific = _schedule.hasSpecificTime;
    return AlertDialog(
      title: Text(strings.daily(widget.activity == null ? 'add' : 'edit')),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: strings.daily('name'),
                hintText: strings.daily('nameHint'),
              ),
            ),
            if (_validationError != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _validationError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SegmentedButton<DailyScheduleMode>(
              segments: [
                ButtonSegment(
                  value: DailyScheduleMode.anytime,
                  label: Text(strings.daily('anytime')),
                ),
                ButtonSegment(
                  value: DailyScheduleMode.specificTime,
                  label: Text(strings.daily('specificTime')),
                ),
              ],
              selected: {_schedule.mode},
              onSelectionChanged: (value) {
                setState(() {
                  if (value.single == DailyScheduleMode.anytime) {
                    _schedule = const DailySchedule.anytime();
                    _notificationsEnabled = false;
                  } else {
                    _time ??= TimeOfDay.now();
                    _schedule = DailySchedule.specific(
                      hour: _time!.hour,
                      minute: _time!.minute,
                    );
                  }
                });
              },
            ),
            if (isSpecific) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.daily('specificTime')),
                trailing: TextButton(
                  onPressed: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: _time ?? TimeOfDay.now(),
                    );
                    if (selected == null) return;
                    setState(() {
                      _time = selected;
                      _schedule = DailySchedule.specific(
                        hour: selected.hour,
                        minute: selected.minute,
                      );
                    });
                  },
                  child: Text(
                    MaterialLocalizations.of(context)
                        .formatTimeOfDay(_time ?? TimeOfDay.now()),
                  ),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(strings.daily('notifications')),
                value: _notificationsEnabled,
                onChanged: _isSaving
                    ? null
                    : (value) async {
                        if (!value) {
                          setState(() => _notificationsEnabled = false);
                          return;
                        }
                        final allowed = await context
                            .read<DailyViewModel>()
                            .notifications
                            .requestPermission();
                        if (!context.mounted) return;
                        if (allowed) {
                          setState(() => _notificationsEnabled = true);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(strings.daily('permissionDenied')),
                            ),
                          );
                        }
                      },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.daily('cancel')),
        ),
        FilledButton(
          onPressed: _isSaving
              ? null
              : () async {
                  if (_nameController.text.trim().isEmpty) {
                    setState(
                      () => _validationError = strings.error('invalidDaily'),
                    );
                    return;
                  }
                  setState(() {
                    _isSaving = true;
                    _validationError = null;
                  });
                  final saved = await context.read<DailyViewModel>().save(
                    id: widget.activity?.id,
                    name: _nameController.text,
                    schedule: _schedule,
                    notificationsEnabled: _notificationsEnabled,
                  );
                  if (!context.mounted) return;
                  if (saved) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _isSaving = false;
                      _validationError = strings.error(
                        context.read<DailyViewModel>().errorMessage ??
                            'saveDaily',
                      );
                    });
                  }
                },
          child: Text(strings.daily(widget.activity == null ? 'add' : 'save')),
        ),
      ],
    );
  }
}
