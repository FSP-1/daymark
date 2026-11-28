import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/feature_id.dart';
import '../../../core/navigation/feature_registry.dart';
import '../../../core/navigation/navigation_view_model.dart';
import '../../calendar/presentation/calendar_page.dart';
import '../../daily/presentation/daily_page.dart';
import '../../goals/presentation/goals_page.dart';
import '../../focus/domain/focus_session.dart';
import '../../focus/presentation/focus_page.dart';
import '../../focus/presentation/focus_view_model.dart';
import '../../journal/presentation/journal_page.dart';
import '../../settings/presentation/settings_page.dart';
import '../../sticky_notes/presentation/sticky_notes_page.dart';
import 'home_feature_grid.dart';
import 'navigation_help_dialog.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final _visited = {FeatureId.home};
  late final FeatureRegistry _registry = FeatureRegistry([
    FeatureDefinition(
      FeatureId.home,
      Icons.home_outlined,
      Icons.home,
      (_) => _HomeOverview(registry: _registry, onOpen: _openFeature),
    ),
    FeatureDefinition(
      FeatureId.journal,
      Icons.menu_book_outlined,
      Icons.menu_book,
      (_) => const JournalPage(showAppBar: false),
      description: (strings) => strings.journal('subtitle'),
    ),
    FeatureDefinition(
      FeatureId.notes,
      Icons.sticky_note_2_outlined,
      Icons.sticky_note_2,
      (_) => const StickyNotesPage(showAppBar: false),
      description: (strings) => strings.home('stickyNotesDescription'),
    ),
    FeatureDefinition(
      FeatureId.daily,
      Icons.check_circle_outline,
      Icons.check_circle,
      (_) => DailyPage(
        showTitle: false,
        onOpenGoals: () => _openFeature(FeatureId.goals),
      ),
      description: (strings) => strings.home('dailyDescription'),
    ),
    FeatureDefinition(
      FeatureId.calendar,
      Icons.calendar_month_outlined,
      Icons.calendar_month,
      (_) => const CalendarPage(showTitle: false),
      description: (strings) => strings.calendar('description'),
    ),
    FeatureDefinition(
      FeatureId.goals,
      Icons.track_changes,
      Icons.track_changes,
      (_) => const GoalsPage(),
      description: (strings) => strings.goals('subtitle'),
    ),
    FeatureDefinition(
      FeatureId.focus,
      Icons.timer_outlined,
      Icons.timer,
      (_) => const FocusPage(),
      description: (strings) => strings.focus('subtitle'),
    ),
  ]);

  void _openFeature(FeatureId id) {
    final model = context.read<NavigationViewModel>();
    if (model.destinations.contains(id) &&
        ModalRoute.of(context)?.isCurrent == true) {
      model.select(id);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (routeContext) => Scaffold(
            appBar: _appBar(routeContext, id),
            body: Builder(builder: _registry[id].builder),
          ),
        ),
      );
    }
  }

  void _openSettings(BuildContext routeContext) {
    Navigator.of(routeContext).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(),
          body: SettingsPage(
            locale: widget.locale,
            onLocaleChanged: widget.onLocaleChanged,
            registry: _registry,
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context, FeatureId id) {
    final strings = AppLocalizations.of(context);
    return AppBar(
      title: Text(switch (id) {
        FeatureId.home => strings.appName,
        FeatureId.notes => strings.notes('title'),
        _ => _registry[id].label(strings),
      }, key: id == FeatureId.daily ? const Key('daily-title') : null),
      actions: [
        IconButton(
          key: const Key('settings-action'),
          tooltip: strings.navigation('settings'),
          onPressed: () => _openSettings(context),
          icon: const Icon(Icons.settings_outlined),
        ),
        IconButton(
          key: const Key('information-action'),
          tooltip: strings.help('title'),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (_) => NavigationHelpDialog(destination: id.name),
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NavigationViewModel>();
    final strings = AppLocalizations.of(context);
    final destinations = model.destinations;
    final selected = model.selected;
    _visited.add(selected);

    return Scaffold(
      appBar: _appBar(context, selected),
      body: IndexedStack(
        index: FeatureId.values.indexOf(selected),
        children: [
          for (final id in FeatureId.values)
            if (_visited.contains(id))
              Builder(key: ValueKey(id), builder: _registry[id].builder)
            else
              SizedBox.shrink(key: ValueKey(id)),
        ],
      ),
      bottomNavigationBar: destinations.length < 2
          ? null
          : NavigationBar(
              selectedIndex: destinations.indexOf(selected),
              onDestinationSelected: (index) =>
                  model.select(destinations[index]),
              destinations: [
                for (final id in destinations)
                  _registry[id].destination(strings),
              ],
            ),
    );
  }
}

class _HomeOverview extends StatelessWidget {
  const _HomeOverview({required this.registry, required this.onOpen});

  final FeatureRegistry registry;
  final ValueChanged<FeatureId> onOpen;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final backgrounds = [colors.tertiary, colors.secondary, colors.primary];

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              strings.appName,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              strings.home('welcome'),
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(strings.home('description'), style: theme.textTheme.bodyLarge),
            Selector<FocusViewModel, (FocusSession?, String)>(
              selector: (_, model) =>
                  (model.active, FocusClock.timeText(model.remaining)),
              builder: (context, snapshot, _) {
                final (active, remaining) = snapshot;
                if (active == null) return const SizedBox.shrink();
                return Card(
                  key: const Key('focus-active-banner'),
                  margin: const EdgeInsets.only(top: 14),
                  child: ListTile(
                    leading: Icon(
                      active.running
                          ? Icons.timer_outlined
                          : Icons.pause_circle_outline,
                      color: colors.primary,
                    ),
                    title: Text(
                      active.activityLabel ?? strings.focus(active.mode.name),
                    ),
                    subtitle: Text(
                      '$remaining · ${strings.focus(active.running ? 'running' : 'paused')}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => onOpen(FeatureId.focus),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            HomeFeatureGrid(
              features: [
                for (final (index, feature) in registry.homeFeatures.indexed)
                  HomeFeature(
                    key: Key('${feature.id.name}-fast-travel'),
                    title: feature.id == FeatureId.notes
                        ? strings.home('stickyNotes')
                        : feature.label(strings),
                    description: feature.description?.call(strings) ?? '',
                    icon: feature.icon,
                    backgroundColor: Color.alphaBlend(
                      backgrounds[index % backgrounds.length].withValues(
                        alpha: 0.20,
                      ),
                      colors.surface,
                    ),
                    foregroundColor: colors.onSurface,
                    onTap: () => onOpen(feature.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
