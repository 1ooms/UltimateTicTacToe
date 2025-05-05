import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/app_drawer.dart';
import 'package:ultimate_tic_tac_toe/widgets/game_mode_card.dart';

import '../models/player_config.dart';
import 'game_modes/computer_game_screen.dart';
import 'game_modes/local_game_screen.dart';
import 'game_modes/online_game_screen.dart';

class HomeScreen extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                              (ctx) => LocalGameScreen(
                                player1: PlayerConfig(
                                  shape: PlayerShape.circle,
                                  color: Colors.blue,
                                ),
                                player2: PlayerConfig(
                                  shape: PlayerShape.cross,
                                  color: Colors.red,
                                ),
                                player1Starts: true,
                              ),
                        ),
                      );
                    },
                  ),
                  GameModeCard(
                    title: 'Online',
                    icon: Icons.public,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const OnlineGameScreen(),
                        ),
                      );
                    },
                  ),
                  GameModeCard(
                    title: 'Computer',
                    icon: Icons.smart_toy,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => const ComputerGameScreen(),
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
    );
  }
}
