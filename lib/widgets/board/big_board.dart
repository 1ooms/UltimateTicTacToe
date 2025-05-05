import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/current_player_indicator.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/sub_board.dart';

import '../../models/move.dart';
import '../../models/player.dart';
import '../../models/player_config.dart';
import '../../models/win_patterns.dart';
import '../dialogs/draw_dialog.dart';
import '../dialogs/player_customizer.dart';
import '../dialogs/win_dialog.dart';

class BigBoard extends StatefulWidget {
  const BigBoard({
    super.key,
    required this.player1,
    required this.player2,
    required this.player1Starts,
  });

  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool player1Starts;

  @override
  State<BigBoard> createState() => BigBoardState();
}

class BigBoardState extends State<BigBoard> {
  late List<List<Player?>> _subBoards;
  late List<Player?> _subBoardWinners;
  late Player _currentPlayer;
  int? _activeSubBoardIndex;

  final List<Move> _moveHistory = [];

  bool _playAgainVisible = false;
  Color _winnerColor = Colors.transparent;
  final _confettiController = ConfettiController();

  @override
  void initState() {
    super.initState();
    _initializeGame();
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
      _playAgainVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CurrentPlayerIndicator(
          currentPlayer: _currentPlayer,
          player1: widget.player1,
          player2: widget.player2,
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
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Visibility(
          visible: _playAgainVisible,
          child: TextButton(
            onPressed: _resetGame,
            child: const Text("Play again"),
          ),
        ),
      ],
    );
  }

  void _handleTap(int boardIndex, int cellIndex) {
    if (!_isValidMove(boardIndex, cellIndex)) return;

    setState(() {
      _subBoards[boardIndex][cellIndex] = _currentPlayer;
      _moveHistory.add(Move(boardIndex, cellIndex, _currentPlayer, _activeSubBoardIndex));

      // check win/draw
      if (_checkWin(_subBoards[boardIndex], _currentPlayer)) {
        _subBoardWinners[boardIndex] = _currentPlayer;

        if (_checkOverallWinner() != null) {
          _showWinDialog(_currentPlayer);
          return;
        } else if (_checkDraw()) {
          _showDrawDialog();
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
    });
  }

  bool _isValidMove(int boardIndex, int cellIndex) {
    final boardPlayable =
        _subBoardWinners[boardIndex] == null &&
        (_activeSubBoardIndex == null || boardIndex == _activeSubBoardIndex);
    final cellEmpty = _subBoards[boardIndex][cellIndex] == null;
    return boardPlayable && cellEmpty;
  }

  bool _checkWin(List<Player?> board, Player player) =>
      winPatterns.any((pattern) => pattern.every((i) => board[i] == player));

  bool _checkDraw() =>
      _subBoardWinners.every(
        (winner) =>
            winner != null ||
            !_subBoards[_subBoardWinners.indexOf(winner)].contains(null),
      ) &&
      _checkOverallWinner() == null;

  Player? _checkOverallWinner() {
    for (final player in [Player.one, Player.two]) {
      if (_checkWin(_subBoardWinners, player)) {
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
                viewingBoard: _playAgainVisible,
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
      builder: (ctx) => DrawDialog(onPlayAgain: _resetGame),
    );
  }

  void _showPlayAgainButton() {
    setState(() {
      _playAgainVisible = true;
    });
  }

  void undoMove() {
    if (_moveHistory.isEmpty) return;

    setState(() {
      final lastMove = _moveHistory.removeLast();
      _subBoards[lastMove.boardIndex][lastMove.cellIndex] = null;
      _currentPlayer = _currentPlayer == Player.one ? Player.two : Player.one;

      _subBoardWinners[lastMove.boardIndex] = null;
      _activeSubBoardIndex = lastMove.activeBoardIndex;
    });
  }

  void performUndo() => undoMove();
}
