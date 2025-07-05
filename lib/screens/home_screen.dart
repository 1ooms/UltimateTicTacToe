import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/widgets/app_drawer.dart';
import 'package:ultimate_tic_tac_toe/widgets/game_mode_card.dart';

import '../utils/ui_helpers.dart';
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
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    Widget buildGameModeCards() {
      final double cardWidth = 200.0;
      const double spacing = 16.0;

      return ListView(
        scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
        children: [
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: 'Local',
              icon: Icons.group,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => GameScreen(gameMode: GameMode.local),
                  ),
                );
              },
            ),
          ),
          if (isLandscape) const SizedBox(width: spacing),
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: 'Online',
              icon: Icons.public,
              onTap: () {
                showCustomSnackBar(
                  context,
                  Text(
                    'Coming soon!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onInverseSurface,
                    ),
                  ),
                );
              },
            ),
          ),
          if (isLandscape) const SizedBox(width: spacing),
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: 'Computer',
              icon: Icons.smart_toy,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => GameScreen(gameMode: GameMode.computer),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }

    Widget buildBodyContent() {
      if (isLandscape) {
        return Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Game', style: textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Expanded(child: buildGameModeCards()),
                  ],
                ),
              ),
            ),
            Container(
              width: 100.0,
              padding: const EdgeInsets.symmetric(
                vertical: 24.0,
                horizontal: 12.0,
              ),
              child: const Align(
                alignment: Alignment.center,
                child: BannerAdWidget(adSize: AdSize.largeBanner),
              ),
            ),
          ],
        );
      } else {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('New Game', style: textTheme.headlineMedium),
                    const SizedBox(height: 16),
                    Expanded(child: buildGameModeCards()),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: BannerAdWidget(),
            ),
          ],
        );
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Play'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: AppDrawer(
        onChangeThemeMode: onChangeThemeMode,
        themeMode: themeMode,
      ),
      body: SafeArea(child: buildBodyContent()),
    );
  }
}
