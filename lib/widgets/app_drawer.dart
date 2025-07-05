import 'package:flutter/material.dart';

import '../screens/how_to_play_screen.dart';
import '../screens/settings_screen.dart';

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
    final textTheme = theme.textTheme;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            child: Text(
              'Ultimate Tic Tac Toe',
              style: textTheme.titleLarge?.copyWith(
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
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
        ],
      ),
    );
  }
}
