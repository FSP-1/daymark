import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../daily/domain/daily_activity.dart';
import '../../daily/presentation/daily_view_model.dart';
import '../domain/goal.dart';
import 'goals_view_model.dart';
import 'goal_style.dart';

class GoalEditorPage extends StatefulWidget {
  const GoalEditorPage({required this.model, this.goal, super.key});

  final GoalsViewModel model;
  final Goal? goal;

  @override
  State<GoalEditorPage> createState() => _GoalEditorPageState();
}

class _GoalEditorPageState extends State<GoalEditorPage> {
  final _form = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.goal?.title);
  late final _description = TextEditingController(
    text: widget.goal?.description,
  );
  final _stepTitle = TextEditingController();
  late final _steps = [...?widget.goal?.milestones];
  late final _target = TextEditingController(
    text: widget.goal?.targetValue.ceil().toString() ?? '1',
  );
  late GoalTracking _tracking = widget.goal?.tracking == GoalTracking.counter
      ? GoalTracking.counter
      : GoalTracking.checklist;
  DailyActivity? _counterActivity;
  late GoalIcon _icon = widget.goal?.icon ?? GoalIcon.target;
  late GoalColor _color = widget.goal?.color ?? GoalColor.primary;
  late DateTime _start = widget.goal?.startDate ?? Goal.day(DateTime.now());
  late DateTime? _deadline = widget.goal?.targetDate;
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    for (final controller in [_title, _description, _stepTitle, _target]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate(bool deadline) async {
    final next = await showDatePicker(
      context: context,
      firstDate: deadline ? _start : DateTime(1),
      lastDate: DateTime(9999, 12, 31),
      initialDate: deadline && _deadline?.isBefore(_start) == false
          ? _deadline!
          : _start,
    );
    if (!mounted || next == null) return;
    setState(() {
      if (deadline) {
        _deadline = next;
      } else {
        _start = next;
      }
      _error = null;
    });
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final existing = widget.goal;
    final counter =
        _counterActivity ??
        _currentCounter(context.read<DailyViewModel?>()?.activities ?? []);
    if (_tracking == GoalTracking.counter && counter == null) {
      setState(() => _error = 'counterNeedsDaily');
      return;
    }
    if (_deadline?.isBefore(_start) == true) {
      setState(() => _error = 'invalidDate');
      return;
    }
    final sameTracking = existing?.tracking == _tracking;
    if (!sameTracking && existing?.hasTrackingData == true) {
      final accepted = await confirmGoalAction(
        context,
        'changeTracking',
        'changeTrackingMessage',
      );
      if (!mounted || !accepted) return;
    }
    final goal = Goal(
      id: existing?.id,
      title: _title.text,
      description: _description.text,
      icon: _icon,
      color: _color,
      tracking: _tracking,
      startDate: _start,
      targetDate: _deadline,
      targetValue: _tracking == GoalTracking.counter
          ? int.parse(_target.text.trim()).toDouble()
          : 1,
      dailyCredits: sameTracking ? existing!.dailyCredits : 0,
      milestones: _tracking == GoalTracking.checklist
          ? [
              ..._steps,
              if (_stepTitle.text.trim().isNotEmpty)
                GoalMilestone(title: _stepTitle.text.trim()),
            ]
          : const [],
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    final daily = context.read<DailyViewModel?>();
    final saved = await widget.model.save(
      goal,
      counterActivityId: counter?.id,
      updateCounterLink: _tracking == GoalTracking.counter,
    );
    if (!mounted) return;
    if (saved) {
      daily?.load();
      Navigator.pop(context);
    } else {
      setState(() {
        _saving = false;
        _error = 'saveError';
      });
    }
  }

  void _addStep() {
    final title = _stepTitle.text.trim();
    if (title.isEmpty) return;
    setState(() => _steps.add(GoalMilestone(title: title)));
    _stepTitle.clear();
  }

  DailyActivity? _currentCounter(List<DailyActivity> activities) {
    final goal = widget.goal;
    if (goal == null || goal.tracking != GoalTracking.counter) return null;
    return activities.where((item) => item.goalId == goal.id).firstOrNull;
  }

  Future<void> _pickActivity(List<DailyActivity> activities) async {
    final strings = AppLocalizations.of(context);
    final used = _steps.map((step) => step.activityId).whereType<int>().toSet();
    final available = activities.where(
      (activity) =>
          (activity.goalId == null || activity.goalId == widget.goal?.id) &&
          (_tracking == GoalTracking.counter || !used.contains(activity.id)),
    );
    final selected = await showDialog<DailyActivity>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(strings.goals('chooseDaily')),
        children: [
          if (available.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(strings.goals('noAvailableDaily')),
            ),
          for (final activity in available)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, activity),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.check_circle_outline),
                title: Text(activity.name),
              ),
            ),
        ],
      ),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _error = null;
      if (_tracking == GoalTracking.counter) {
        _counterActivity = selected;
      } else {
        _steps.add(
          GoalMilestone(title: selected.name, activityId: selected.id),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dates = MaterialLocalizations.of(context);
    final theme = Theme.of(context);
    final activities = context.watch<DailyViewModel?>()?.activities ?? [];
    final counter = _counterActivity ?? _currentCounter(activities);
    final checklist = _tracking == GoalTracking.checklist;

    return Scaffold(
      appBar: AppBar(
        title: Text(strings.goals(widget.goal == null ? 'new' : 'edit')),
        actions: [
          TextButton(
            key: const Key('goal-save'),
            onPressed: _saving ? null : _save,
            child: Text(strings.goals('save')),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Form(
              key: _form,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      key: const Key('goal-title'),
                      controller: _title,
                      decoration: InputDecoration(
                        labelText: strings.goals('title'),
                        border: const OutlineInputBorder(),
                      ),
                      validator: (value) => value?.trim().isNotEmpty == true
                          ? null
                          : strings.goals('required'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      strings.goals('tracking'),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      key: const Key('goal-tracking'),
                      spacing: 8,
                      children: [
                        for (final type in [
                          GoalTracking.checklist,
                          GoalTracking.counter,
                        ])
                          ChoiceChip(
                            avatar: Icon(
                              type == GoalTracking.checklist
                                  ? Icons.checklist
                                  : Icons.pin_outlined,
                              size: 18,
                            ),
                            label: Text(strings.goals(type.name)),
                            selected: _tracking == type,
                            showCheckmark: false,
                            onSelected: _saving
                                ? null
                                : (_) => setState(() {
                                    _tracking = type;
                                    _error = null;
                                  }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              strings.goals(
                                checklist
                                    ? 'checklistSetup'
                                    : 'counterFromDaily',
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (checklist) ...[
                              for (final (index, step) in _steps.indexed)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  leading: Icon(
                                    step.linked
                                        ? Icons.link
                                        : Icons.check_box_outline_blank,
                                  ),
                                  title: Text(step.title),
                                  trailing: IconButton(
                                    tooltip: strings.goals('deleteStep'),
                                    onPressed: _saving
                                        ? null
                                        : () => setState(
                                            () => _steps.removeAt(index),
                                          ),
                                    icon: const Icon(Icons.close),
                                  ),
                                ),
                              TextField(
                                key: const Key('goal-draft-step'),
                                controller: _stepTitle,
                                onSubmitted: (_) => _addStep(),
                                decoration: InputDecoration(
                                  labelText: strings.goals('addStep'),
                                  border: const OutlineInputBorder(),
                                  suffixIcon: IconButton(
                                    tooltip: strings.goals('addStep'),
                                    onPressed: _saving ? null : _addStep,
                                    icon: const Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ] else ...[
                              TextFormField(
                                controller: _target,
                                key: const Key('goal-target'),
                                decoration: InputDecoration(
                                  labelText: strings.goals('target'),
                                  border: const OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  final target = int.tryParse(
                                    value?.trim() ?? '',
                                  );
                                  return target != null && target > 0
                                      ? null
                                      : strings.goals('invalidTarget');
                                },
                              ),
                              if (counter != null)
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.link),
                                  title: Text(counter.name),
                                  subtitle: Text(strings.goals('linkedDaily')),
                                ),
                            ],
                            const SizedBox(height: 8),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: OutlinedButton.icon(
                                key: const Key('goal-choose-daily'),
                                onPressed: _saving
                                    ? null
                                    : () => _pickActivity(activities),
                                icon: const Icon(Icons.link),
                                label: Text(
                                  strings.goals(
                                    counter != null && !checklist
                                        ? 'changeDaily'
                                        : 'chooseDaily',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          strings.goals(_error!),
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    const SizedBox(height: 14),
                    ExpansionTile(
                      key: const Key('goal-details'),
                      tilePadding: EdgeInsets.zero,
                      title: Text(strings.goals('details')),
                      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _description,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: strings.goals('description'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<GoalIcon>(
                          initialValue: _icon,
                          decoration: InputDecoration(
                            labelText: strings.goals('icon'),
                          ),
                          items: [
                            for (final icon in GoalIcon.values)
                              DropdownMenuItem(
                                value: icon,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(goalIcon(icon)),
                                    const SizedBox(width: 8),
                                    Text(strings.goals('icon_${icon.name}')),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (value) => setState(() => _icon = value!),
                        ),
                        DropdownButtonFormField<GoalColor>(
                          initialValue: _color,
                          decoration: InputDecoration(
                            labelText: strings.goals('color'),
                          ),
                          items: [
                            for (final color in GoalColor.values)
                              DropdownMenuItem(
                                value: color,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      color: goalColor(context, color),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(strings.goals('color_${color.name}')),
                                  ],
                                ),
                              ),
                          ],
                          onChanged: (value) => setState(() => _color = value!),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.today_outlined),
                          title: Text(strings.goals('start')),
                          subtitle: Text(dates.formatMediumDate(_start)),
                          onTap: () => _pickDate(false),
                        ),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.event_outlined),
                          title: Text(strings.goals('deadline')),
                          subtitle: Text(
                            _deadline == null
                                ? strings.goals('noDeadline')
                                : dates.formatMediumDate(_deadline!),
                          ),
                          onTap: () => _pickDate(true),
                          trailing: _deadline == null
                              ? null
                              : IconButton(
                                  tooltip: strings.goals('removeDeadline'),
                                  onPressed: () => setState(() {
                                    _deadline = null;
                                    _error = null;
                                  }),
                                  icon: const Icon(Icons.clear),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<bool> confirmGoalAction(
  BuildContext context,
  String title,
  String message,
) async {
  final strings = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.goals(title)),
          content: Text(strings.goals(message)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.goals('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.goals('confirm')),
            ),
          ],
        ),
      ) ??
      false;
}
