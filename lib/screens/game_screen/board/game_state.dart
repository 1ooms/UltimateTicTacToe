import 'dart:async';
import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';
import 'package:ultimate_tic_tac_toe/utils/lobby_controller.dart';

import '../../../data/win_patterns.dart';
import '../../../models/enum/player.dart';
import '../../../models/game_setup.dart';
import '../../../models/move.dart';
import '../../../models/move_parameters.dart';
import '../../../utils/audio_controller.dart';
import '../../../utils/bot_player/bot_isolate.dart';
import '../../../utils/ui_helpers.dart';
import '../end_dialogs/draw_dialog.dart';
import '../end_dialogs/win_dialog.dart';

part '../../../utils/bot_game_handler.dart';
part '../../../utils/online_game_handler.dart';

class GameState extends StatefulWidget {
  const GameState({
    super.key,
    required this.playingAgainstBot,
    required this.playingOnline,
    required this.layoutBuilder,
    required this.onPlayAgain,
    required this.gameSetup,
    required this.lobbyController,
    required this.lobbyCode,
    required this.isHost,
  });

  final bool playingAgainstBot;
  final bool playingOnline;
  final VoidCallback onPlayAgain;
  final GameSetup gameSetup;
  final LobbyController? lobbyController;
  final String? lobbyCode;
  final bool isHost;

  final Widget Function({
    required Widget boardWidget,
    required Player currentPlayer,
    required bool gameFinished,
    required Player? overallWinner,
    required bool aiThinking,
    required bool showPlayAgainButton,
  })
  layoutBuilder;

  @override
  State<GameState> createState() => GameStateState();
}

class GameStateState extends State<GameState> with BotHandler, OnlineHandler {
  late List<List<Player?>> _subBoards;
  late List<Player?> _subBoardWinners;
  late Player _currentPlayer;
  int? _activeSubBoardIndex;
  late Player? overallWinner;

  List<Move> _moveHistory = [];

  bool gameFinished = false;
  Color _winnerColor = Colors.transparent;
  final _confettiController = ConfettiController();

  AudioController audioController = AudioController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initBot();
    _initOnline();

    if (widget.playingAgainstBot && _currentPlayer == Player.two) {
      _makeBotMove();
    }
  }

  @override
  void dispose() {
    _disposeOnline();
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeGame() {
    _subBoards = List.generate(9, (ctx) => List<Player?>.filled(9, null));
    _subBoardWinners = List<Player?>.filled(9, null);
    _currentPlayer = widget.gameSetup.player1Starts ? Player.one : Player.two;
    _activeSubBoardIndex = null;
    gameFinished = false;
    overallWinner = null;
  }

  void resetAndStartNewGame(GameSetup setup) {
    setState(() {
      widget.gameSetup.player1 = setup.player1;
      widget.gameSetup.player2 = setup.player2;
      widget.gameSetup.player1Starts = setup.player1Starts;
      widget.gameSetup.botDifficulty = setup.botDifficulty;

      _moveHistory.clear();
      _initializeGame();
      if (widget.playingAgainstBot && _currentPlayer == Player.two) {
        _makeBotMove();
      }
    });
  }

  void _showPlayAgainButton() {
    setState(() {
      if (!gameFinished) {
        gameFinished = true;
      }
    });
  }

  void performUndo() => undoMove();

  void _handleTap(int boardIndex, int cellIndex) {
    if (_aiThinking) return;
    if (widget.playingOnline && _currentPlayer != _localPlayer) return;

    if (!_isValidMove(boardIndex, cellIndex)) return;

    audioController.playSound("assets/sounds/tap.wav");

    setState(() {
      _subBoards[boardIndex][cellIndex] = _currentPlayer;
      _moveHistory.add(
        Move(boardIndex, cellIndex, _currentPlayer, _activeSubBoardIndex),
      );

      if (checkWin(_subBoards[boardIndex], _currentPlayer)) {
        _subBoardWinners[boardIndex] = _currentPlayer;

        if (checkOverallWinner() != null) {
          overallWinner = _currentPlayer;
          gameFinished = true;
          _showWinDialog(_currentPlayer);
          if (widget.playingOnline) {
            widget.lobbyController?.updateGameData(
              widget.lobbyCode!,
              _getGameData(),
            );
          }
          return;
        } else if (checkDraw()) {
          gameFinished = true;
          _showDrawDialog();
          if (widget.playingOnline) {
            widget.lobbyController?.updateGameData(
              widget.lobbyCode!,
              _getGameData(),
            );
          }
          return;
        }
      }

      _activeSubBoardIndex = cellIndex;

      // check if new board available
      if (_subBoardWinners[_activeSubBoardIndex!] != null ||
          !_subBoards[_activeSubBoardIndex!].contains(null)) {
        _activeSubBoardIndex = null;
      }

      // switch player turn
      _currentPlayer = _currentPlayer == Player.one ? Player.two : Player.one;

      if (widget.playingAgainstBot && _currentPlayer == Player.two) {
        _makeBotMove();
      }

      if (widget.playingOnline) {
        widget.lobbyController?.updateGameData(
          widget.lobbyCode!,
          _getGameData(),
        );
      }
    });
  }

  bool _isValidMove(int boardIndex, int cellIndex) {
    if (gameFinished) return false;
    final boardPlayable =
        _subBoardWinners[boardIndex] == null &&
        (_activeSubBoardIndex == null || boardIndex == _activeSubBoardIndex);
    final cellEmpty = _subBoards[boardIndex][cellIndex] == null;
    return boardPlayable && cellEmpty;
  }

  bool checkWin(List<Player?> board, Player player) =>
      winPatterns.any((pattern) => pattern.every((i) => board[i] == player));

  bool checkDraw() =>
      _subBoardWinners.every(
        (winner) =>
            winner != null ||
            !_subBoards[_subBoardWinners.indexOf(winner)].contains(null),
      ) &&
      checkOverallWinner() == null;

  Player? checkOverallWinner() {
    for (final player in [Player.one, Player.two]) {
      if (checkWin(_subBoardWinners, player)) {
        return player;
      }
    }
    return null;
  }

  void _showWinDialog(Player winner) {
    _winnerColor =
        winner == Player.one
            ? widget.gameSetup.player1.color
            : widget.gameSetup.player2.color;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => Stack(
            alignment: Alignment.topCenter,
            children: [
              WinDialog(
                winningPlayer: winner,
                winnerConfig:
                    winner == Player.one
                        ? widget.gameSetup.player1
                        : widget.gameSetup.player2,
                viewingBoard: gameFinished,
                confettiController: _confettiController,
                onPlayAgain: widget.onPlayAgain,
                onViewBoard: _showPlayAgainButton,
                buildIcon: buildIcon,
              ),
              ConfettiWidget(
                key: ValueKey(_winnerColor),
                confettiController: _confettiController,
                blastDirection: pi / 2,
                colors: [_winnerColor],
              ),
            ],
          ),
    );

    _playConfetti();
  }

  void _playConfetti() {
    Future.delayed(const Duration(milliseconds: 50), () {
      _confettiController.play();
    });
  }

  void _showDrawDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => DrawDialog(
            onPlayAgain: widget.onPlayAgain,
            onViewBoard: _showPlayAgainButton,
          ),
    );
  }

  void undoMove() {
    if (_moveHistory.isEmpty || _aiThinking) return;

    audioController.playSound("assets/sounds/tap.wav");

    setState(() {
      int movesToUndo = widget.playingAgainstBot ? 2 : 1;

      for (int i = 0; i < movesToUndo && _moveHistory.isNotEmpty; i++) {
        final move = _moveHistory.removeLast();
        _subBoards[move.boardIndex][move.cellIndex] = null;
        _subBoardWinners[move.boardIndex] = null;
        _currentPlayer = move.player;
        _activeSubBoardIndex = move.activeBoardIndex;
      }

      gameFinished = false;
    });

    if (widget.playingAgainstBot && _currentPlayer == Player.two) {
      _makeBotMove();
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardWidget = UltimateBoard(
      subBoards: _subBoards,
      subBoardWinners: _subBoardWinners,
      player1: widget.gameSetup.player1,
      player2: widget.gameSetup.player2,
      currentPlayer: _currentPlayer,
      isValidMove: _isValidMove,
      onCellTap: _handleTap,
      previousMove: _moveHistory.lastOrNull,
      gameFinished: gameFinished,
    );

    return widget.layoutBuilder(
      boardWidget: boardWidget,
      currentPlayer: _currentPlayer,
      gameFinished: gameFinished,
      overallWinner: overallWinner,
      aiThinking: _aiThinking,
      showPlayAgainButton: gameFinished,
    );
  }
}
