import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_styles.dart';
import '../../../core/theme/theme_presets.dart';
import 'theme_view_model.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final Locale locale;
  final ValueChanged<Locale> onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = context.watch<ThemeViewModel>();
    final styleNames = {
      AppStyle.soft: strings.settings('soft'),
      AppStyle.playful: strings.settings('playful'),
      AppStyle.minimal: strings.settings('minimal'),
    };
    final styleDescriptions = {
      AppStyle.soft: strings.settings('softDescription'),
      AppStyle.playful: strings.settings('playfulDescription'),
      AppStyle.minimal: strings.settings('minimalDescription'),
    };
    final paletteNames = {
      AppPalette.vanilla: strings.settings('vanilla'),
      AppPalette.sage: strings.settings('sage'),
      AppPalette.rose: strings.settings('rose'),
      AppPalette.sky: strings.settings('sky'),
      AppPalette.lavender: strings.settings('lavender'),
      AppPalette.peach: strings.settings('peach'),
    };
    return SafeArea(
      child: ListView(
        key: const Key('settings-scroll'),
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            strings.settings('title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(strings.settings('languageDescription')),
          const SizedBox(height: 24),
          Text(
            strings.settings('styleTitle'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<AppStyle>(
            key: const Key('style-selector'),
            initialValue: theme.style,
            decoration: InputDecoration(
              labelText: strings.settings('styleTitle'),
            ),
            items: AppStyle.values
                .map(
                  (style) => DropdownMenuItem(
                    value: style,
                    child: Text(styleNames[style]!),
                  ),
                )
                .toList(),
            onChanged: (style) {
              if (style != null) theme.setStyle(style);
            },
          ),
          const SizedBox(height: 8),
          Text(
            styleDescriptions[theme.style]!,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Text(
            strings.settings('paletteTitle'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppPalette.values
                .map(
                  (palette) => _PaletteOption(
                    label: paletteNames[palette]!,
                    palette: palette,
                    selected: theme.palette == palette,
                    onTap: () => theme.setPalette(palette),
                  ),
                )
                .toList(),
          ),
          OutlinedButton.icon(
            onPressed: () => theme.reset(),
            icon: const Icon(Icons.restart_alt),
            label: Text(strings.settings('reset')),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: locale.languageCode,
                decoration: InputDecoration(labelText: strings.language),
                items: [
                  DropdownMenuItem(value: 'es', child: Text(strings.spanish)),
                  DropdownMenuItem(value: 'en', child: Text(strings.english)),
                ],
                onChanged: (value) {
                  if (value != null) onLocaleChanged(Locale(value));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaletteOption extends StatelessWidget {
  const _PaletteOption({
    required this.label,
    required this.palette,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final AppPalette palette;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = paletteTokens(palette);
    return Semantics(
      label: label,
      selected: selected,
      button: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          key: Key('palette-${palette.name}'),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 76,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : colors.border,
                width: selected ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _Swatch(color: colors.primary),
                _Swatch(color: colors.accent),
                _Swatch(color: colors.secondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) =>
      CircleAvatar(radius: 9, backgroundColor: color);
}
