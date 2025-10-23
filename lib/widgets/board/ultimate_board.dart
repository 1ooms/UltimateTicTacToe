import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/ultimate_sub_board.dart';

import '../../models/move.dart';
import '../../models/player_config.dart';

class UltimateBoard extends StatelessWidget {
  const UltimateBoard({
    super.key,
    required this.subBoards,
    required this.subBoardWinners,
    required this.player1,
    required this.player2,
    required this.currentPlayer,
    required this.isValidMove,
    required this.onCellTap,
    required this.previousMove,
    required this.gameFinished,
  });

  final List<List<Player?>> subBoards;
  final List<Player?> subBoardWinners;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final Player currentPlayer;
  final bool Function(int boardIndex, int cellIndex) isValidMove;
  final void Function(int boardIndex, int cellIndex) onCellTap;
  final Move? previousMove;
  final bool gameFinished;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
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
          board: subBoards,
          winner: subBoardWinners[subBoardIndex],
          player1: player1,
          player2: player2,
          currentPlayer: currentPlayer,
          isValidMove: isValidMove,
          onCellTap: onCellTap,
          previousMove: previousMove,
          gameFinished: gameFinished,
        );
      },
    );
  }
}
