import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/tutorial/static_board_state.dart';

import '../../../models/move.dart';
import '../../../models/player_config.dart';
import '../../game_screen/board/ultimate_sub_board.dart';

class StaticBoard extends StatelessWidget {
  final List<Move> moveHistory;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool gameFinished;

  const StaticBoard({
    super.key,
    required this.moveHistory,
    required this.player1,
    required this.player2,
    required this.gameFinished,
  });

  @override
  Widget build(BuildContext context) {
    final boardState = buildStaticBoardState(moveHistory);

    return AspectRatio(
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
            board: boardState.subBoards,
            winner: boardState.subBoardWinners[subBoardIndex],
            player1: player1,
            player2: player2,
            currentPlayer: boardState.currentPlayer,
            isValidMove: (boardIdx, cellIdx) {
              final valid =
                  boardState.subBoardWinners[boardIdx] == null &&
                  (boardState.activeSubBoardIndex == null ||
                      boardIdx == boardState.activeSubBoardIndex) &&
                  boardState.subBoards[boardIdx][cellIdx] == null;
              return valid;
            },
            onCellTap: (_, __) {},
            previousMove: boardState.lastMove,
            gameFinished: gameFinished,
          );
        },
      ),
    );
  }
}
