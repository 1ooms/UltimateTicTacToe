import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/play_again_button.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/winner_indicator.dart';

import '../../models/enum/bot_difficulty.dart';
import '../../models/enum/player.dart';
import '../../models/game_setup.dart';
import '../../models/online_setup.dart';
import '../../models/player_config.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'board/game_state.dart';
import 'bot_thinking_indicator.dart';
import 'current_player_indicator.dart';
import 'game_screen_landscape_layout.dart';
import 'game_screen_portrait_layout.dart';
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
  BotDifficulty? botDifficulty;
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
        botDifficulty = result.botDifficulty;
      });

      if (!gameStarted) {
        _boardKey.currentState?.resetAndStartNewGame(result);
      }

      setState(() {
        gameStarted = true;
      });
    }
  }

  Future<void> _showOnlineSetupDialog(BuildContext context) async {
    await showDialog<OnlineSetup>(
      barrierDismissible: false,
      context: context,
      builder: (context) => const OnlineSetupDialog(),
    );
  }

  void _handlePlayAgain() {
    setState(() {
      gameStarted = false;
    });
    _showGameSetupDialog(context);
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
        MediaQuery
            .of(context)
            .orientation == Orientation.landscape;

    final PlayerConfig p1 = player1;
    final PlayerConfig p2 = player2;
    final bool playingAgainstBot = widget.gameMode == GameMode.bot;

    Widget playerStatusIndicator =
    gameFinished
        ? WinnerIndicator(
      overallWinner: overallWinner,
      player1: p1,
      player2: p2,
      playingAgainstBot: playingAgainstBot,
    )
        : CurrentPlayerIndicator(
      currentPlayer: currentPlayer,
      player1: p1,
      player2: p2,
      playingAgainstBot: playingAgainstBot,
    );

    final aiThinkingIndicator = BotThinkingIndicator(visible: aiThinking);
    final playAgainButton = PlayAgainButton(
      visible: showPlayAgainButton,
      onPressed: _handlePlayAgain,
    );

    if (isLandscape) {
      return GameScreenLandscapeLayout(
        boardWidget: boardWidget,
        playerStatusIndicator: playerStatusIndicator,
        playAgainButton: playAgainButton,
        aiThinkingIndicator: aiThinkingIndicator,
      );
    } else {
      return GameScreenPortraitLayout(
        boardWidget: boardWidget,
        playerStatusIndicator: playerStatusIndicator,
        playAgainButton: playAgainButton,
        aiThinkingIndicator: aiThinkingIndicator,
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
            botDifficulty: botDifficulty,
          ),
          playingAgainstBot: widget.gameMode == GameMode.bot,
          onPlayAgain: _handlePlayAgain,
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
          IconButton(
            onPressed: () => _showGameSetupDialog(context),
            icon: const Icon(Icons.palette),
          ),
          IconButton(
            onPressed: () => _boardKey.currentState?.performUndo(),
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
