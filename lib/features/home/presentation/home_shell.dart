import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../sticky_notes/presentation/sticky_notes_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../settings/presentation/theme_view_model.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../../core/localization/app_localizations.dart';
import '../../daily/presentation/daily_page.dart';
import '../../journal/presentation/journal_page.dart';
import 'home_feature_grid.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.stickyNotesPage,
    required this.locale,
    required this.onLocaleChanged,
    required this.dailyPage,
    required this.journalPage,
    super.key,
  });

  final StickyNotesPage stickyNotesPage;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final DailyPage dailyPage;
  final JournalPage journalPage;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

enum _HomeDestination { home, notes, calendar, daily, journal }

class _HomeShellState extends State<HomeShell> {
  var _destination = _HomeDestination.home;
  var _calendarVisited = false;

  void _select(_HomeDestination destination) {
    setState(() {
      _destination = destination;
      if (destination == _HomeDestination.calendar) _calendarVisited = true;
    });
  }

  void _openSettings() {
    final theme = context.read<ThemeViewModel>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChangeNotifierProvider.value(
          value: theme,
          child: Scaffold(
            appBar: AppBar(),
            body: SettingsPage(
              locale: widget.locale,
              onLocaleChanged: widget.onLocaleChanged,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeOverview(
        onOpenNotes: () => _select(_HomeDestination.notes),
        onOpenDaily: () => _select(_HomeDestination.daily),
        onOpenCalendar: () => _select(_HomeDestination.calendar),
        onOpenJournal: () => _select(_HomeDestination.journal),
        onOpenSettings: _openSettings,
      ),
      widget.stickyNotesPage,
      if (_calendarVisited) const CalendarPage() else const SizedBox.shrink(),
      widget.dailyPage,
      widget.journalPage,
    ];
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _destination.index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _destination.index,
        onDestinationSelected: (index) =>
            _select(_HomeDestination.values[index]),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: strings.navigation('home'),
          ),
          NavigationDestination(
            key: Key('notes-nav'),
            icon: Icon(Icons.sticky_note_2_outlined),
            label: strings.navigation('notes'),
          ),
          NavigationDestination(
            key: const Key('calendar-nav'),
            icon: const Icon(Icons.calendar_month_outlined),
            label: strings.navigation('calendar'),
          ),
          NavigationDestination(
            key: const Key('daily-nav'),
            icon: Icon(Icons.check_circle_outline),
            label: strings.navigation('daily'),
          ),
          NavigationDestination(
            key: const Key('journal-nav'),
            icon: Icon(Icons.menu_book_outlined),
            label: strings.navigation('journal'),
          ),
        ],
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({
    required this.onOpenNotes,
    required this.onOpenDaily,
    required this.onOpenCalendar,
    required this.onOpenJournal,
    required this.onOpenSettings,
  });

  final VoidCallback onOpenNotes;
  final VoidCallback onOpenDaily;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenJournal;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final featureNotes = Color.alphaBlend(
      colors.tertiary.withValues(alpha: 0.22),
      colors.surface,
    );
    final featureDaily = Color.alphaBlend(
      colors.secondary.withValues(alpha: 0.28),
      colors.surface,
    );
    final featureCalendar = Color.alphaBlend(
      colors.primary.withValues(alpha: 0.16),
      colors.surface,
    );
    final featureFuture = Color.alphaBlend(
      colors.tertiary.withValues(alpha: 0.12),
      colors.surface,
    );
    return SafeArea(
      child: DecoratedBox(
        decoration: BoxDecoration(color: colors.surface),
        child: Column(
          children: [
            AppBar(
              title: Text(strings.appName),
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                IconButton(
                  key: const Key('settings-action'),
                  tooltip: strings.navigation('settings'),
                  onPressed: onOpenSettings,
                  icon: const Icon(Icons.settings_outlined),
                ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          strings.appName,
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Text('☀', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      strings.home('welcome'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.home('description'),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    HomeFeatureGrid(
                      features: [
                        HomeFeature(
                          key: const Key('journal-fast-travel'),
                          title: strings.journal('title'),
                          description: strings.journal('subtitle'),
                          icon: Icons.menu_book_outlined,
                          backgroundColor: featureFuture,
                          foregroundColor: colors.onSurface,
                          onTap: onOpenJournal,
                        ),
                        HomeFeature(
                          title: strings.home('stickyNotes'),
                          description: strings.home('stickyNotesDescription'),
                          icon: Icons.sticky_note_2_outlined,
                          backgroundColor: featureNotes,
                          foregroundColor: colors.onSurface,
                          onTap: onOpenNotes,
                        ),
                        HomeFeature(
                          key: const Key('daily-fast-travel'),
                          title: strings.daily('title'),
                          description: strings.home('dailyDescription'),
                          icon: Icons.check_circle_outline,
                          backgroundColor: featureDaily,
                          foregroundColor: colors.onSurface,
                          onTap: onOpenDaily,
                        ),
                        HomeFeature(
                          key: const Key('calendar-fast-travel'),
                          title: strings.navigation('calendar'),
                          description: strings.calendar('description'),
                          icon: Icons.calendar_month_outlined,
                          backgroundColor: featureCalendar,
                          foregroundColor: colors.onSurface,
                          onTap: onOpenCalendar,
                        ),
                        HomeFeature(
                          title: strings.home('growing'),
                          description: strings.home('comingSoon'),
                          icon: Icons.auto_awesome_outlined,
                          backgroundColor: featureFuture,
                          foregroundColor: colors.onSurface,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
