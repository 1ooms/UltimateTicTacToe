import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/ultimate_board.dart';
import 'package:ultimate_tic_tac_toe/widgets/dialogs/player_setup/player_setup.dart';

import '../models/enum/ai_difficulty.dart';
import '../models/player_config.dart';
import '../models/player_setup_result.dart';
import '../widgets/ads/banner_ad_widget.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, required this.gameMode});

  final GameMode gameMode;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late PlayerConfig player1;
  late PlayerConfig player2;
  late bool player1Starts;
  AIDifficulty? aiDifficulty;
  bool gameStarted = false;

  final GlobalKey<BoardState> _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {
      _showPlayerSetupDialog(context);
    });
  }

  Future<void> _showPlayerSetupDialog(BuildContext context) async {
    final result = await showDialog<PlayerSetupResult>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) =>
              PlayerSetup(gameMode: widget.gameMode, gameStarted: gameStarted),
    );

    if (result != null) {
      setState(() {
        player1 = result.player1;
        player2 = result.player2;
        player1Starts = result.player1Starts;
        aiDifficulty = result.aiDifficulty;
        gameStarted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.gameMode.name.capitalize()} Game',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showPlayerSetupDialog(context);
            },
            icon: const Icon(Icons.palette),
          ),
          IconButton(
            onPressed: () {
              _boardKey.currentState?.performUndo();
            },
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 24),
                gameStarted
                    ? Board(
                      key: _boardKey,
                      player1: player1,
                      player2: player2,
                      player1Starts: player1Starts,
                      playingAgainstAI:
                          widget.gameMode == GameMode.computer ? true : false,
                      aiDifficulty: aiDifficulty,
                    )
                    : const Text("Waiting for game to start..."),
              ],
            ),
            BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}
