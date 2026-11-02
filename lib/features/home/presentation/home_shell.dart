import 'package:flutter/material.dart';

import '../../sticky_notes/presentation/sticky_notes_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../../core/localization/app_localizations.dart';
import '../../daily/presentation/daily_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.stickyNotesPage,
    required this.locale,
    required this.onLocaleChanged,
    required this.dailyPage,
    super.key,
  });

  final StickyNotesPage stickyNotesPage;
  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;
  final DailyPage dailyPage;

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
      ),
      widget.stickyNotesPage,
      widget.dailyPage,
      _FeaturePlaceholder(title: 'dates', icon: Icons.event_outlined),
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
            icon: Icon(Icons.event_outlined),
            label: strings.navigation('dates'),
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
  const _HomeOverview({required this.onOpenNotes, required this.onOpenDaily});

  final VoidCallback onOpenNotes;
  final VoidCallback onOpenDaily;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
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
                    Card(
                      color: colors.secondaryContainer,
                      elevation: 5,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(22),
                        onTap: onOpenNotes,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      strings.home('stickyNotes'),
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    Text(
                                      strings.home('stickyNotesDescription'),
                                    ),
                                  ],
                                ),
                              ),
                              Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Transform.rotate(
                                    angle: -0.12,
                                    child: Icon(
                                      Icons.sticky_note_2,
                                      size: 54,
                                      color: colors.tertiaryContainer,
                                    ),
                                  ),
                                  Positioned(
                                    right: -6,
                                    bottom: -4,
                                    child: Transform.rotate(
                                      angle: 0.12,
                                      child: Icon(
                                        Icons.edit,
                                        size: 24,
                                        color: colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: colors.primaryContainer,
                      elevation: 3,
                      child: ListTile(
                        key: const Key('daily-fast-travel'),
                        leading: const Icon(Icons.check_circle_outline),
                        title: Text(strings.daily('title')),
                        subtitle: Text(strings.daily('emptyDescription')),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: onOpenDaily,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: colors.surfaceContainerHighest,
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.auto_awesome_outlined),
                        title: Text(strings.home('growing')),
                        subtitle: Text(strings.home('comingSoon')),
                      ),
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

class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: Text(strings.navigation(title))),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56),
                  const SizedBox(height: 16),
                  Text(strings.home('comingSoon')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
