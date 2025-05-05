import 'package:flutter/material.dart';
import '../../models/player.dart';
import '../../models/player_config.dart';
import '../dialogs/player_customizer.dart';

class SubBoard extends StatelessWidget {
  final int boardIndex;
  final List<List<Player?>> board;
  final Player? winner;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final Player currentPlayer;
  final void Function(int, int) onCellTap;
  final bool Function(int boardIndex, int cellIndex) isValidMove;

  const SubBoard({
    super.key,
    required this.boardIndex,
    required this.board,
    required this.winner,
    required this.player1,
    required this.player2,
    required this.currentPlayer,
    required this.onCellTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
          ),
          itemCount: 9,
          itemBuilder: (ctx, cellIndex) => _buildSubBoardCell(boardIndex, cellIndex),
        ),
        if (winner != null)
          Container(
            color: (winner == Player.one
                ? player1.color
                : player2.color)
                .withAlpha(102),
            child: Center(
              child: buildIcon(
                winner == Player.one
                    ? player1.shape
                    : player2.shape,
                winner == Player.one
                    ? player1.color
                    : player2.color,
                110,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubBoardCell(int boardIndex, int cellIndex) {
    final player = board[boardIndex][cellIndex];

    Icon? symbol;
    if (player == Player.one) {
      symbol = buildIcon(player1.shape, player1.color, 32.toDouble());
    } else if (player == Player.two) {
      symbol = buildIcon(player2.shape, player2.color, 32.toDouble());
    }

    final highlightColor =
    currentPlayer == Player.one
        ? player1.color
        : player2.color;

    return GestureDetector(
      onTap: isValidMove(boardIndex, cellIndex) ? () => onCellTap(boardIndex, cellIndex) : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: isValidMove(boardIndex, cellIndex) ? highlightColor.withAlpha(38) : null,
        ),
        child: Center(child: symbol),
      ),
    );
  }
}
