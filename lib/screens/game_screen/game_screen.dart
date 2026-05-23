import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/play_again_button.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/winner_indicator.dart';
import 'package:ultimate_tic_tac_toe/utils/lobby_controller.dart';

import '../../models/enum/bot_difficulty.dart';
import '../../models/enum/player.dart';
import '../../models/game_setup.dart';
import '../../models/player_config.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'leave_game_dialog.dart';
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
  LobbyController? lobbyController;
  String? lobbyCode;
  bool isHost = false;

  final GlobalKey<GameStateState> _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.gameMode == GameMode.online) {
      lobbyController = LobbyController(instance: FirebaseFirestore.instance);
      WidgetsBinding.instance.addPostFrameCallback((ctx) {
        _showOnlineSetupDialog();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((ctx) {
        _showGameSetupDialog();
      });
    }
  }

  Future<void> _showGameSetupDialog() async {
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

      if (widget.gameMode == GameMode.online && isHost && lobbyCode != null) {
        await lobbyController?.startGame(lobbyCode!, result);
      }

      if (!gameStarted) {
        _boardKey.currentState?.resetAndStartNewGame(result);
      }

      setState(() {
        gameStarted = true;
      });
    } else {
      if (widget.gameMode == GameMode.online && isHost && lobbyCode != null) {
        await lobbyController?.deleteLobby(lobbyCode!);
        if (!mounted) return;
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _showOnlineSetupDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => OnlineSetupDialog(lobbyController: lobbyController!),
    );

    // if (!mounted) return;

    if (result != null) {
      setState(() {
        lobbyCode = result['lobbyCode'];
        isHost = result['isHost'];
      });

      if (isHost) {
        _showGameSetupDialog();
      } else {
        final setupData = result['gameSetup'];
        if (setupData != null) {
          final setup = GameSetup.fromJson(setupData);
          setState(() {
            player1 = setup.player1;
            player2 = setup.player2;
            player1Starts = setup.player1Starts;
            botDifficulty = setup.botDifficulty;
            gameStarted = true;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _boardKey.currentState?.resetAndStartNewGame(setup);
          });
        }
      }
    }
  }

  void _handlePlayAgain() {
    setState(() {
      gameStarted = false;
    });
    _showGameSetupDialog();
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
              playingOnline: widget.gameMode == GameMode.online,
              isHost: isHost,
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
          playingOnline: widget.gameMode == GameMode.online,
          onPlayAgain: _handlePlayAgain,
          lobbyController: lobbyController,
          lobbyCode: lobbyCode,
          isHost: isHost,
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && gameStarted) {
          showDialog(context: context, builder: (ctx) => LeaveGameDialog());
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.gameMode.name.capitalize()} Game',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            IconButton(
              onPressed: () => _showGameSetupDialog(),
              icon: const Icon(Icons.palette),
            ),
            if (widget.gameMode != GameMode.online)
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
      ),
    );
  }
}
