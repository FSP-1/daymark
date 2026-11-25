import 'package:material_ui/material_ui.dart';

import '../../../core/localization/app_localizations.dart';
import '../domain/focus_session.dart';
import '../domain/focus_statistics.dart';
import 'focus_view_model.dart';

class FocusSettingsPage extends StatefulWidget {
  const FocusSettingsPage({required this.model, super.key});
  final FocusViewModel model;

  static void open(BuildContext context, FocusViewModel model) =>
      Navigator.push<void>(
        context,
        MaterialPageRoute(builder: (_) => FocusSettingsPage(model: model)),
      );

  @override
  State<FocusSettingsPage> createState() => _FocusSettingsPageState();
}

class _FocusSettingsPageState extends State<FocusSettingsPage> {
  late FocusSettings _settings = widget.model.settings;
  var _saving = false;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.focus('settings')),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () async {
                    setState(() => _saving = true);
                    final saved = await widget.model.updateSettings(_settings);
                    if (!context.mounted) return;
                    if (!saved) {
                      setState(() => _saving = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(strings.focus('error'))),
                      );
                    } else {
                      Navigator.pop(context);
                    }
                  },
            child: Text(strings.focus('save')),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _duration(
              strings.focus('focus'),
              _settings.focus,
              120,
              (value) => _settings.copyWith(focus: value),
            ),
            _duration(
              strings.focus('shortBreak'),
              _settings.shortBreak,
              30,
              (value) => _settings.copyWith(shortBreak: value),
            ),
            _duration(
              strings.focus('longBreak'),
              _settings.longBreak,
              60,
              (value) => _settings.copyWith(longBreak: value),
            ),
            ListTile(
              title: Text(strings.focus('perCycle')),
              trailing: DropdownButton<int>(
                value: _settings.cycle,
                items: [
                  for (var index = 2; index <= 8; index++)
                    DropdownMenuItem(value: index, child: Text('$index')),
                ],
                onChanged: (value) => setState(
                  () => _settings = _settings.copyWith(cycle: value),
                ),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: Text(strings.focus('autoBreak')),
              value: _settings.autoBreak,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(autoBreak: value),
              ),
            ),
            SwitchListTile(
              title: Text(strings.focus('autoFocus')),
              value: _settings.autoFocus,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(autoFocus: value),
              ),
            ),
            SwitchListTile(
              title: Text(strings.focus('sound')),
              value: _settings.sound,
              onChanged: (value) =>
                  setState(() => _settings = _settings.copyWith(sound: value)),
            ),
            SwitchListTile(
              title: Text(strings.focus('vibration')),
              value: _settings.vibration,
              onChanged: (value) => setState(
                () => _settings = _settings.copyWith(vibration: value),
              ),
            ),
            const Divider(),
            ListTile(
              title: Text(strings.focus('cycleDuration')),
              subtitle: Text(
                focusDurationText(
                  Duration(
                    minutes:
                        _settings.focus * _settings.cycle +
                        _settings.shortBreak * (_settings.cycle - 1) +
                        _settings.longBreak,
                  ),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () =>
                  setState(() => _settings = const FocusSettings()),
              child: Text(strings.focus('defaults')),
            ),
          ],
        ),
      ),
    );
  }

  Widget _duration(
    String title,
    int minutes,
    int max,
    FocusSettings Function(int) update,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      ListTile(title: Text(title), trailing: Text('$minutes min')),
      Slider(
        min: 1,
        max: max.toDouble(),
        divisions: max - 1,
        value: minutes.toDouble(),
        label: '$minutes min',
        onChanged: (value) => setState(() => _settings = update(value.round())),
      ),
    ],
  );
}
