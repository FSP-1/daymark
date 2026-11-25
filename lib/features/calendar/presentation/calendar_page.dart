import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../journal/presentation/journal_page.dart';
import '../../journal/presentation/journal_view_model.dart';
import '../../sticky_notes/presentation/sticky_notes_page.dart';
import '../../sticky_notes/presentation/sticky_notes_view_model.dart';
import 'calendar_view_model.dart';
import 'widgets/calendar_grid.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage>
    with WidgetsBindingObserver {
  final _model = CalendarViewModel();
  Timer? _midnight;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnight();
  }

  void _scheduleMidnight() {
    _midnight?.cancel();
    final now = DateTime.now();
    _midnight = Timer(
      DateTime(now.year, now.month, now.day + 1).difference(now),
      () {
        _model.refreshToday();
        _scheduleMidnight();
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _model.refreshToday();
      _scheduleMidnight();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnight?.cancel();
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = context.watch<StickyNotesViewModel>();
    final journal = context.watch<JournalViewModel>();
    final content = CalendarContent(notes.notes, journal.entries);
    final strings = AppLocalizations.of(context);
    final dates = MaterialLocalizations.of(context);

    return ListenableBuilder(
      listenable: _model,
      builder: (context, _) => Scaffold(
        key: const Key('calendar-page'),
        body: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1200),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      strings.navigation('calendar'),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    subtitle: Text(strings.calendar('description')),
                    trailing: IconButton(
                      tooltip: strings.calendar('today'),
                      onPressed: _model.goToToday,
                      icon: const Icon(Icons.today_outlined),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(strings.calendar('month')),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(strings.calendar('year')),
                        ),
                      ],
                      selected: {_model.annual},
                      onSelectionChanged: (value) =>
                          _model.showAnnual(value.single),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: strings.calendar('previous'),
                        onPressed: _model.canMove(-1)
                            ? () => _model.move(-1)
                            : null,
                        icon: const Icon(Icons.chevron_left),
                      ),
                      Expanded(
                        child: Text(
                          _model.annual
                              ? dates.formatYear(_model.displayed)
                              : dates.formatMonthYear(_model.displayed),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: strings.calendar('next'),
                        onPressed: _model.canMove(1)
                            ? () => _model.move(1)
                            : null,
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                  if (_model.annual)
                    CalendarYearGrid(model: _model, content: content)
                  else ...[
                    CalendarMonthGrid(
                      month: _model.displayed,
                      model: _model,
                      content: content,
                      onDaySelected: _model.select,
                    ),
                    const SizedBox(height: 12),
                    const CalendarLegend(),
                    const Divider(height: 32),
                    _DayContent(
                      model: _model,
                      content: content,
                      notes: notes,
                      journal: journal,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayContent extends StatelessWidget {
  const _DayContent({
    required this.model,
    required this.content,
    required this.notes,
    required this.journal,
  });

  final CalendarViewModel model;
  final CalendarContent content;
  final StickyNotesViewModel notes;
  final JournalViewModel journal;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final day = model.selected;
    final dayNotes = content.notesByDay[day] ?? [];
    final dayEntries = content.entriesByDay[day] ?? [];
    final loading =
        notes.status == StickyNotesStatus.loading ||
        journal.status == JournalStatus.loading;
    final failed =
        notes.status == StickyNotesStatus.error ||
        journal.status == JournalStatus.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          MaterialLocalizations.of(context).formatFullDate(day),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (loading) const LinearProgressIndicator(),
        if (failed)
          TextButton.icon(
            onPressed: () {
              notes.load();
              journal.load();
            },
            icon: const Icon(Icons.refresh),
            label: Text(strings.calendar('loadError')),
          ),
        if (!loading && !failed && dayNotes.isEmpty && dayEntries.isEmpty)
          Text(strings.calendar('empty')),
        for (final note in dayNotes)
          _ContentTile(
            title: note.title ?? strings.notes('untitled'),
            type: strings.calendar('note'),
            preview: note.content,
            drawing: note.drawingData?.isNotEmpty == true,
            icon: Icons.sticky_note_2_outlined,
            color: calendarNoteColor(context),
            onTap: () => StickyNotesPage.openNote(context, note),
          ),
        for (final entry in dayEntries)
          _ContentTile(
            title: entry.title ?? strings.journal('untitled'),
            type: strings.calendar('journalEntry'),
            preview: entry.content,
            drawing: entry.drawingData?.isNotEmpty == true,
            icon: Icons.menu_book_outlined,
            color: calendarJournalColor(context),
            onTap: () => JournalPage.openEntry(context, entry),
          ),
        const SizedBox(height: 12),
        OverflowBar(
          spacing: 8,
          overflowSpacing: 8,
          children: [
            OutlinedButton.icon(
              key: const Key('calendar-add-note'),
              onPressed: () => StickyNotesPage.openEditor(context, date: day),
              icon: const Icon(Icons.add),
              label: Text(strings.notes('addNote')),
            ),
            OutlinedButton.icon(
              key: const Key('calendar-write-journal'),
              onPressed: model.canWriteJournal
                  ? () => JournalPage.openEditor(context, date: day)
                  : null,
              icon: const Icon(Icons.menu_book_outlined),
              label: Text(strings.calendar('writeJournal')),
            ),
          ],
        ),
        if (!model.canWriteJournal) Text(strings.journal('futureDate')),
      ],
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile({
    required this.title,
    required this.type,
    required this.preview,
    required this.drawing,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String type;
  final String preview;
  final bool drawing;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: color),
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    subtitle: Text(
      preview.trim().isEmpty ? type : '$type · $preview',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (drawing) const Icon(Icons.draw_outlined),
        const Icon(Icons.chevron_right),
      ],
    ),
    onTap: onTap,
  );
}
