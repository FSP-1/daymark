import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_styles.dart';
import '../../daily/presentation/daily_view_model.dart';
import '../../daily/presentation/daily_activity_icons.dart';
import '../../settings/presentation/theme_view_model.dart';
import '../domain/focus_session.dart';
import '../domain/focus_statistics.dart';
import 'focus_history_page.dart';
import 'focus_activities_page.dart';
import 'focus_settings_page.dart';
import 'focus_view_model.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<FocusViewModel>();
    final daily = context.watch<DailyViewModel?>();
    final strings = AppLocalizations.of(context);
    final active = model.active;
    final day = focusDay(model.now);
    final statistics = FocusStatistics(model.history, day, focusNextDay(day));
    final style = context.watch<ThemeViewModel?>()?.style ?? AppStyle.soft;
    final cycle = model.settings.cycle;
    final options = _activities(model, daily, strings);
    final selected = options
        .where((item) => item.key == model.activityKey)
        .firstOrNull;
    final position = model.mode == FocusMode.focus
        ? model.cycleCount % cycle + 1
        : model.cycleCount == 0
        ? 1
        : (model.cycleCount - 1) % cycle + 1;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          key: const Key('focus-page'),
          padding: EdgeInsets.symmetric(
            horizontal: constraints.maxWidth > 600
                ? (constraints.maxWidth - 560) / 2
                : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: Text(strings.focus('subtitle'))),
                  IconButton(
                    tooltip: strings.focus('history'),
                    icon: const Icon(Icons.history),
                    onPressed: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FocusHistoryPage(model: model),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: strings.focus('settings'),
                    icon: const Icon(Icons.tune),
                    onPressed: () => FocusSettingsPage.open(context, model),
                  ),
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(strings.focus('howTo')),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(strings.focus('howToBody')),
                  ),
                ],
              ),
              if (model.loading) const LinearProgressIndicator(),
              if (model.failed)
                TextButton(
                  onPressed: model.restore,
                  child: Text(strings.focus('error')),
                ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final focus in [true, false])
                    ChoiceChip(
                      label: Text(strings.focus(focus ? 'focus' : 'rest')),
                      selected: (model.mode == FocusMode.focus) == focus,
                      onSelected: active != null || model.busy || model.loading
                          ? null
                          : (_) => model.selectMode(
                              focus
                                  ? FocusMode.focus
                                  : model.mode == FocusMode.focus
                                  ? nextFocusMode(
                                      FocusMode.focus,
                                      model.cycleCount,
                                      cycle,
                                    )
                                  : model.mode,
                            ),
                    ),
                ],
              ),
              const SizedBox(height: 22),
              Center(
                child: SizedBox.square(
                  dimension: (constraints.maxWidth - 64).clamp(0.0, 252.0),
                  child: FocusTimerRing(
                    remaining: model.remaining,
                    planned: model.planned,
                    style: style,
                    label: strings.focus(
                      model.mode == FocusMode.focus ? 'focus' : 'rest',
                    ),
                    status: strings.focus(
                      active == null
                          ? 'ready'
                          : active.running
                          ? 'running'
                          : 'paused',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    for (var index = 0; index < cycle; index++)
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: index < position
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 8),
                      child: Text(
                        strings
                            .focus('cycleLabel')
                            .replaceFirst('{current}', '$position')
                            .replaceFirst('{total}', '$cycle'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (model.mode == FocusMode.focus) ...[
                _AssociationTile(
                  icon: selected?.icon ?? Icons.category_outlined,
                  title: strings.focus('activity'),
                  value: model.activityLabel ?? strings.focus('none'),
                  onTap:
                      active == null &&
                          !model.busy &&
                          daily?.status != DailyStatus.loading
                      ? () => _chooseActivity(context, model, options)
                      : null,
                ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    key: const Key('focus-manage-activities'),
                    onPressed: active != null || model.loading
                        ? null
                        : () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FocusActivitiesPage(model: model),
                            ),
                          ),
                    icon: const Icon(Icons.settings_outlined),
                    label: Text(strings.focus('activities')),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: strings.focus('reset'),
                    icon: const Icon(Icons.restart_alt),
                    onPressed: model.busy || active == null
                        ? null
                        : model.reset,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      key: const Key('focus-toggle'),
                      onPressed: model.busy || model.loading
                          ? null
                          : active?.running == true
                          ? model.pause
                          : model.startOrResume,
                      icon: Icon(
                        active?.running == true
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                      label: Text(
                        strings.focus(
                          active == null
                              ? 'start'
                              : active.running
                              ? 'pause'
                              : 'resume',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    tooltip: strings.focus('stop'),
                    icon: const Icon(Icons.stop),
                    onPressed: model.busy || active == null
                        ? null
                        : () async {
                            if (await confirmFocus(
                              context,
                              'stop',
                              'stopConfirm',
                            )) {
                              await model.stop();
                            }
                          },
                  ),
                ],
              ),
              if (model.mode != FocusMode.focus)
                Center(
                  child: TextButton.icon(
                    onPressed: model.busy ? null : model.skipBreak,
                    icon: const Icon(Icons.skip_next),
                    label: Text(strings.focus('skip')),
                  ),
                ),
              const Divider(height: 28),
              Text(
                strings.focus('today'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              FocusSummary(
                values: [
                  (
                    focusDurationText(statistics.concentration),
                    strings.focus('time'),
                  ),
                  ('${statistics.completed}', strings.focus('sessions')),
                  (
                    focusDurationText(statistics.breaks),
                    strings.focus('breaks'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FocusTimerRing extends StatelessWidget {
  const FocusTimerRing({
    required this.remaining,
    required this.planned,
    required this.style,
    required this.label,
    required this.status,
    super.key,
  });

  final Duration remaining, planned;
  final AppStyle style;
  final String label, status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final value = planned == Duration.zero
        ? 0.0
        : (remaining.inMilliseconds / planned.inMilliseconds).clamp(0.0, 1.0);
    final smooth = style != AppStyle.minimal;
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: style == AppStyle.playful
                  ? 12
                  : smooth
                  ? 9
                  : 5,
              strokeCap: smooth ? StrokeCap.round : StrokeCap.butt,
              color: colors.primary,
              backgroundColor: colors.surfaceContainerHighest,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(25),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                Text(
                  FocusClock.timeText(remaining),
                  key: const Key('focus-countdown'),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(status, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FocusSummary extends StatelessWidget {
  const FocusSummary({required this.values, super.key});
  final List<(String, String)> values;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      for (final (value, label) in values)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                Text(
                  value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(label, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
    ],
  );
}

class _AssociationTile extends StatelessWidget {
  const _AssociationTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });
  final IconData icon;
  final String title, value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsets.zero,
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(value),
    onTap: onTap,
    trailing: onTap == null ? null : const Icon(Icons.expand_more),
  );
}

typedef _ActivityOption = ({
  String? key,
  String label,
  IconData icon,
  bool daily,
});

List<_ActivityOption> _activities(
  FocusViewModel model,
  DailyViewModel? daily,
  AppLocalizations strings,
) => [
  (
    key: null,
    label: strings.focus('none'),
    icon: Icons.remove_circle_outline,
    daily: false,
  ),
  for (final item in model.activities.where((item) => !item.archived))
    (
      key: 'custom:${item.id}',
      label: item.title,
      icon: focusActivityIcon(item.icon),
      daily: false,
    ),
  for (final item in daily?.activities ?? [])
    if (model.dailyActivityIds.contains(item.id))
      (
        key: 'daily:${item.id}',
        label: item.name,
        icon: DailyActivityIcons.iconFor(item.iconKey),
        daily: true,
      ),
];

Future<void> _chooseActivity(
  BuildContext context,
  FocusViewModel model,
  List<_ActivityOption> options,
) async {
  final strings = AppLocalizations.of(context);
  final choice = await showDialog<_ActivityOption>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(strings.focus('activity')),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(strings.focus('activityPickerHelp')),
        ),
        for (final option in options)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, option),
            child: Row(
              children: [
                Icon(option.icon, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    option.daily ? '${option.label} · Daily' : option.label,
                  ),
                ),
                if (option.key == model.activityKey) const Icon(Icons.check),
              ],
            ),
          ),
      ],
    ),
  );
  if (choice != null) {
    model.selectActivity(choice.key, choice.key == null ? null : choice.label);
  }
}

Future<bool> confirmFocus(
  BuildContext context,
  String title,
  String body,
) async {
  final strings = AppLocalizations.of(context);
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(strings.focus(title)),
          content: Text(strings.focus(body)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(strings.focus('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(strings.focus('confirm')),
            ),
          ],
        ),
      ) ??
      false;
}
