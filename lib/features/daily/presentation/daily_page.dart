import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../domain/daily_activity.dart';
import '../domain/daily_schedule.dart';
import 'daily_activity_icons.dart';
import 'daily_view_model.dart';
import 'widgets/daily_activity_card.dart';

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
      body: switch (viewModel.status) {
        DailyStatus.idle ||
        DailyStatus.loading => const Center(child: CircularProgressIndicator()),
        DailyStatus.error when viewModel.activities.isEmpty => Center(
          child: Text(strings.error(viewModel.errorMessage ?? 'loadDaily')),
        ),
        _ => _DailyContent(
          viewModel: viewModel,
          onAdd: () => _showEditor(context),
          onEdit: (activity) => _showEditor(context, activity: activity),
        ),
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

class _IconOption extends StatelessWidget {
  const _IconOption({
    required this.iconKey,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final String iconKey;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: selected
                ? colors.primaryContainer.withValues(alpha: 0.55)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: selected
                ? Border.all(color: colors.primary, width: 1.5)
                : Border.all(color: colors.outlineVariant),
          ),
          child: Icon(
            DailyActivityIcons.iconFor(iconKey),
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}

class _DailyContent extends StatelessWidget {
  const _DailyContent({
    required this.viewModel,
    required this.onAdd,
    required this.onEdit,
  });

  final DailyViewModel viewModel;
  final VoidCallback onAdd;
  final ValueChanged<DailyActivity> onEdit;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final completedCount = viewModel.activities
        .where(viewModel.isCompleted)
        .length;
    final total = viewModel.activities.length;
    final progress = total == 0 ? 0.0 : completedCount / total;
    final date = MaterialLocalizations.of(context)
        .formatFullDate(DateTime.now());
    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.daily('eyebrow').toUpperCase(),
              style: TextStyle(
                color: colors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.daily('title'),
              key: const Key('daily-title'),
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              date,
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(color: colors.primary),
            ),
            const SizedBox(height: 6),
            Text(
              strings.daily('description'),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _DailyProgress(
              completed: completedCount,
              total: total,
              progress: progress,
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Text(
                  strings.daily('activitiesHeading'),
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Text(
                  strings
                      .daily('activityCount')
                      .replaceFirst('{count}', '$total'),
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (viewModel.activities.isEmpty)
              _DailyEmptyState()
            else
              ...viewModel.activities.map(
                (activity) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: DailyActivityCard(
                    activity: activity,
                    completed: viewModel.isCompleted(activity),
                    onTap: () => onEdit(activity),
                    onCompleted: () => viewModel.toggleCompleted(activity),
                    onDelete: () => _confirmDelete(context, activity),
                    onEdit: () => onEdit(activity),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                key: const Key('daily-add'),
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(strings.daily('add')),
              ),
            ),
          ],
        ),
      ),
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

class _DailyProgress extends StatelessWidget {
  const _DailyProgress({
    required this.completed,
    required this.total,
    required this.progress,
  });

  final int completed;
  final int total;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.spa_outlined, color: colors.primary, size: 21),
              const SizedBox(width: 9),
              Text(
                strings.daily('progress'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '$completed/$total',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: colors.surface,
              color: colors.primary,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            completed == total && total > 0
                ? strings.daily('progressComplete')
                : strings.daily('progressKeepGoing'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _DailyEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Center(
        child: Text(
          strings.daily('empty'),
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
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
  late String _iconKey;
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
    _iconKey = activity?.iconKey ?? DailyActivityIcons.defaultKey;
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      title: Row(
        children: [
          Expanded(
            child: Text(
              strings.daily(widget.activity == null ? 'add' : 'edit'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: MaterialLocalizations.of(context).closeButtonLabel,
            onPressed: _isSaving ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 540,
          maxHeight: MediaQuery.sizeOf(context).height * 0.62,
        ),
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: strings.daily('name'),
                  hintText: strings.daily('nameHint'),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: colors.outlineVariant),
                  ),
                ),
              ),
              if (_validationError != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _validationError!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                strings.daily('icon'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final key in DailyActivityIcons.keys)
                    _IconOption(
                      iconKey: key,
                      selected: key == _iconKey,
                      label: strings.daily('iconOption'),
                      onTap: () => setState(() => _iconKey = key),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                strings.daily('schedule'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<DailyScheduleMode>(
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
              ),
              if (isSpecific) ...[
                const SizedBox(height: 12),
                InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: _time ?? TimeOfDay.now(),
                    );
                    if (selected == null || !mounted) return;
                    setState(() {
                      _time = selected;
                      _schedule = DailySchedule.specific(
                        hour: selected.hour,
                        minute: selected.minute,
                      );
                    });
                  },
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colors.outlineVariant),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.schedule_outlined, color: colors.primary),
                        const SizedBox(width: 10),
                        Expanded(child: Text(strings.daily('specificTime'))),
                        Text(
                          MaterialLocalizations.of(context)
                              .formatTimeOfDay(_time ?? TimeOfDay.now()),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  strings.daily('notifications'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(
                      alpha: 0.35,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.outlineVariant),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_outlined,
                        size: 28,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.daily('notifications'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.daily('notificationDescription'),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Switch(
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
                                      content: Text(
                                        strings.daily('permissionDenied'),
                                      ),
                                    ),
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        if (widget.activity != null)
          TextButton(
            onPressed: _isSaving ? null : _deleteActivity,
            child: Text(
              strings.daily('delete'),
              style: TextStyle(color: colors.error),
            ),
          ),
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
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
                    iconKey: _iconKey,
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

  Future<void> _deleteActivity() async {
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
    if (confirmed != true || !mounted) return;
    await context.read<DailyViewModel>().delete(widget.activity!);
    if (mounted) Navigator.pop(context);
  }
}
