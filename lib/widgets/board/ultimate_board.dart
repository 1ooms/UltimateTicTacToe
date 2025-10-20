import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/ai_difficulty.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/current_player_indicator.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/ultimate_sub_board.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/winner_indicator.dart';

import '../../models/ai_player/ai_isolate.dart';
import '../../models/enum/player.dart';
import '../../models/move.dart';
import '../../models/move_parameters.dart';
import '../../models/player_config.dart';
import '../../data/win_patterns.dart';
import '../../utils/ui_helpers.dart';
import '../ads/banner_ad_widget.dart';
import '../dialogs/draw_dialog.dart';
import '../dialogs/win_dialog.dart';

class Board extends StatefulWidget {
  const Board({
    super.key,
    required this.player1,
    required this.player2,
    required this.player1Starts,
    required this.playingAgainstAI,
    this.aiDifficulty,
  });

  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool player1Starts;
  final bool playingAgainstAI;
  final AIDifficulty? aiDifficulty;

  @override
  State<Board> createState() => BoardState();
}

class BoardState extends State<Board> {
  late List<List<Player?>> _subBoards;
  late List<Player?> _subBoardWinners;
  late Player _currentPlayer;
  int? _activeSubBoardIndex;
  late Player overallWinner;

  final List<Move> _moveHistory = [];
  bool _aiThinking = false;

  bool gameFinished = false;
  Color _winnerColor = Colors.transparent;
  final _confettiController = ConfettiController();
  late final AIIsolate _aiIsolate;

  @override
  void initState() {
    super.initState();
    _initializeGame();

    if (widget.playingAgainstAI) {
      _aiIsolate = AIIsolate(widget.aiDifficulty!);

      if (_currentPlayer == Player.two) {
        _makeAIMove();
      }
    }
  }

  void _initializeGame() {
    _subBoards = List.generate(9, (ctx) => List<Player?>.filled(9, null));
    _subBoardWinners = List<Player?>.filled(9, null);
    _currentPlayer = widget.player1Starts ? Player.one : Player.two;
    _activeSubBoardIndex = null;
  }

  void _resetGame() {
    setState(() {
      _initializeGame();
      _moveHistory.clear();
      gameFinished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

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
                      gameFinished
                          ? WinnerIndicator(
                            overallWinner: overallWinner,
                            player1: widget.player1,
                            player2: widget.player2,
                            playingAgainstAI: widget.playingAgainstAI,
                          )
                          : CurrentPlayerIndicator(
                            currentPlayer: _currentPlayer,
                            player1: widget.player1,
                            player2: widget.player2,
                            playingAgainstAI: widget.playingAgainstAI,
                          ),
                      const SizedBox(height: 16),
                      Visibility(
                        visible: gameFinished,
                        child: TextButton(
                          onPressed: _resetGame,
                          child: const Text("Play again"),
                        ),
                      ),
                      Visibility(
                        visible: _aiThinking,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "AI is thinking",
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(
                              height: 25.0,
                              width: 25.0,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, subBoardIndex) {
                    return SubBoard(
                      boardIndex: subBoardIndex,
                      board: _subBoards,
                      winner: _subBoardWinners[subBoardIndex],
                      player1: widget.player1,
                      player2: widget.player2,
                      currentPlayer: _currentPlayer,
                      isValidMove: _isValidMove,
                      onCellTap: _handleTap,
                      previousMove: _moveHistory.lastOrNull,
                      gameFinished: gameFinished,
                    );
                  },
                ),
              ),

              SizedBox(
                width: sidePanelWidth,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24.0,
                    horizontal: 12.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RotatedBox(
                        quarterTurns: 1,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: BannerAdWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              gameFinished
                  ? WinnerIndicator(
                    overallWinner: overallWinner,
                    player1: widget.player1,
                    player2: widget.player2,
                    playingAgainstAI: widget.playingAgainstAI,
                  )
                  : CurrentPlayerIndicator(
                    currentPlayer: _currentPlayer,
                    player1: widget.player1,
                    player2: widget.player2,
                    playingAgainstAI: widget.playingAgainstAI,
                  ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, subBoardIndex) {
                    return SubBoard(
                      boardIndex: subBoardIndex,
                      board: _subBoards,
                      winner: _subBoardWinners[subBoardIndex],
                      player1: widget.player1,
                      player2: widget.player2,
                      currentPlayer: _currentPlayer,
                      isValidMove: _isValidMove,
                      onCellTap: _handleTap,
                      previousMove: _moveHistory.lastOrNull,
                      gameFinished: gameFinished,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Visibility(
                visible: gameFinished,
                child: TextButton(
                  onPressed: _resetGame,
                  child: const Text("Play again"),
                ),
              ),
              Visibility(
                visible: _aiThinking,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
              ),
            ],
          ),
          BannerAdWidget(),
        ],
      );
    }
  }

  void _handleTap(int boardIndex, int cellIndex) {
    if (_aiThinking) return;

    if (!_isValidMove(boardIndex, cellIndex)) return;

    setState(() {
      _subBoards[boardIndex][cellIndex] = _currentPlayer;
      _moveHistory.add(
        Move(boardIndex, cellIndex, _currentPlayer, _activeSubBoardIndex),
      );

      // check win/draw
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

    await Future.delayed(Duration(milliseconds: 500));

    final moveParameters = MoveParameters(
      _subBoards,
      _subBoardWinners,
      Player.two,
      _activeSubBoardIndex,
      widget.aiDifficulty!,
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
        winner == Player.one ? widget.player1.color : widget.player2.color;

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
                    winner == Player.one ? widget.player1 : widget.player2,
                viewingBoard: gameFinished,
                confettiController: _confettiController,
                onPlayAgain: _resetGame,
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
            onPlayAgain: _resetGame,
            onViewBoard: _showPlayAgainButton,
          ),
    );
  }

  void _showPlayAgainButton() {
    setState(() {
      gameFinished = true;
    });
  }

  void undoMove() {
    if (_moveHistory.isEmpty || _aiThinking) return;

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
      _makeAIMove;
    }
  }

  void performUndo() => undoMove();
}
