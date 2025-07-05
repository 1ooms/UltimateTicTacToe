import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/widgets/app_drawer.dart';
import 'package:ultimate_tic_tac_toe/widgets/game_mode_card.dart';

import '../widgets/ads/banner_ad_widget.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({
    super.key,
    required this.onChangeThemeMode,
    required this.themeMode,
  });

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Function(ThemeMode) onChangeThemeMode;
  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Play'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: AppDrawer(
        onChangeThemeMode: onChangeThemeMode,
        themeMode: themeMode,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Game', style: textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          GameModeCard(
                            title: 'Local',
                            icon: Icons.group,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (ctx) =>
                                          GameScreen(gameMode: GameMode.local),
                                ),
                              );
                            },
                          ),
                          GameModeCard(
                            title: 'Online',
                            icon: Icons.public,
                            onTap: () {
                              // Navigator.push(...)
                            },
                          ),
                          GameModeCard(
                            title: 'Computer',
                            icon: Icons.smart_toy,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (ctx) => GameScreen(
                                        gameMode: GameMode.computer,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: BannerAdWidget(),
            ),
          ],
        ),
      ),
    );
  }
}
