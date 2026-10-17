import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

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
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            strings.settings('title'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(strings.settings('languageDescription')),
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
