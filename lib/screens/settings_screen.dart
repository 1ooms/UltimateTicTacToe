import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.onChangeThemeMode,
    required this.themeMode,
  });
  final Function(ThemeMode) onChangeThemeMode;
  final ThemeMode themeMode;

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late ThemeMode themeMode;

  @override
  void initState() {
    super.initState();
    themeMode = widget.themeMode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text(
              'Appearance',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Light theme'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.light,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  widget.onChangeThemeMode(value!);
                  setState(() {
                    themeMode = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Dark theme'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  widget.onChangeThemeMode(value!);
                  setState(() {
                    themeMode = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Use device theme'),
              leading: Radio<ThemeMode>(
                value: ThemeMode.system,
                groupValue: themeMode,
                onChanged: (ThemeMode? value) {
                  widget.onChangeThemeMode(value!);
                  setState(() {
                    themeMode = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
