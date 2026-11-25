import 'package:material_ui/material_ui.dart';

import '../localization/app_localizations.dart';
import 'feature_id.dart';

class FeatureDefinition {
  const FeatureDefinition(
    this.id,
    this.icon,
    this.selectedIcon,
    this.builder, {
    this.description,
  });

  final FeatureId id;
  final IconData icon;
  final IconData selectedIcon;
  final WidgetBuilder builder;
  final String Function(AppLocalizations strings)? description;

  String label(AppLocalizations strings) => strings.navigation(id.name);

  NavigationDestination destination(AppLocalizations strings) =>
      NavigationDestination(
        key: Key('${id.name}-nav'),
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: label(strings),
      );
}

class FeatureRegistry {
  FeatureRegistry(Iterable<FeatureDefinition> definitions)
    : _definitions = {for (final item in definitions) item.id: item};

  final Map<FeatureId, FeatureDefinition> _definitions;

  FeatureDefinition operator [](FeatureId id) => _definitions[id]!;
  Iterable<FeatureDefinition> get homeFeatures =>
      _definitions.values.where((item) => item.id != FeatureId.home);
}
