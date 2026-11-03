import 'package:flutter/material.dart';

import '../../sticky_notes/presentation/sticky_notes_page.dart';
import '../../settings/presentation/settings_page.dart';
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

class _HomeShellState extends State<HomeShell> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeOverview(
        onOpenNotes: () => setState(() => _selectedIndex = 1),
        onOpenDaily: () => setState(() => _selectedIndex = 2),
        onOpenDates: () => setState(() => _selectedIndex = 3),
        onOpenJournal: () => setState(() => _selectedIndex = 3),
      ),
      widget.stickyNotesPage,
      widget.dailyPage,
      widget.journalPage,
      SettingsPage(
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
      ),
    ];
    final strings = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
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
            key: const Key('daily-nav'),
            icon: Icon(Icons.check_circle_outline),
            label: strings.navigation('daily'),
          ),
          NavigationDestination(
            key: const Key('journal-nav'),
            icon: Icon(Icons.menu_book_outlined),
            label: strings.navigation('journal'),
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            label: strings.navigation('settings'),
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
    required this.onOpenDates,
    required this.onOpenJournal,
  });

  final VoidCallback onOpenNotes;
  final VoidCallback onOpenDaily;
  final VoidCallback onOpenDates;
  final VoidCallback onOpenJournal;

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
    final featureDates = Color.alphaBlend(
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
                          title: strings.navigation('journal'),
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
                          title: strings.navigation('dates'),
                          description: strings.home('datesDescription'),
                          icon: Icons.event_outlined,
                          backgroundColor: featureDates,
                          foregroundColor: colors.onSurface,
                          onTap: onOpenDates,
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
