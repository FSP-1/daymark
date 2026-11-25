import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_localizations.dart';
import '../domain/focus_session.dart';
import '../domain/focus_statistics.dart';
import 'focus_page.dart';
import 'focus_view_model.dart';

class FocusHistoryPage extends StatefulWidget {
  const FocusHistoryPage({required this.model, super.key});
  final FocusViewModel model;

  @override
  State<FocusHistoryPage> createState() => _FocusHistoryPageState();
}

class _FocusHistoryPageState extends State<FocusHistoryPage> {
  bool _monthly = false;
  DateTimeRange? _range;
  String? _activity;

  @override
  Widget build(BuildContext context) {
    final model = widget.model;
    final strings = AppLocalizations.of(context);
    final dates = MaterialLocalizations.of(context);
    final today = focusDay(model.now);
    final week = DateTime(
      today.year,
      today.month,
      today.day - (today.weekday % 7 - dates.firstDayOfWeekIndex) % 7,
    );
    final weekEnd = DateTime(week.year, week.month, week.day + 7);
    final month = DateTime(today.year, today.month);
    final monthEnd = DateTime(today.year, today.month + 1);

    return Scaffold(
      appBar: AppBar(title: Text(strings.focus('history'))),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: model,
          builder: (context, _) {
            final records = model.history;
            final weekly = FocusStatistics(records, week, weekEnd);
            final monthly = FocusStatistics(records, month, monthEnd);
            final stats = _monthly ? monthly : weekly;
            final group = stats.byActivity.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            final activities =
                records
                    .map((entry) => entry.activityLabel)
                    .whereType<String>()
                    .toSet()
                    .toList()
                  ..sort();
            final selected = activities.contains(_activity) ? _activity : null;
            final filtered = records.where(
              (session) =>
                  (selected == null || session.activityLabel == selected) &&
                  (_range == null ||
                      session.between(
                            _range!.start,
                            focusNextDay(_range!.end),
                          ) >
                          Duration.zero),
            );
            final bins = <(String, Duration)>[];
            final span = _monthly ? 7 : 1;
            for (var start = stats.start; start.isBefore(stats.end);) {
              final next = DateTime(start.year, start.month, start.day + span);
              final end = next.isAfter(stats.end) ? stats.end : next;
              bins.add((
                _monthly
                    ? dates.formatDecimal(start.day)
                    : dates.narrowWeekdays[start.weekday % 7],
                FocusStatistics(records, start, end).concentration,
              ));
              start = next;
            }

            return ListView(
              key: const Key('focus-history'),
              padding: const EdgeInsets.all(16),
              children: [
                if (model.historyFailed)
                  TextButton(
                    onPressed: model.restore,
                    child: Text(strings.focus('error')),
                  ),
                FocusSummary(
                  values: [
                    (
                      focusDurationText(weekly.concentration),
                      strings.focus('week'),
                    ),
                    (
                      focusDurationText(monthly.concentration),
                      strings.focus('month'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text(strings.focus('week')),
                      selected: !_monthly,
                      onSelected: (_) => setState(() => _monthly = false),
                    ),
                    ChoiceChip(
                      label: Text(strings.focus('month')),
                      selected: _monthly,
                      onSelected: (_) => setState(() => _monthly = true),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FocusChart(bins: bins),
                const SizedBox(height: 16),
                Text(
                  strings.focus('byActivity'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (group.isEmpty) Text(strings.focus('noHistory')),
                for (final entry in group)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(entry.key ?? strings.focus('none')),
                            ),
                            Text(focusDurationText(entry.value)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value:
                              entry.value.inMilliseconds /
                              stats.concentration.inMilliseconds,
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 30),
                Text(
                  strings.focus('recent'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _range == null
                            ? strings.focus('dates')
                            : '${dates.formatShortDate(_range!.start)} – ${dates.formatShortDate(_range!.end)}',
                      ),
                      onPressed: () async {
                        final range = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          lastDate: today,
                          initialDateRange: _range,
                        );
                        if (range != null && mounted) {
                          setState(() => _range = range);
                        }
                      },
                    ),
                    if (_range != null)
                      IconButton(
                        tooltip: strings.focus('clearDates'),
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _range = null),
                      ),
                  ],
                ),
                DropdownButton<String>(
                  value: selected ?? '',
                  isExpanded: true,
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(strings.focus('allActivities')),
                    ),
                    for (final item in activities)
                      DropdownMenuItem(
                        value: item,
                        child: Text(item, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (value) => setState(
                    () => _activity = value?.isEmpty == true ? null : value,
                  ),
                ),
                if (filtered.isEmpty) Text(strings.focus('noHistory')),
                for (final session in filtered)
                  FocusHistoryTile(session: session, model: model),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FocusChart extends StatelessWidget {
  const _FocusChart({required this.bins});
  final List<(String, Duration)> bins;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = bins.fold<int>(
      1,
      (max, bin) => bin.$2.inMilliseconds > max ? bin.$2.inMilliseconds : max,
    );
    return SizedBox(
      height: 138,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final (label, duration) in bins)
            Expanded(
              child: Semantics(
                label: '$label · ${focusDurationText(duration)}',
                child: Tooltip(
                  message: focusDurationText(duration),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            widthFactor: .78,
                            heightFactor: duration.inMilliseconds / max,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(label, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class FocusHistoryTile extends StatelessWidget {
  const FocusHistoryTile({
    required this.session,
    required this.model,
    this.day,
    super.key,
  });
  final FocusSession session;
  final FocusViewModel model;
  final DateTime? day;

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    final strings = AppLocalizations.of(context);
    final duration = day == null
        ? session.actual
        : session.between(day!, focusNextDay(day!));
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        session.mode == FocusMode.focus
            ? Icons.timer_outlined
            : Icons.coffee_outlined,
      ),
      title: Text(
        session.activityLabel ?? strings.focus(session.mode.name),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        '${dates.formatMediumDate(session.started)} · ${strings.focus(session.completed ? 'completed' : 'interrupted')}',
      ),
      trailing: Text(focusDurationText(duration)),
      onTap: () => Navigator.push<void>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              FocusSessionDetailPage(session: session, model: model),
        ),
      ),
    );
  }
}

class FocusSessionDetailPage extends StatelessWidget {
  const FocusSessionDetailPage({
    required this.session,
    required this.model,
    super.key,
  });
  final FocusSession session;
  final FocusViewModel model;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final dates = MaterialLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.focus('detail')),
        actions: [
          IconButton(
            tooltip: strings.focus('delete'),
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              if (!await confirmFocus(context, 'delete', 'deleteConfirm') ||
                  !context.mounted) {
                return;
              }
              await model.deleteSession(session.id);
              if (!context.mounted) return;
              if (model.failed) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(strings.focus('error'))));
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ListTile(
              title: Text(
                session.activityLabel ?? strings.focus(session.mode.name),
              ),
              subtitle: Text(
                strings.focus(session.completed ? 'completed' : 'interrupted'),
              ),
            ),
            ListTile(
              title: Text(focusDurationText(session.actual)),
              subtitle: Text(strings.focus('time')),
            ),
            ListTile(
              title: Text(dates.formatFullDate(session.started)),
              subtitle: Text(
                dates.formatTimeOfDay(TimeOfDay.fromDateTime(session.started)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
