import 'package:ultimate_tic_tac_toe/models/enum/player.dart';

import 'enum/bot_difficulty.dart';

class MoveParameters {
  final List<List<Player?>> subBoards;
  final List<Player?> subBoardWinners;
  final Player botPlayer;
  final int? activeSubBoardIndex;
  final BotDifficulty difficulty;

  Map<String, dynamic> toJson() => {
    'subBoards':
        subBoards.map((board) => board.map((p) => p?.name).toList()).toList(),
    'subBoardWinners': subBoardWinners.map((p) => p?.name).toList(),
    'botPlayer': botPlayer.name,
    'activeSubBoardIndex': activeSubBoardIndex,
    'difficulty': difficulty.name,
  };

  factory MoveParameters.fromJson(Map<String, dynamic> json) => MoveParameters(
    (json['subBoards'] as List)
        .map<List<Player?>>(
          (board) =>
              (board as List)
                  .map<Player?>(
                    (p) => p != null ? Player.values.byName(p) : null,
                  )
                  .toList(),
        )
        .toList(),
    (json['subBoardWinners'] as List)
        .map<Player?>((p) => p != null ? Player.values.byName(p) : null)
        .toList(),
    Player.values.byName(json['botPlayer']),
    json['activeSubBoardIndex'],
    BotDifficulty.values.byName(json['difficulty']),
  );

  MoveParameters(
    this.subBoards,
    this.subBoardWinners,
    this.botPlayer,
    this.activeSubBoardIndex,
    this.difficulty,
  );
}
