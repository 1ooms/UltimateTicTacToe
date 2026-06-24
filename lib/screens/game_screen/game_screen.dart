import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/draw_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/session_ended_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/win_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_info/play_again_button.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_info/winner_indicator.dart';
import 'package:ultimate_tic_tac_toe/utils/game_controller.dart';
import 'package:ultimate_tic_tac_toe/utils/ui_helpers.dart';

import '../../models/enum/bot_difficulty.dart';
import '../../models/enum/player.dart';
import '../../models/game_setup.dart';
import '../../models/player_config.dart';
import '../../utils/online_game_controller.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'end_dialogs/leave_game_dialog.dart';
import 'game_info/bot_thinking_indicator.dart';
import 'game_info/current_player_indicator.dart';
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
  // game setup args
  late PlayerConfig player1;
  late PlayerConfig player2;
  late bool player1Starts;
  BotDifficulty? botDifficulty;

  GameController? _gameController;
  final ConfettiController _confettiController = ConfettiController();
  bool gameStarted = false;
  bool _isEndDialogOpen = false;

  // online game args
  OnlineGameController? onlineGameController;
  String? lobbyCode;
  bool? isHost;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {
      if (widget.gameMode == GameMode.online) {
        _initializeOnlineGame();
      } else {
        _showGameSetupDialog();
      }
    });
  }

  @override
  void dispose() {
    _gameController?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeOnlineGame() async {
    onlineGameController = OnlineGameController();
    bool connected = await onlineGameController!.initialize();
    if (!connected) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to the server.")),
      );
      return;
    }
    _showOnlineSetupDialog();
  }

  Future<void> _showGameSetupDialog() async {
    final gameSetup = await showDialog<GameSetup>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) =>
              GameSetupDialog(gameMode: widget.gameMode, gameStarted: false),
    );

    if (gameSetup != null) {
      setState(() {
        player1 = gameSetup.player1;
        player2 = gameSetup.player2;
        player1Starts = gameSetup.player1Starts;
        botDifficulty = gameSetup.botDifficulty;
      });

      if (widget.gameMode == GameMode.online &&
          isHost != null &&
          lobbyCode != null) {
        await onlineGameController?.startGame(gameSetup);
      }

      setState(() {
        gameStarted = true;
      });

      if (_gameController == null) {
        _gameController = GameController(
          gameMode: widget.gameMode,
          gameSetup: gameSetup,
          onlineGameController: onlineGameController,
          lobbyCode: lobbyCode,
          isHost: isHost,
          onWin: _showWinDialog,
          onDraw: _showDrawDialog,
          onOnlineSessionEnded: _showSessionEndedDialog,
          onGameRestarted: _handleGameRestarted,
        );
      } else {
        _gameController!.resetAndStartNewGame(gameSetup);
      }
    } else if (widget.gameMode == GameMode.online &&
        isHost != null &&
        lobbyCode != null) {
      await onlineGameController?.stopHosting();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _showOnlineSetupDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) =>
              OnlineSetupDialog(onlineGameController: onlineGameController!),
    );

    if (result != null) {
      setState(() {
        lobbyCode = result['lobbyCode'];
        isHost = result['isHost'];

        // why is this here?
        if (isHost ?? false) {
          gameStarted = true;
        }
      });

      if (isHost ?? false) {
        _showGameSetupDialog();
      } else {
        final setupData = result['gameSetup'];

        if (setupData == null) return;

        final setup = GameSetup.fromJson(setupData);
        setState(() {
          player1 = setup.player1;
          player2 = setup.player2;
          player1Starts = setup.player1Starts;
          botDifficulty = setup.botDifficulty;
          gameStarted = true;
        });

        if (_gameController == null) {
          _gameController = GameController(
            gameMode: widget.gameMode,
            gameSetup: setup,
            onlineGameController: onlineGameController,
            lobbyCode: lobbyCode,
            isHost: isHost,
            onWin: _showWinDialog,
            onDraw: _showDrawDialog,
            onOnlineSessionEnded: _showSessionEndedDialog,
            onGameRestarted: _handleGameRestarted,
          );
        } else {
          _gameController!.resetAndStartNewGame(setup);
        }
      }
    }
  }

  void _showWinDialog(Player winner) {
    Color winnerColor = winner == Player.one ? player1.color : player2.color;

    _isEndDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Stack(
            alignment: Alignment.topCenter,
            children: [
              WinDialog(
                gameMode: widget.gameMode,
                isHost: isHost,
                winningPlayer: winner,
                winnerConfig: winner == Player.one ? player1 : player2,
                viewingBoard: _gameController?.gameFinished ?? true,
                confettiController: _confettiController,
                onPlayAgain: _handlePlayAgain,
                onViewBoard: () {
                  // Ensure UI rebuilds if they dismiss the dialog to view board.
                },
                buildIcon: buildIcon,
              ),
              ConfettiWidget(
                key: ValueKey(winnerColor),
                confettiController: _confettiController,
                blastDirection: pi / 2,
                colors: [winnerColor],
              ),
            ],
          ),
    ).then((_) {
      _isEndDialogOpen = false;
    });

    Future.delayed(const Duration(milliseconds: 50), () {
      _confettiController.play();
    });
  }

  void _showDrawDialog() {
    _isEndDialogOpen = true;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => DrawDialog(
            gameMode: widget.gameMode,
            isHost: isHost,
            onPlayAgain: _handlePlayAgain,
            onViewBoard: () {},
          ),
    ).then((_) {
      _isEndDialogOpen = false;
    });
  }

  void _showSessionEndedDialog(String lobbyCode) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => SessionEndedDialog(
            onlineGameController: onlineGameController,
            lobbyCode: lobbyCode,
          ),
    );
  }

  void _handleGameRestarted() {
    _confettiController.stop();
    if (isHost == false && _isEndDialogOpen) {
      if (mounted) {
        Navigator.of(context).pop();
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
      if (gameStarted && _gameController != null) {
        return ListenableBuilder(
          listenable: _gameController!,
          builder: (context, child) {
            final controller = _gameController!;
            final boardWidget = UltimateBoard(
              subBoards: controller.subBoards,
              subBoardWinners: controller.subBoardWinners,
              player1: player1,
              player2: player2,
              currentPlayer: controller.currentPlayer,
              isValidMove: controller.isValidMove,
              onCellTap: controller.handleTap,
              previousMove: controller.moveHistory.lastOrNull,
              gameFinished: controller.gameFinished,
            );

            return _buildGameLayout(
              boardWidget: boardWidget,
              currentPlayer: controller.currentPlayer,
              gameFinished: controller.gameFinished,
              overallWinner: controller.overallWinner,
              aiThinking: controller.aiThinking,
              showPlayAgainButton:
                  controller.gameFinished &&
                  !(widget.gameMode == GameMode.online && isHost != true),
            );
          },
        );
      }

      return const Center(child: Text("Waiting for game to start..."));
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && gameStarted) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (ctx) => LeaveGameDialog(gameMode: widget.gameMode),
          );

          if (shouldLeave == true && mounted) {
            _gameController?.cancelOnlineSubscription();
            if (widget.gameMode == GameMode.online) {
              onlineGameController?.setOtherPlayerLeft();
            }
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '${widget.gameMode.name.capitalize()} Game',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          actions: [
            if (widget.gameMode != GameMode.online)
              IconButton(
                onPressed: () => _showGameSetupDialog(),
                icon: const Icon(Icons.palette),
              ),
            if (widget.gameMode != GameMode.online)
              IconButton(
                onPressed: () => _gameController?.undoMove(),
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
