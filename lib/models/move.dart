import 'package:ultimate_tic_tac_toe/models/enum/player.dart';

class Move {
  final int boardIndex;
  final int cellIndex;
  final Player player;
  final int? activeBoardIndex;

  Map<String, dynamic> toJson() => {
    'boardIndex': boardIndex,
    'cellIndex': cellIndex,
    'player': player.name,
    'activeBoardIndex': activeBoardIndex,
  };

  factory Move.fromJson(Map<String, dynamic> json) => Move(
    json['boardIndex'],
    json['cellIndex'],
    Player.values.byName(json['player']),
    json['activeBoardIndex'],
  );

  Move(this.boardIndex, this.cellIndex, this.player, this.activeBoardIndex);
}
