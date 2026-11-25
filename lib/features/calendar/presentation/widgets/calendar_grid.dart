import 'package:material_ui/material_ui.dart';

import '../../../../core/localization/app_localizations.dart';
import '../calendar_view_model.dart';

Color calendarNoteColor(BuildContext context) =>
    Theme.of(context).colorScheme.tertiary;
Color calendarJournalColor(BuildContext context) =>
    Theme.of(context).colorScheme.primary;

Color calendarGoalColor(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;

class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    required this.month,
    required this.model,
    required this.content,
    this.onDaySelected,
    super.key,
  });

  final DateTime month;
  final CalendarViewModel model;
  final CalendarContent content;
  final ValueChanged<DateTime>? onDaySelected;

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final compact = onDaySelected == null;
    final first = dates.firstDayOfWeekIndex;
    final days = CalendarViewModel.monthDays(month, first);
    return Column(
      children: [
        if (!compact)
          Row(
            children: [
              for (var index = 0; index < 7; index++)
                Expanded(
                  child: Center(
                    child: Text(dates.narrowWeekdays[(first + index) % 7]),
                  ),
                ),
            ],
          ),
        if (!compact) const SizedBox(height: 4),
        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: compact ? 0 : 4,
            mainAxisSpacing: compact ? 0 : 4,
            mainAxisExtent: compact
                ? 18
                : MediaQuery.textScalerOf(context).scale(14) + 34,
          ),
          itemCount: days.length,
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) return const SizedBox.shrink();
            final today = day == model.today;
            final selected = day == model.selected;
            final notes = content.notesByDay.containsKey(day);
            final journal = content.entriesByDay.containsKey(day);
            final goals = content.goalsByDay.containsKey(day);
            if (compact) {
              return Center(
                child: Text(
                  dates.formatDecimal(day.day),
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: today || notes || journal || goals
                        ? FontWeight.bold
                        : null,
                    decoration: notes || journal || goals
                        ? TextDecoration.underline
                        : null,
                    color: notes
                        ? calendarNoteColor(context)
                        : journal
                        ? calendarJournalColor(context)
                        : goals
                        ? calendarGoalColor(context)
                        : colors.onSurfaceVariant,
                  ),
                ),
              );
            }
            return Semantics(
              label: dates.formatFullDate(day),
              selected: selected,
              button: true,
              child: Material(
                color: selected
                    ? colors.primaryContainer
                    : colors.surfaceContainerHighest,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                  side: today
                      ? BorderSide(color: colors.primary, width: 2)
                      : BorderSide.none,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  key: ValueKey(day),
                  onTap: () => onDaySelected!(day),
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          dates.formatDecimal(day.day),
                          maxLines: 1,
                          style: TextStyle(
                            color: selected
                                ? colors.onPrimaryContainer
                                : colors.onSurface,
                          ),
                        ),
                        SizedBox(
                          height: 8,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (notes)
                                _Dot(color: calendarNoteColor(context)),
                              if (journal)
                                _Dot(color: calendarJournalColor(context)),
                              if (goals)
                                _Dot(color: calendarGoalColor(context)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class CalendarYearGrid extends StatelessWidget {
  const CalendarYearGrid({
    required this.model,
    required this.content,
    super.key,
  });

  final CalendarViewModel model;
  final CalendarContent content;

  @override
  Widget build(BuildContext context) {
    final dates = MaterialLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => GridView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: constraints.maxWidth >= 1000
              ? 4
              : constraints.maxWidth >= 650
              ? 3
              : 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          mainAxisExtent: MediaQuery.textScalerOf(context).scale(20) + 136,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          final month = DateTime(model.displayed.year, index + 1);
          final current =
              month.year == model.today.year &&
              month.month == model.today.month;
          return Material(
            color: current
                ? colors.primaryContainer
                : colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: ValueKey('calendar-month-${month.month}'),
              onTap: () => model.openMonth(month.month),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    Text(
                      dates.formatMonthYear(month),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    CalendarMonthGrid(
                      month: month,
                      model: model,
                      content: content,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CalendarLegend extends StatelessWidget {
  const CalendarLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Wrap(
        spacing: 12,
        children: [
          _label(calendarNoteColor(context), strings.navigation('notes')),
          _label(calendarJournalColor(context), strings.navigation('journal')),
          _label(calendarGoalColor(context), strings.navigation('goals')),
        ],
      ),
    );
  }

  Widget _label(Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _Dot(color: color),
      Text(label),
    ],
  );
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: Icon(Icons.circle, size: 5, color: color),
  );
}
