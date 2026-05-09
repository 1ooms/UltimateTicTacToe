import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../data/win_patterns.dart';
import '../models/enum/player.dart';
import '../models/player_config.dart';
import '../screens/game_screen/end_dialogs/draw_dialog.dart';
import '../screens/game_screen/end_dialogs/win_dialog.dart';
import '../utils/ui_helpers.dart';

// enum Player { one, two }

// final winPatterns = [
//   [0, 1, 2],
//   [3, 4, 5],
//   [6, 7, 8],
//   [0, 3, 6],
//   [1, 4, 7],
//   [2, 5, 8],
//   [0, 4, 8],
//   [2, 4, 6],
// ];

class TicTacToeBoard extends StatefulWidget {
  const TicTacToeBoard({
    super.key,
    required this.player1,
    required this.player2,
    required this.player1Starts,
  });

  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool player1Starts;

  @override
  State<TicTacToeBoard> createState() => TicTacToeBoardState();
}

class TicTacToeBoardState extends State<TicTacToeBoard> {
  @override
  void initState() {
    super.initState();
    _currentPlayer = widget.player1Starts ? Player.one : Player.two;
  }

  final List<Player?> _board = List<Player?>.filled(9, null);
  final List<int> _moveHistory = [];
  Player _currentPlayer = Player.one;

  bool confettiIsPlaying = false;
  Color winnerColor = Colors.transparent;
  final _confettiController = ConfettiController();

  bool showPlayAgain = false;

  Widget _buildCell(int index) {
    Widget? symbol;

    if (_board[index] == Player.one) {
      symbol = buildIcon(widget.player1.shape, widget.player1.color, 48);
    } else if (_board[index] == Player.two) {
      symbol = buildIcon(widget.player2.shape, widget.player2.color, 48);
    }

    return GestureDetector(
      onTap: () => _handleTap(index),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
        child: Center(child: symbol),
      ),
    );
  }

  void _handleTap(int index) {
    if (_board[index] != null) return;

    setState(() {
      _board[index] = _currentPlayer;
      _moveHistory.add(index);

      if (_checkWinner(_currentPlayer)) {
        _showWinDialog(_currentPlayer);
      } else if (_board.every((cell) => cell != null)) {
        _showDrawDialog();
      } else {
        _currentPlayer = _currentPlayer == Player.one ? Player.two : Player.one;
      }
    });
  }

  void undoMove() {
    if (_moveHistory.isEmpty) return;

    setState(() {
      int lastIndex = _moveHistory.removeLast();
      _board[lastIndex] = null;
      _currentPlayer = _currentPlayer == Player.one ? Player.two : Player.one;
      showPlayAgain = false;
    });
  }

  bool _checkWinner(Player player) {
    for (final pattern in winPatterns) {
      if (pattern.every((i) => _board[i] == player)) {
        return true;
      }
    }
    return false;
  }

  void playConfetti(Color color) {
    setState(() {
      winnerColor = color;
    });

    Future.delayed(Duration(milliseconds: 50), () {
      _confettiController.play();
    });
  }

  void _showWinDialog(Player winner) {
    Color winnerColor;
    winner == Player.one
        ? winnerColor = widget.player1.color
        : winnerColor = widget.player2.color;

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
                viewingBoard: showPlayAgain,
                confettiController: _confettiController,
                onPlayAgain: _resetGame,
                onViewBoard: _showPlayAgainButton,
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
    );

    playConfetti(winnerColor);
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
      showPlayAgain = true;
    });
  }

  void _resetGame() {
    setState(() {
      for (int i = 0; i < _board.length; i++) {
        _board[i] = null;
      }
      _moveHistory.clear();
      _currentPlayer = widget.player1Starts ? Player.one : Player.two;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Player: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            _currentPlayer == Player.one
                ? buildIcon(widget.player1.shape, widget.player1.color, 28)
                : buildIcon(widget.player2.shape, widget.player2.color, 28),
          ],
        ),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1,
          child: GridView.builder(
            itemCount: 9,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemBuilder: (ctx, index) => _buildCell(index),
          ),
        ),
        const SizedBox(height: 16),
        showPlayAgain
            ? TextButton(
              onPressed: () {
                _resetGame();
                showPlayAgain = false;
              },
              child: const Text("Play again"),
            )
            : Container(),
      ],
    );
  }

  void performUndo() => undoMove();
}
