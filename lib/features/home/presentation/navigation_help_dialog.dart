import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_localizations.dart';

class NavigationHelpDialog extends StatelessWidget {
  const NavigationHelpDialog({required this.destination, super.key});

  final String destination;

  static const _drawingIcons = [
    (Icons.draw_outlined, 'createDrawing'),
    (Icons.edit_outlined, 'editDrawing'),
    (Icons.auto_fix_high, 'eraseDrawing'),
    (Icons.edit, 'penDrawing'),
    (Icons.undo, 'undoDrawing'),
    (Icons.delete_outline, 'clearDrawing'),
  ];

  static const _navigationIcons = [
    (Icons.home_outlined, 'home'),
    (Icons.sticky_note_2_outlined, 'notes'),
    (Icons.calendar_month_outlined, 'calendar'),
    (Icons.check_circle_outline, 'daily'),
    (Icons.menu_book_outlined, 'journal'),
    (Icons.track_changes, 'goals'),
    (Icons.timer_outlined, 'focus'),
    (Icons.settings_outlined, 'settings'),
    (Icons.info_outline, 'information'),
  ];

  static const _controls = {
    'notes': [
      (Icons.add, 'addNote'),
      (Icons.search, 'search'),
      (Icons.date_range, 'filter'),
      (Icons.clear, 'clearFilters'),
      (Icons.draw_outlined, 'drawing'),
    ],
    'calendar': [
      (Icons.today_outlined, 'today'),
      (Icons.chevron_left, 'previous'),
      (Icons.chevron_right, 'next'),
      (Icons.circle, 'calendarDots'),
      (Icons.add, 'calendarNote'),
      (Icons.menu_book_outlined, 'calendarWrite'),
      (Icons.track_changes, 'goalDate'),
    ],
    'daily': [
      (Icons.add, 'addDaily'),
      (Icons.check_circle_outline, 'complete'),
      (Icons.edit_outlined, 'editDaily'),
      (Icons.access_time, 'time'),
      (Icons.notifications_active_outlined, 'reminder'),
      (Icons.notifications_off_outlined, 'noReminder'),
    ],
    'journal': [(Icons.add, 'addEntry'), (Icons.draw_outlined, 'drawing')],
    'goals': [
      (Icons.checklist, 'goalChecklist'),
      (Icons.pin_outlined, 'goalCounter'),
      (Icons.add, 'goalAdvance'),
      (Icons.remove, 'goalDecrease'),
    ],
    'focus': [
      (Icons.info_outline, 'focusHowTo'),
      (Icons.history, 'focusHistory'),
      (Icons.tune, 'focusSettings'),
      (Icons.settings_outlined, 'focusActivities'),
      (Icons.restart_alt, 'focusReset'),
      (Icons.stop, 'focusStop'),
    ],
    'home': [(Icons.arrow_outward_rounded, 'shortcut')],
  };

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      scrollable: true,
      title: Text(strings.help('title')),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _HelpSection(
              title: strings.navigation(destination),
              icons: _controls[destination] ?? const [],
              initiallyExpanded: true,
            ),
            _HelpSection(
              title: strings.help('drawingTools'),
              icons: _drawingIcons,
            ),
            for (final section in _controls.entries)
              if (section.key != destination)
                _HelpSection(
                  title: strings.navigation(section.key),
                  icons: section.value,
                ),
            _HelpSection(
              title: strings.help('navigation'),
              icons: _navigationIcons,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.help('close')),
        ),
      ],
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection({
    required this.title,
    required this.icons,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<(IconData, String)> icons;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ExpansionTile(
      title: Text(title),
      tilePadding: EdgeInsets.zero,
      expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
      initiallyExpanded: initiallyExpanded,
      children: [
        for (final (icon, key) in icons)
          _HelpRow(icon: icon, description: strings.help(key)),
      ],
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow({required this.icon, required this.description});

  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(description)),
      ],
    ),
  );
}
