import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/utils/ad_controller.dart';
import 'package:ultimate_tic_tac_toe/utils/audio_controller.dart';

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

  final audioController = AudioController();
  late bool soundSetting;

  final adController = AdController();

  void getSoundSetting() {
    soundSetting = audioController.soundSetting;
  }

  void saveSoundSettings() {
    audioController.toggleSound();
  }

  @override
  void initState() {
    super.initState();
    themeMode = widget.themeMode;
    soundSetting = audioController.soundSetting;
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          children: [
            Text('Appearance', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            RadioGroup<ThemeMode>(
              groupValue: themeMode,
              onChanged: (ThemeMode? value) {
                widget.onChangeThemeMode(value!);
                setState(() {
                  themeMode = value;
                });
              },
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Light theme'),
                    leading: Radio<ThemeMode>(value: ThemeMode.light),
                  ),
                  ListTile(
                    title: const Text('Dark theme'),
                    leading: Radio<ThemeMode>(value: ThemeMode.dark),
                  ),
                  ListTile(
                    title: const Text('Use device theme'),
                    leading: Radio<ThemeMode>(value: ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Sound', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            RadioGroup<bool>(
              groupValue: soundSetting,
              onChanged: (bool? value) {
                setState(() {
                  soundSetting = value!;
                  saveSoundSettings();
                });
              },
              child: Column(
                children: [
                  ListTile(
                    title: const Text('On'),
                    leading: Radio<bool>(value: true),
                  ),
                  ListTile(
                    title: const Text('Off'),
                    leading: Radio<bool>(value: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Ads', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              'Please consider leaving ads on to support the app. We will never show ads that interrupt gameplay.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<bool>(
              valueListenable: adController.adSettingNotifier,
              builder: (context, adSettingValue, child) {
                return RadioGroup<bool>(
                  groupValue: adSettingValue,
                  onChanged: (bool? value) {
                    adController.setAdSetting(value!);
                  },
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('On'),
                        leading: Radio<bool>(value: true),
                      ),
                      ListTile(
                        title: const Text('Off'),
                        leading: Radio<bool>(value: false),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
