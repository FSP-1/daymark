import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../domain/goal.dart';
import 'goal_detail_page.dart';
import 'goal_editor_page.dart';
import 'goal_style.dart';
import 'goals_view_model.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  GoalFilter _filter = GoalFilter.all;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GoalsViewModel>();
    final strings = AppLocalizations.of(context);
    final visible = model.filtered(_filter);
    final completed = model.filtered(GoalFilter.completed).length;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          key: const Key('goals-page'),
          padding: const EdgeInsets.all(16),
          children: [
            Text(strings.goals('subtitle')),
            const SizedBox(height: 16),
            Row(
              children: [
                _Summary(
                  count: model.goals.length,
                  label: strings.goals('total'),
                ),
                _Summary(
                  count: model.goals.length - completed,
                  label: strings.goals('active'),
                ),
                _Summary(count: completed, label: strings.goals('completed')),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                for (final filter in GoalFilter.values)
                  ChoiceChip(
                    label: Text(strings.goals(filter.name)),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (model.loading)
              const LinearProgressIndicator()
            else if (model.failed)
              TextButton(
                onPressed: model.load,
                child: Text(strings.goals('loadError')),
              )
            else if (visible.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(strings.goals('empty')),
              ),
            for (final goal in visible) _GoalCard(goal: goal, model: model),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              key: const Key('goal-create'),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => GoalEditorPage(model: model)),
              ),
              icon: const Icon(Icons.add),
              label: Text(strings.goals('new')),
            ),
          ],
        ),
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.count, required this.label});
  final int count;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text('$count', style: Theme.of(context).textTheme.titleLarge),
        Text(label, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal, required this.model});
  final Goal goal;
  final GoalsViewModel model;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final color = goalColor(context, goal.color);
    final overdue = goal.overdue(DateTime.now());
    final deadline = goal.targetDate;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => GoalDetailPage.open(context, goal.id!),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(goalIcon(goal.icon), color: color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          goal.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${goal.percentage}%', style: TextStyle(color: color)),
                  IconButton(
                    tooltip: strings.goals('delete'),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: model.busy(goal)
                        ? null
                        : () =>
                              deleteGoalWithConfirmation(context, model, goal),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: goal.progress, color: color),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(goalProgressText(context, goal)),
                  if (deadline != null)
                    Text(
                      MaterialLocalizations.of(context)
                          .formatCompactDate(deadline),
                    ),
                  if (overdue)
                    Text(
                      strings.goals('overdue'),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                ],
              ),
              if (goal.tracking == GoalTracking.checklist)
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Wrap(
                    spacing: 4,
                    children: [
                      IconButton(
                        tooltip: strings.goals('decrease'),
                        onPressed: model.busy(goal)
                            ? null
                            : _quickAction(context, false),
                        icon: const Icon(Icons.remove),
                      ),
                      TextButton.icon(
                        onPressed: model.busy(goal)
                            ? null
                            : _quickAction(context, true),
                        icon: const Icon(Icons.add),
                        label: Text(strings.goals('advance')),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _quickAction(BuildContext context, bool forward) {
    final steps = goal.milestones.toList();
    final index = forward
        ? steps.indexWhere((step) => !step.complete && !step.linked)
        : steps.lastIndexWhere(
            (step) => step.complete && !step.fromDaily && !step.linked,
          );
    if (index < 0) return null;
    steps[index] = steps[index].toggle();
    return () =>
        saveGoalProgress(context, model, goal.withProgress(steps: steps));
  }
}
