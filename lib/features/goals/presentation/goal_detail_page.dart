import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../daily/presentation/daily_view_model.dart';
import '../domain/goal.dart';
import 'goal_editor_page.dart';
import 'goal_style.dart';
import 'goals_view_model.dart';

class GoalDetailPage extends StatefulWidget {
  const GoalDetailPage({required this.id, super.key});
  final int id;

  static void open(BuildContext context, int id) {
    final model = context.read<GoalsViewModel>();
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: model,
          child: GoalDetailPage(id: id),
        ),
      ),
    );
  }

  @override
  State<GoalDetailPage> createState() => _GoalDetailPageState();
}

class _GoalDetailPageState extends State<GoalDetailPage> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();
    final goal = model.goals.where((item) => item.id == widget.id).firstOrNull;
    final strings = AppLocalizations.of(context);
    if (goal == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(strings.goals('missing'))),
      );
    }
    final dates = MaterialLocalizations.of(context);
    final busy = model.busy(goal);
    final color = goalColor(context, goal.color);

    return Scaffold(
      appBar: AppBar(
        title: Text(goal.title),
        actions: [
          IconButton(
            tooltip: strings.goals('edit'),
            onPressed: busy
                ? null
                : () => Navigator.push<void>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GoalEditorPage(model: model, goal: goal),
                    ),
                  ),
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: strings.goals('delete'),
            onPressed: busy ? null : () => _delete(model, goal),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('goal-detail'),
          padding: const EdgeInsets.all(16),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(
                    goal.targetDate == null
                        ? '${strings.goals('start')} · ${dates.formatMediumDate(goal.startDate)}'
                        : '${strings.goals('deadline')} · ${dates.formatMediumDate(goal.targetDate!)}',
                  ),
                ),
                Chip(
                  label: Text(
                    strings.goals(
                      goal.completed
                          ? 'completed'
                          : goal.overdue(DateTime.now())
                          ? 'overdue'
                          : 'active',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              goalProgressText(context, goal),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(color: color, value: goal.progress),
            if (goal.dailyCredits > 0 &&
                goal.tracking != GoalTracking.checklist)
              Text(
                strings
                    .goals('dailyCredits')
                    .replaceFirst('{count}', '${goal.dailyCredits}'),
              ),
            const SizedBox(height: 12),
            if (goal.tracking == GoalTracking.checklist)
              _Milestones(goal: goal, model: model, disabled: busy),
            if (goal.tracking == GoalTracking.counter)
              Text(strings.goals('counterFromDaily')),
          ],
        ),
      ),
    );
  }

  Future<void> _delete(GoalsViewModel model, Goal goal) async {
    if (!await confirmGoalAction(context, 'delete', 'deleteMessage') ||
        !mounted) {
      return;
    }
    final daily = context.read<DailyViewModel?>();
    if (await model.delete(goal)) {
      if (mounted) {
        daily?.load();
        Navigator.pop(context);
      }
    } else if (mounted) {
      _showError(context);
    }
  }
}

class _Milestones extends StatelessWidget {
  const _Milestones({
    required this.goal,
    required this.model,
    required this.disabled,
  });
  final Goal goal;
  final GoalsViewModel model;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, step) in goal.milestones.indexed)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Checkbox(
              value: step.complete,
              semanticLabel: step.title,
              onChanged: disabled || step.linked || step.fromDaily
                  ? null
                  : (_) => _update(
                      context,
                      (steps) => steps[index] = step.toggle(),
                    ),
            ),
            title: Text(step.title),
            subtitle: step.fromDaily
                ? Text(strings.goals('dailyStep'))
                : step.linked
                ? Text(strings.goals('linkedDaily'))
                : null,
            trailing: PopupMenuButton<String>(
              enabled: !disabled,
              onSelected: (action) => _select(context, index, action),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Text(strings.goals('editStep')),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(strings.goals('deleteStep')),
                ),
                if (index > 0)
                  PopupMenuItem(value: 'up', child: Text(strings.goals('up'))),
                if (index + 1 < goal.milestones.length)
                  PopupMenuItem(
                    value: 'down',
                    child: Text(strings.goals('down')),
                  ),
              ],
            ),
          ),
        OutlinedButton.icon(
          onPressed: disabled ? null : () => _edit(context),
          icon: const Icon(Icons.add),
          label: Text(strings.goals('addStep')),
        ),
      ],
    );
  }

  Future<void> _edit(BuildContext context, [int? index]) async {
    final strings = AppLocalizations.of(context);
    final original = index == null ? null : goal.milestones[index];
    final title = await _editText(
      context,
      title: original == null ? 'addStep' : 'editStep',
      initial: original?.title ?? '',
      validate: (value) => value.isEmpty ? strings.goals('required') : null,
    );
    if (title == null || !context.mounted) return;
    await _update(context, (steps) {
      if (index == null) {
        steps.add(GoalMilestone(title: title));
      } else {
        steps[index] = original!.rename(title);
      }
    });
  }

  void _select(BuildContext context, int index, String action) {
    switch (action) {
      case 'edit':
        _edit(context, index);
      case 'delete':
        _update(context, (steps) => steps.removeAt(index));
      case 'up':
      case 'down':
        _update(context, (steps) {
          final step = steps.removeAt(index);
          steps.insert(index + (action == 'up' ? -1 : 1), step);
        });
    }
  }

  Future<void> _update(
    BuildContext context,
    void Function(List<GoalMilestone>) apply,
  ) {
    final steps = goal.milestones.toList();
    apply(steps);
    return saveGoalProgress(context, model, goal.withProgress(steps: steps));
  }
}

Future<String?> _editText(
  BuildContext context, {
  required String title,
  required String initial,
  required String? Function(String) validate,
  TextInputType? keyboardType,
}) {
  final strings = AppLocalizations.of(context);
  final form = GlobalKey<FormState>();
  var current = initial;
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(strings.goals(title)),
      content: Form(
        key: form,
        child: TextFormField(
          autofocus: true,
          initialValue: initial,
          keyboardType: keyboardType,
          onChanged: (value) => current = value.trim(),
          validator: (value) => validate(value?.trim() ?? ''),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.goals('cancel')),
        ),
        FilledButton(
          onPressed: () {
            if (form.currentState!.validate()) Navigator.pop(context, current);
          },
          child: Text(strings.goals('save')),
        ),
      ],
    ),
  );
}

Future<void> saveGoalProgress(
  BuildContext context,
  GoalsViewModel model,
  Goal goal,
) async {
  if (!await model.save(goal) && context.mounted) _showError(context);
}

void _showError(BuildContext context) => ScaffoldMessenger.of(context)
    .showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).goals('saveError'))),
    );

String goalProgressText(BuildContext context, Goal goal) {
  final strings = AppLocalizations.of(context);
  return switch (goal.tracking) {
    GoalTracking.checklist =>
      strings
          .goals('stepsProgress')
          .replaceFirst('{current}', '${goal.completedSteps}')
          .replaceFirst('{target}', '${goal.milestones.length}'),
    GoalTracking.counter =>
      strings
          .goals('counterProgress')
          .replaceFirst('{current}', _number(context, goal.totalValue))
          .replaceFirst('{target}', _number(context, goal.targetValue)),
    GoalTracking.manual => '${goal.percentage}%',
  };
}

String _number(BuildContext context, double value) {
  if (value == value.roundToDouble() && value.abs() < 1e15) {
    return value.toInt().toString();
  }
  final text = value.toString();
  return Localizations.localeOf(context).languageCode == 'es'
      ? text.replaceAll('.', ',')
      : text;
}
