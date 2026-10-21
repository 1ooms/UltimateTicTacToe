import 'dart:async';
import 'dart:math';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/extensions/string_extension.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/models/online_setup.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/draw_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/session_ended_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/end_dialogs/win_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_info/play_again_button.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_info/winner_indicator.dart';
import 'package:ultimate_tic_tac_toe/controllers/game_controller.dart';
import 'package:ultimate_tic_tac_toe/utils/ui_helpers.dart';
import 'package:ultimate_tic_tac_toe/utils/game_mode_gradients.dart';

import '../../models/enum/player.dart';
import '../../models/game_setup.dart';
import '../../models/player_config.dart';
import '../../models/saved_game.dart';
import '../../controllers/bot_game_controller.dart';
import '../../controllers/online_game_controller.dart';
import '../../controllers/stats_controller.dart';
import '../../services/game_save_service.dart';
import '../../widgets/ads/banner_ad_widget.dart';
import 'end_dialogs/leave_game_dialog.dart';
import 'game_info/bot_thinking_indicator.dart';
import 'game_info/current_player_indicator.dart';
import 'game_screen_landscape_layout.dart';
import 'game_screen_portrait_layout.dart';
import 'game_setup_dialogs/game_setup/game_setup_dialog.dart';
import 'game_setup_dialogs/online_setup/online_setup_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.gameMode,
    this.initialSavedGame,
    this.gameSaveService,
  });

  final GameMode gameMode;
  final SavedGame? initialSavedGame;
  final GameSaveService? gameSaveService;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameSetup gameSetup;
  late final GameSaveService _gameSaveService;

  GameController? _gameController;
  BotGameController? botGameController;
  final ConfettiController _confettiController = ConfettiController();
  bool gameStarted = false;
  bool _isEndDialogOpen = false;
  bool _hasRecordedStats = false;

  // online game args
  OnlineGameController? onlineGameController;
  String? lobbyCode;
  bool? isHost;

  Player? localPlayer;

  @override
  void initState() {
    super.initState();
    _gameSaveService = widget.gameSaveService ?? const GameSaveService();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {
      if (widget.initialSavedGame != null) {
        _restoreSavedGame(widget.initialSavedGame!);
      } else if (widget.gameMode == GameMode.online) {
        _initializeOnlineGame();
      } else {
        _showGameSetupDialog();
      }
    });
  }

  @override
  void dispose() {
    _gameController?.dispose();
    botGameController?.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _initializeOnlineGame() async {
    try {
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
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to connect to the server.")),
      );
    }
  }

  Future<void> _showGameSetupDialog() async {
    final gameSetupResult = await showDialog<GameSetup>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => GameSetupDialog(
            gameMode: widget.gameMode,
            gameStarted: gameStarted,
          ),
    );

    if (gameSetupResult != null) {
      setState(() {
        gameSetup = gameSetupResult;
      });

      if (widget.gameMode == GameMode.online &&
          isHost != null &&
          lobbyCode != null) {
        await onlineGameController?.startGame(gameSetup);
      }

      if (!gameStarted) {
        _initializeOrResetGameController(gameSetup);
      } else {
        _gameController?.gameSetup = gameSetup;
        _saveCurrentGameProgress();
      }

      setState(() {
        gameStarted = true;
      });
    } else if (widget.gameMode == GameMode.online &&
        isHost != null &&
        lobbyCode != null) {
      await onlineGameController?.stopHosting();
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Future<void> _showOnlineSetupDialog() async {
    final onlineSetup = await showDialog<OnlineSetup>(
      barrierDismissible: false,
      context: context,
      builder:
          (context) =>
              OnlineSetupDialog(onlineGameController: onlineGameController!),
    );

    if (onlineSetup != null) {
      setState(() {
        lobbyCode = onlineSetup.lobbyCode;
        isHost = onlineSetup.isHost;
      });

      if (isHost ?? false) {
        _showGameSetupDialog();
      } else {
        final gameSetupResult = onlineSetup.gameSetup;

        setState(() {
          gameSetup = gameSetupResult!;
          gameStarted = true;
        });

        _initializeOrResetGameController(gameSetup);
      }
    }
  }

  void _restoreSavedGame(SavedGame savedGame) {
    setState(() {
      gameSetup = savedGame.gameSetup;
      gameStarted = true;
    });

    _hasRecordedStats = false;
    _setLocalPlayer();
    _gameController = GameController.restore(
      gameMode: widget.gameMode,
      gameSetup: savedGame.gameSetup,
      savedData: savedGame.gameData,
      localPlayer: localPlayer,
      onWin: _showWinDialog,
      onDraw: _showDrawDialog,
      onGameStateChanged: _handleGameStateChanged,
    );

    if (widget.gameMode == GameMode.bot) {
      botGameController = BotGameController(gameController: _gameController!);
    }
  }

  void _handleGameStateChanged() {
    if (widget.gameMode == GameMode.online) {
      onlineGameController?.sendGameData();
    } else {
      _saveCurrentGameProgress();
    }
  }

  void _saveCurrentGameProgress() {
    if (widget.gameMode == GameMode.online ||
        _gameController == null ||
        _gameController!.gameFinished) {
      return;
    }
    _gameSaveService.saveGame(
      mode: widget.gameMode,
      setup: gameSetup,
      data: _gameController!.toGameData(),
    );
  }

  void _setLocalPlayer() {
    if (widget.gameMode == GameMode.online) {
      if (isHost != null && isHost!) {
        localPlayer = Player.one;
      } else if (isHost != null && !isHost!) {
        localPlayer = Player.two;
      }
    } else if (widget.gameMode == GameMode.bot) {
      localPlayer = Player.one;
    }
  }

  void _initializeOrResetGameController(GameSetup setup) {
    _hasRecordedStats = false;
    _setLocalPlayer();
    if (_gameController == null) {
      _gameController = GameController(
        gameMode: widget.gameMode,
        gameSetup: setup,
        localPlayer: localPlayer,
        onWin: _showWinDialog,
        onDraw: _showDrawDialog,
        onGameStateChanged: _handleGameStateChanged,
      );
      if (widget.gameMode == GameMode.online) {
        onlineGameController?.syncWith(
          _gameController!,
          onOnlineSessionEnded: _showSessionEndedDialog,
          onGameRestarted: _handleGameRestarted,
        );
      } else if (widget.gameMode == GameMode.bot) {
        botGameController = BotGameController(gameController: _gameController!);
      }
    } else {
      _gameController!.resetAndStartNewGame(setup);
    }
    _saveCurrentGameProgress();
  }

  void _recordGameStats({Player? winner, bool isDraw = false}) {
    if (_hasRecordedStats) return;
    _hasRecordedStats = true;

    final statsController = StatsController();
    switch (widget.gameMode) {
      case GameMode.local:
        statsController.recordLocalGamePlayed(winner: winner, isDraw: isDraw);
        break;
      case GameMode.online:
        final bool userWon =
            isDraw
                ? false
                : (winner != null && localPlayer != null
                    ? winner == localPlayer
                    : false);
        statsController.recordOnlineGamePlayed(won: userWon, isDraw: isDraw);
        break;
      case GameMode.bot:
        final difficulty = gameSetup.botDifficulty;
        final bool userWon = !isDraw && winner == Player.one;
        statsController.recordBotGamePlayed(
          won: userWon,
          difficulty: difficulty!,
          isDraw: isDraw,
        );
        break;
    }
  }

  void _showWinDialog(Player winner) {
    _recordGameStats(winner: winner);
    if (widget.gameMode != GameMode.online) {
      _gameSaveService.clearSavedGame(widget.gameMode);
    }

    Color winnerColor =
        winner == Player.one
            ? gameSetup.player1.color
            : gameSetup.player2.color;

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
                winnerConfig:
                    winner == Player.one
                        ? gameSetup.player1
                        : gameSetup.player2,
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

    if (localPlayer == null || winner == localPlayer) {
      Future.delayed(const Duration(milliseconds: 50), () {
        _confettiController.play();
      });
    }
  }

  void _showDrawDialog() {
    _recordGameStats(isDraw: true);
    if (widget.gameMode != GameMode.online) {
      _gameSaveService.clearSavedGame(widget.gameMode);
    }

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
    if (widget.gameMode != GameMode.online) {
      _gameSaveService.clearSavedGame(widget.gameMode);
    }
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

    final PlayerConfig p1 = gameSetup.player1;
    final PlayerConfig p2 = gameSetup.player2;
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
          listenable: Listenable.merge([
            _gameController!,
            if (botGameController != null) botGameController!,
          ]),
          builder: (context, child) {
            final controller = _gameController!;
            final boardWidget = UltimateBoard(
              subBoards: controller.subBoards,
              subBoardWinners: controller.subBoardWinners,
              player1: gameSetup.player1,
              player2: gameSetup.player2,
              currentPlayer: controller.currentPlayer,
              isValidMove: controller.isValidMove,
              onCellTap: controller.makeMove,
              previousMove: controller.moveHistory.lastOrNull,
              gameFinished: controller.gameFinished,
            );

            return _buildGameLayout(
              boardWidget: boardWidget,
              currentPlayer: controller.currentPlayer,
              gameFinished: controller.gameFinished,
              overallWinner: controller.overallWinner,
              aiThinking: botGameController?.aiThinking ?? false,
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop && gameStarted) {
          final shouldLeave = await showDialog<bool>(
            context: context,
            builder: (ctx) => LeaveGameDialog(gameMode: widget.gameMode),
          );

          if (shouldLeave == true && context.mounted) {
            onlineGameController?.cancelSync();
            if (widget.gameMode == GameMode.online) {
              onlineGameController?.setOtherPlayerLeft();
            }
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: GameModeGradients.forMode(widget.gameMode, isDarkMode),
            ),
          ),
          foregroundColor: Colors.white,
          title: Text(
            '${widget.gameMode.name.capitalize()} Game',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            if (widget.gameMode != GameMode.online)
              IconButton(
                onPressed: () => _showGameSetupDialog(),
                icon: const Icon(Icons.palette),
              ),
            if (_gameController != null)
              ListenableBuilder(
                listenable: _gameController!,
                builder: (context, _) {
                  if (widget.gameMode != GameMode.online ||
                      _gameController!.currentPlayer == localPlayer) {
                    return IconButton(
                      onPressed: () => _gameController!.undoMove(),
                      icon: const Icon(Icons.undo),
                    );
                  }
                  return const SizedBox.shrink();
                },
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
