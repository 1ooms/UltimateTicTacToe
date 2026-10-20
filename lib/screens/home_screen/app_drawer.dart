import 'package:flutter/material.dart';

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

    AssetImage image;
    if (isDarkMode) {
      image = AssetImage('assets/icon/icon_dark.png');
    } else {
      image = AssetImage('assets/icon/icon.png');
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
                image: DecorationImage(image: image, fit: BoxFit.cover, opacity: 0.9, alignment: Alignment.bottomCenter),
                color: colorScheme.surface),
            child: SizedBox(),
          ),
          ListTile(
            leading: Icon(Icons.play_circle),
            title: Text('Play'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Statistics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => const StatisticsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
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
            leading: Icon(Icons.help),
            title: Text('How to play'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => HowToPlayScreen()),
              );
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.help),
          //   title: Text('Test screen'),
          //   onTap: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(builder: (ctx) => IntroScreen()),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }
}
