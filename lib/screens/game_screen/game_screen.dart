import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';

import '../../models/enum/ai_difficulty.dart';
import '../../models/enum/player.dart';
import '../../models/online_setup.dart';
import '../../models/player_config.dart';
import '../../models/game_setup.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'board/current_player_indicator.dart';
import 'board/game_state.dart';
import 'board/winner_indicator.dart';
import 'game_setup_dialogs/game_setup/game_setup_dialog.dart';
import 'game_setup_dialogs/online_setup/online_setup_dialog.dart';

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

  final GlobalKey<GameStateState> _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.gameMode == GameMode.online) {
      WidgetsBinding.instance.addPostFrameCallback((ctx) {
        _showOnlineSetupDialog(context);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((ctx) {
        _showGameSetupDialog(context);
      });
    }
  }

  Future<void> _showGameSetupDialog(BuildContext context) async {
    final result = await showDialog<GameSetup>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => GameSetupDialog(
            gameMode: widget.gameMode,
            gameStarted: gameStarted,
          ),
    );

    if (result != null) {
      setState(() {
        player1 = result.player1;
        player2 = result.player2;
        player1Starts = result.player1Starts;
        aiDifficulty = result.aiDifficulty;
        gameStarted = true;
      });

      _boardKey.currentState?.resetAndStartNewGame(result);
    }
  }

  Future<void> _showOnlineSetupDialog(BuildContext context) async {
    final result = await showDialog<OnlineSetup>(
      barrierDismissible: false,
      context: context,
      builder: (context) => OnlineSetupDialog(),
    );
  }

  Widget _buildGameLayout({
    required Widget boardWidget,
    required Player currentPlayer,
    required bool gameFinished,
    required Player? overallWinner,
    required bool aiThinking,
    required bool showPlayAgainButton,
  }) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final PlayerConfig p1 = player1;
    final PlayerConfig p2 = player2;
    final bool playingAgainstAI = widget.gameMode == GameMode.computer;

    Widget playerStatusIndicator =
        gameFinished
            ? WinnerIndicator(
              overallWinner: overallWinner,
              player1: p1,
              player2: p2,
              playingAgainstAI: playingAgainstAI,
            )
            : CurrentPlayerIndicator(
              currentPlayer: currentPlayer,
              player1: p1,
              player2: p2,
              playingAgainstAI: playingAgainstAI,
            );

    Widget playAgainButton = Visibility(
      visible: showPlayAgainButton,
      child: TextButton(
        onPressed: () {
          gameStarted = false;
          _showGameSetupDialog(context);
        },
        child: const Text("Play again"),
      ),
    );

    Widget aiThinkingIndicator = Visibility(
      visible: aiThinking,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "AI is thinking",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 25.0,
            width: 25.0,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );

    if (isLandscape) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final totalHeight = constraints.maxHeight;

          final desiredBoardWidth = min(totalWidth * 0.5, 500.0);
          final boardSize = min(desiredBoardWidth, totalHeight);

          final sidePanelWidth = (totalWidth - boardSize) / 2;

          return Row(
            children: [
              SizedBox(
                width: sidePanelWidth,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      playerStatusIndicator,
                      const SizedBox(height: 16),
                      playAgainButton,
                      aiThinkingIndicator,
                    ],
                  ),
                ),
              ),

              SizedBox(width: boardSize, height: boardSize, child: boardWidget),

              SizedBox(width: sidePanelWidth),
            ],
          );
        },
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  playerStatusIndicator,
                  const SizedBox(height: 16),
                  AspectRatio(aspectRatio: 1, child: boardWidget),
                  const SizedBox(height: 16),
                  playAgainButton,
                  aiThinkingIndicator,
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildBodyContent() {
      if (gameStarted) {
        return GameState(
          key: _boardKey,
          gameSetup: GameSetup(
            player1: player1,
            player2: player2,
            player1Starts: player1Starts,
            aiDifficulty: aiDifficulty,
          ),
          playingAgainstAI: widget.gameMode == GameMode.computer,
          onPlayAgain: () {
            gameStarted = false;
            _showGameSetupDialog(context);
          },
          layoutBuilder:
              ({
                required Widget boardWidget,
                required Player currentPlayer,
                required bool gameFinished,
                required Player? overallWinner,
                required bool aiThinking,
                required bool showPlayAgainButton,
              }) => _buildGameLayout(
                boardWidget: boardWidget,
                currentPlayer: currentPlayer,
                gameFinished: gameFinished,
                overallWinner: overallWinner,
                aiThinking: aiThinking,
                showPlayAgainButton: showPlayAgainButton,
              ),
        );
      }

      return const Center(child: Text("Waiting for game to start..."));
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.gameMode.name.capitalize()} Game',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          isLandscape ? BannerAdWidget() : const SizedBox(),
          isLandscape ? const SizedBox(width: 120) : const SizedBox(),

          IconButton(
            onPressed: () {
              _showGameSetupDialog(context);
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
        padding: const EdgeInsets.only(
          left: 16.0,
          right: 16.0,
          top: 8.0,
          bottom: 16,
        ),
        child: buildBodyContent(),
      ),
      bottomNavigationBar:
          isLandscape ? const SizedBox() : const BannerAdWidget(),
    );
  }
}
