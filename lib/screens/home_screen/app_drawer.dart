import 'package:flutter/material.dart';

import '../../controllers/stats_controller.dart';
import '../how_to_play_screen/how_to_play_screen.dart';
import '../settings_screen/settings_screen.dart';
import '../statistics_screen/statistics_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onChangeThemeMode,
    required this.themeMode,
  });

  final Function(ThemeMode) onChangeThemeMode;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDarkMode = theme.brightness == Brightness.dark;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final image = AssetImage(
      isDarkMode ? 'assets/icon/icon_dark.png' : 'assets/icon/icon.png',
    );
    final visualDensity =
        isLandscape ? VisualDensity.compact : VisualDensity.standard;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: image,
                fit: BoxFit.cover,
                opacity: 0.9,
                alignment: Alignment.bottomCenter,
              ),
              color: colorScheme.surface,
            ),
            child: const SizedBox(),
          ),
          ListTile(
            dense: isLandscape,
            visualDensity: visualDensity,
            leading: const Icon(Icons.play_circle),
            title: const Text('Play'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            dense: isLandscape,
            visualDensity: visualDensity,
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const StatisticsScreen()),
              );
            },
          ),
          ListTile(
            dense: isLandscape,
            visualDensity: visualDensity,
            leading: const Icon(Icons.emoji_events_outlined),
            title: const Text('Achievements'),
            onTap: () {
              Navigator.pop(context);
              StatsController().showAchievements();
            },
          ),
          ListTile(
            dense: isLandscape,
            visualDensity: visualDensity,
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (ctx) => SettingsScreen(
                        onChangeThemeMode: onChangeThemeMode,
                        themeMode: themeMode,
                      ),
                ),
              );
            },
          ),
          ListTile(
            dense: isLandscape,
            visualDensity: visualDensity,
            leading: const Icon(Icons.help),
            title: const Text('How to play'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const HowToPlayScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
