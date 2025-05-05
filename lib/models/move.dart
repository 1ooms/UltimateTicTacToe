import 'package:ultimate_tic_tac_toe/models/player.dart';

class Move {
  final int boardIndex;
  final int cellIndex;
  final Player player;
  final int? activeBoardIndex;

  Move(this.boardIndex, this.cellIndex, this.player, this.activeBoardIndex);
}