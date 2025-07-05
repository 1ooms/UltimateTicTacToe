import 'package:flutter/material.dart';
import '../../models/move.dart';
import '../../models/enum/player.dart';
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
  final Move? previousMove;

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
    required this.previousMove,
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
          itemBuilder:
              (ctx, cellIndex) =>
                  _buildSubBoardCell(context, boardIndex, cellIndex),
        ),
        if (winner != null)
          Container(
            color:
                Theme.of(context).brightness == Brightness.dark
                    ? (winner == Player.one ? player1.color : player2.color)
                        .withAlpha(130)
                    : (winner == Player.one ? player1.color : player2.color)
                        .withAlpha(102),
            child: Center(
              child: buildIcon(
                winner == Player.one ? player1.shape : player2.shape,
                winner == Player.one ? player1.color : player2.color,
                110,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubBoardCell(
    BuildContext context,
    int boardIndex,
    int cellIndex,
  ) {
    final player = board[boardIndex][cellIndex];

    Icon? symbol;
    if (player == Player.one) {
      symbol = buildIcon(player1.shape, player1.color, 32.toDouble());
    } else if (player == Player.two) {
      symbol = buildIcon(player2.shape, player2.color, 32.toDouble());
    }

    final highlightColor =
        currentPlayer == Player.one ? player1.color : player2.color;

    late final Color borderColor;
    late final double borderThickness;

    if (previousMove != null &&
        previousMove!.boardIndex == boardIndex &&
        previousMove!.cellIndex == cellIndex) {
      borderColor = Theme.of(context).colorScheme.onSurface;
      borderThickness = 2;
    } else {
      borderColor = Colors.grey;
      borderThickness = 1;
    }

    return GestureDetector(
      onTap:
          isValidMove(boardIndex, cellIndex)
              ? () => onCellTap(boardIndex, cellIndex)
              : null,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: borderThickness),
          color:
              isValidMove(boardIndex, cellIndex)
                  ? Theme.of(context).brightness == Brightness.dark
                      ? highlightColor.withAlpha(75)
                      : highlightColor.withAlpha(38)
                  : null,
        ),
        child: Center(child: symbol),
      ),
    );
  }
}
