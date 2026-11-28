import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../daily/presentation/daily_view_model.dart';
import '../domain/focus_session.dart';
import 'focus_view_model.dart';

const _activityIcons = [
  Icons.adjust,
  Icons.menu_book_outlined,
  Icons.code,
  Icons.brush_outlined,
];

IconData focusActivityIcon(int index) =>
    _activityIcons[index.clamp(0, _activityIcons.length - 1)];

class FocusActivitiesPage extends StatelessWidget {
  const FocusActivitiesPage({required this.model, super.key});

  final FocusViewModel model;

  @override
  Widget build(BuildContext context) {
    final daily = context.watch<DailyViewModel?>();
    final items = daily?.activities ?? [];
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final palette = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(strings.focus('activities'))),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final custom = model.activities.where((item) => !item.archived);
            final links = model.dailyActivityIds;
            final linked = items.where((item) => links.contains(item.id));
            return ListView(
              key: const Key('focus-activities-page'),
              padding: const EdgeInsets.all(16),
              children: [
                Text(strings.focus('activityManagerHelp')),
                if (model.failed) Text(strings.focus('error')),
                const SizedBox(height: 20),
                Text(
                  strings.focus('customActivities'),
                  style: theme.textTheme.titleMedium,
                ),
                if (custom.isNotEmpty)
                  Text(strings.focus('customActivitiesHelp')),
                if (custom.isEmpty) Text(strings.focus('noCustomActivities')),
                for (final activity in custom)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      _activityIcons[activity.icon.clamp(
                        0,
                        _activityIcons.length - 1,
                      )],
                      color:
                          palette[activity.color.clamp(0, palette.length - 1)],
                    ),
                    title: Text(activity.title),
                    onTap: model.busy
                        ? null
                        : () => _editActivity(context, model, activity),
                    trailing: IconButton(
                      tooltip: strings.focus('archive'),
                      icon: const Icon(Icons.delete_outline),
                      onPressed: model.busy
                          ? null
                          : () async {
                              if (await _confirmRemoval(
                                context,
                                strings,
                                'archive',
                                'archiveActivityHelp',
                              )) {
                                await model.saveActivity(
                                  activity.title,
                                  existing: activity,
                                  icon: activity.icon,
                                  color: activity.color,
                                  archive: true,
                                );
                              }
                            },
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: FilledButton.tonalIcon(
                    onPressed: model.busy
                        ? null
                        : () => _editActivity(context, model),
                    icon: const Icon(Icons.add),
                    label: Text(strings.focus('newActivity')),
                  ),
                ),
                const Divider(height: 32),
                Text(
                  strings.focus('dailyActivities'),
                  style: theme.textTheme.titleMedium,
                ),
                Text(strings.focus('dailyActivitiesHelp')),
                if (daily?.status == DailyStatus.loading)
                  const LinearProgressIndicator(),
                for (final item in linked)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.link),
                    title: Text(item.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: strings.focus('unlinkDaily'),
                      onPressed: model.busy
                          ? null
                          : () async {
                              if (await _confirmRemoval(
                                context,
                                strings,
                                'unlinkDaily',
                                'unlinkDailyHelp',
                              )) {
                                await model.setDailyLinked(item.id!, false);
                              }
                            },
                    ),
                  ),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: OutlinedButton.icon(
                    key: const Key('focus-add-daily'),
                    onPressed:
                        model.busy || daily?.status == DailyStatus.loading
                        ? null
                        : () async {
                            final available = items.where(
                              (item) =>
                                  item.id != null && !links.contains(item.id),
                            );
                            final id = await showDialog<int>(
                              context: context,
                              builder: (context) => SimpleDialog(
                                title: Text(strings.focus('addDaily')),
                                children: [
                                  if (available.isEmpty)
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        strings.focus('noDailyToAdd'),
                                      ),
                                    ),
                                  for (final item in available)
                                    SimpleDialogOption(
                                      onPressed: () =>
                                          Navigator.pop(context, item.id),
                                      child: Text(item.name),
                                    ),
                                ],
                              ),
                            );
                            if (id != null) {
                              await model.setDailyLinked(id, true);
                            }
                          },
                    icon: const Icon(Icons.add_link),
                    label: Text(strings.focus('addDaily')),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

Future<bool> _confirmRemoval(
  BuildContext context,
  AppLocalizations strings,
  String title,
  String message,
) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.focus(title)),
        content: Text(strings.focus(message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.focus('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(strings.focus(title)),
          ),
        ],
      ),
    ) ??
    false;

Future<void> _editActivity(
  BuildContext context,
  FocusViewModel model, [
  FocusActivity? activity,
]) async {
  final strings = AppLocalizations.of(context);
  var title = activity?.title ?? '';
  var icon = activity?.icon ?? 0;
  var color = activity?.color ?? 0;
  final colors = Theme.of(context).colorScheme;
  final palette = [colors.primary, colors.secondary, colors.tertiary];
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        scrollable: true,
        title: Text(
          strings.focus(activity == null ? 'newActivity' : 'editActivity'),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: title,
              onChanged: (value) => title = value,
              decoration: InputDecoration(
                labelText: strings.focus('activityName'),
              ),
            ),
            Wrap(
              spacing: 4,
              children: [
                for (final (index, item) in _activityIcons.indexed)
                  ChoiceChip(
                    label: Icon(item),
                    selected: icon == index,
                    onSelected: (_) => setState(() => icon = index),
                  ),
              ],
            ),
            Wrap(
              spacing: 4,
              children: [
                for (final (index, item) in palette.indexed)
                  ChoiceChip(
                    label: Icon(Icons.circle, color: item),
                    selected: color == index,
                    onSelected: (_) => setState(() => color = index),
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(strings.focus('cancel')),
          ),
          FilledButton(
            onPressed: () {
              if (title.trim().isNotEmpty) Navigator.pop(context, true);
            },
            child: Text(strings.focus('save')),
          ),
        ],
      ),
    ),
  );
  if (result != null) {
    await model.saveActivity(
      title,
      existing: activity,
      icon: icon,
      color: color,
    );
  }
}
