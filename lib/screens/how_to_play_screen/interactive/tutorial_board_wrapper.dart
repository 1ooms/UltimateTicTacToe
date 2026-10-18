import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/controllers/game_controller.dart';
import 'package:ultimate_tic_tac_toe/models/player_config.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';

class TutorialBoardWrapper extends StatelessWidget {
  final GameController gameController;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final List<GlobalKey> subBoardKeys;
  final List<GlobalKey> cellKeys;
  final void Function(int boardIndex, int cellIndex) onCellTap;

  const TutorialBoardWrapper({
    super.key,
    required this.gameController,
    required this.player1,
    required this.player2,
    required this.subBoardKeys,
    required this.cellKeys,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        children: [
          // Underlying existing board widget
          UltimateBoard(
            subBoards: gameController.subBoards,
            subBoardWinners: gameController.subBoardWinners,
            player1: player1,
            player2: player2,
            currentPlayer: gameController.currentPlayer,
            isValidMove: gameController.isValidMove,
            onCellTap: (_, __) {},
            previousMove: gameController.moveHistory.lastOrNull,
            gameFinished: gameController.gameFinished,
          ),

          // Transparent tap interceptor and key holder layer
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, boardIndex) {
              return Container(
                key: subBoardKeys[boardIndex],
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, cellIndex) {
                    final keyIndex = boardIndex * 9 + cellIndex;
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onCellTap(boardIndex, cellIndex),
                      child: Container(
                        key: cellKeys[keyIndex],
                        color: Colors.transparent,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
