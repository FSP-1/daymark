import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/feature_id.dart';
import '../../../core/navigation/feature_registry.dart';
import '../../../core/navigation/navigation_view_model.dart';

class NavigationSettingsPage extends StatelessWidget {
  const NavigationSettingsPage({required this.registry, super.key});

  final FeatureRegistry registry;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NavigationViewModel>();
    final strings = AppLocalizations.of(context);
    final pinned = model.pinned;
    final available = registry.homeFeatures.map((feature) => feature.id);
    final full = pinned.length == NavigationViewModel.maxOptional;
    return Scaffold(
      appBar: AppBar(title: Text(strings.navSettings('title'))),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(strings.navSettings('description')),
            const SizedBox(height: 12),
            Text(
              '${strings.navSettings('selected')} ${pinned.length} / ${NavigationViewModel.maxOptional}',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: pinned.length / NavigationViewModel.maxOptional,
            ),
            ListTile(
              leading: Icon(registry[FeatureId.home].icon),
              title: Text(registry[FeatureId.home].label(strings)),
              subtitle: Text(strings.navSettings('always')),
              trailing: const Icon(Icons.lock_outline),
            ),
            for (final id in [
              ...pinned,
              ...available.where((id) => !pinned.contains(id)),
            ])
              _DestinationTile(
                key: ValueKey(id),
                definition: registry[id],
                pinned: pinned.contains(id),
                full: full,
                up: pinned.indexOf(id) > 0,
                down:
                    pinned.contains(id) &&
                    pinned.indexOf(id) < pinned.length - 1,
                model: model,
              ),
            if (full)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(strings.navSettings('limit')),
              ),
            if (model.failed)
              Text(
                strings.navSettings('error'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            const SizedBox(height: 16),
            Text(
              strings.navSettings('preview'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (model.destinations.length == 1)
              Text(strings.navSettings('onlyHome'))
            else
              IgnorePointer(
                child: NavigationBar(
                  key: const Key('navigation-preview'),
                  selectedIndex: 0,
                  destinations: [
                    for (final id in model.destinations)
                      NavigationDestination(
                        icon: Icon(registry[id].icon),
                        label: registry[id].label(strings),
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            OutlinedButton(
              key: const Key('navigation-defaults'),
              onPressed: model.restoreDefaults,
              child: Text(strings.navSettings('restore')),
            ),
          ],
        ),
      ),
    );
  }
}

class _DestinationTile extends StatelessWidget {
  const _DestinationTile({
    required this.definition,
    required this.pinned,
    required this.full,
    required this.up,
    required this.down,
    required this.model,
    super.key,
  });

  final FeatureDefinition definition;
  final bool pinned, full, up, down;
  final NavigationViewModel model;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final id = definition.id;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          children: [
            Expanded(
              child: SwitchListTile(
                key: Key('pin-${id.name}'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                secondary: Icon(definition.icon),
                title: Text(definition.label(strings)),
                value: pinned,
                onChanged: (!pinned && full) || model.loading
                    ? null
                    : (value) => model.setPinned(id, value),
              ),
            ),
            if (pinned) ...[
              IconButton(
                key: Key('move-up-${id.name}'),
                tooltip: strings.navSettings('up'),
                onPressed: up ? () => model.move(id, -1) : null,
                icon: const Icon(Icons.arrow_upward),
              ),
              IconButton(
                tooltip: strings.navSettings('down'),
                onPressed: down ? () => model.move(id, 1) : null,
                icon: const Icon(Icons.arrow_downward),
              ),
            ],
          ],
        ),
        const Divider(height: 1),
      ],
    );
  }
}
