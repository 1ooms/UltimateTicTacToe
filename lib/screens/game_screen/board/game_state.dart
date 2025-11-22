import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';

import '../../../data/win_patterns.dart';
import '../../../models/ai_player/ai_isolate.dart';
import '../../../models/enum/player.dart';
import '../../../models/game_setup.dart';
import '../../../models/move.dart';
import '../../../models/move_parameters.dart';
import '../../../utils/audio_controller.dart';
import '../../../utils/ui_helpers.dart';
import '../dialogs/draw_dialog.dart';
import '../dialogs/win_dialog.dart';

class GameState extends StatefulWidget {
  const GameState({
    super.key,
    required this.playingAgainstAI,
    required this.layoutBuilder,
    required this.onPlayAgain,
    required this.gameSetup,
  });

  final bool playingAgainstAI;
  final VoidCallback onPlayAgain;
  final GameSetup gameSetup;

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

class GameStateState extends State<GameState> {
  late List<List<Player?>> _subBoards;
  late List<Player?> _subBoardWinners;
  late Player _currentPlayer;
  int? _activeSubBoardIndex;
  late Player? overallWinner;

  final List<Move> _moveHistory = [];
  bool _aiThinking = false;

  bool gameFinished = false;
  Color _winnerColor = Colors.transparent;
  final _confettiController = ConfettiController();
  late final AIIsolate _aiIsolate;

  AudioController audioController = AudioController();

  @override
  void initState() {
    super.initState();
    _initializeGame();

    if (widget.playingAgainstAI) {
      _aiIsolate = AIIsolate(widget.gameSetup.aiDifficulty!);

      if (_currentPlayer == Player.two) {
        _makeAIMove();
      }
    }
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
      widget.gameSetup.aiDifficulty = setup.aiDifficulty;

      _moveHistory.clear();
      _initializeGame();
      if (widget.playingAgainstAI && _currentPlayer == Player.two) {
        _makeAIMove();
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
          _showWinDialog(_currentPlayer);
          overallWinner = _currentPlayer;
          gameFinished = true;
          return;
        } else if (checkDraw()) {
          _showDrawDialog();
          gameFinished = true;
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

      if (widget.playingAgainstAI && _currentPlayer == Player.two) {
        _makeAIMove();
      }
    });
  }

  Future<void> _makeAIMove() async {
    if (_aiThinking) return;
    _aiThinking = true;

    await Future.delayed(const Duration(milliseconds: 500));

    final moveParameters = MoveParameters(
      _subBoards,
      _subBoardWinners,
      Player.two,
      _activeSubBoardIndex,
      widget.gameSetup.aiDifficulty!,
    );

    final move = await _aiIsolate.computeMove(moveParameters);

    _aiThinking = false;

    if (move != null) {
      _handleTap(move.boardIndex, move.cellIndex);
    }
  }

  bool _isValidMove(int boardIndex, int cellIndex) {
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

    Theme.of(context).colorScheme.onSurface;

    setState(() {
      int movesToUndo = widget.playingAgainstAI ? 2 : 1;

      for (int i = 0; i < movesToUndo && _moveHistory.isNotEmpty; i++) {
        final move = _moveHistory.removeLast();
        _subBoards[move.boardIndex][move.cellIndex] = null;
        _subBoardWinners[move.boardIndex] = null;
        _currentPlayer = move.player;
        _activeSubBoardIndex = move.activeBoardIndex;
      }

      gameFinished = false;
    });

    if (widget.playingAgainstAI && _currentPlayer == Player.two) {
      _makeAIMove();
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
