import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/app_drawer.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/game_mode_card.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/welcome_dialog.dart';

import '../../widgets/ads/banner_ad_widget.dart';
import '../game_screen/game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.onChangeThemeMode,
    required this.themeMode,
    required this.showWelcomeDialog,
  });

  final Function(ThemeMode) onChangeThemeMode;
  final ThemeMode themeMode;
  final bool showWelcomeDialog;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {
      if (widget.showWelcomeDialog) {
        showDialog(context: context, builder: (ctx) => WelcomeDialog());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    Widget buildGameModeCards() {
      final double cardWidth = 220.0;

      final cardsList = ListView(
        shrinkWrap: true,
        scrollDirection: isLandscape ? Axis.horizontal : Axis.vertical,
        children: [
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: isLandscape ? 'Local\ngame' : 'Local game',
              icon: Icons.group,
              gradient: CardGradients.local(isDarkMode),
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
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: isLandscape ? 'Online\ngame' : 'Online game',
              icon: Icons.public,
              gradient: CardGradients.online(isDarkMode),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => GameScreen(gameMode: GameMode.online),
                  ),
                );
                // showCustomSnackBar(
                //   context,
                //   Text(
                //     'Coming soon!',
                //     style: Theme.of(context).textTheme.titleLarge?.copyWith(
                //       color: Theme.of(context).colorScheme.onInverseSurface,
                //     ),
                //   ),
                // );
              },
            ),
          ),
          SizedBox(
            width: isLandscape ? cardWidth : null,
            child: GameModeCard(
              title: isLandscape ? 'Bot\ngame' : 'Bot game',
              icon: Icons.smart_toy,
              gradient: CardGradients.bot(isDarkMode),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => GameScreen(gameMode: GameMode.bot),
                  ),
                );
              },
            ),
          ),
        ],
      );

      if (isLandscape) {
        return Center(child: cardsList);
      }
      return cardsList;
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Ultimate Tic Tac Toe'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: AppDrawer(
        onChangeThemeMode: widget.onChangeThemeMode,
        themeMode: widget.themeMode,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(children: [Expanded(child: buildGameModeCards())]),
        ),
      ),
      bottomNavigationBar: BannerAdWidget(),
    );
  }
}
