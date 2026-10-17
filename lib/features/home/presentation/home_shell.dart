import 'package:flutter/material.dart';

import '../../sticky_notes/presentation/sticky_notes_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({required this.stickyNotesPage, super.key});

  final StickyNotesPage stickyNotesPage;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  var _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeOverview(onOpenNotes: () => setState(() => _selectedIndex = 1)),
      widget.stickyNotesPage,
      const _FeaturePlaceholder(
        title: 'Tasks',
        icon: Icons.check_circle_outline,
      ),
      const _FeaturePlaceholder(
        title: 'Important dates',
        icon: Icons.event_outlined,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) =>
            setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(
            key: Key('notes-nav'),
            icon: Icon(Icons.sticky_note_2_outlined),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_outlined),
            label: 'Dates',
          ),
        ],
      ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({required this.onOpenNotes});

  final VoidCallback onOpenNotes;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xfff4efff), Color(0xfffff8ec)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            AppBar(
              title: const Text('Daymark'),
              backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Make space for what matters.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: const Color(0xff39275f),
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your personal organizer, ready to work offline.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 28),
                    Card(
                      color: const Color(0xffffe9a8),
                      elevation: 5,
                      child: ListTile(
                        leading: const Icon(Icons.sticky_note_2_outlined),
                        title: const Text('Sticky Notes'),
                        subtitle: const Text(
                          'Capture an idea or draw a thought.',
                        ),
                        trailing: const Icon(Icons.arrow_forward),
                        onTap: onOpenNotes,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      color: const Color(0xffdcecff),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.auto_awesome_outlined),
                        title: const Text('More features are coming soon'),
                        subtitle: const Text(
                          'Tasks and important dates will live here.',
                        ),
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
    return SafeArea(
      child: Column(
        children: [
          AppBar(title: Text(title)),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 56),
                  const SizedBox(height: 16),
                  Text('$title is coming soon.'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
