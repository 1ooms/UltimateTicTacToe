import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/move.dart';

class GameData {
  final Player currentPlayer;
  final int? activeSubBoardIndex;
  final List<Player?> subBoardWinners;
  final List<List<Player?>> subBoards;
  final List<Move> moveHistory;
  final bool gameFinished;
  final Player? overallWinner;

  GameData({
    required this.currentPlayer,
    this.activeSubBoardIndex,
    required this.subBoardWinners,
    required this.subBoards,
    required this.moveHistory,
    required this.gameFinished,
    this.overallWinner,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPlayer': currentPlayer.name,
      'activeSubBoardIndex': activeSubBoardIndex,
      'subBoardWinners': subBoardWinners.map((p) => p?.name).toList(),
      'subBoard1': subBoards[0].map((p) => p?.name).toList(),
      'subBoard2': subBoards[1].map((p) => p?.name).toList(),
      'subBoard3': subBoards[2].map((p) => p?.name).toList(),
      'subBoard4': subBoards[3].map((p) => p?.name).toList(),
      'subBoard5': subBoards[4].map((p) => p?.name).toList(),
      'subBoard6': subBoards[5].map((p) => p?.name).toList(),
      'subBoard7': subBoards[6].map((p) => p?.name).toList(),
      'subBoard8': subBoards[7].map((p) => p?.name).toList(),
      'subBoard9': subBoards[8].map((p) => p?.name).toList(),
      'moveHistory': moveHistory.map((m) => m.toJson()).toList(),
      'gameFinished': gameFinished,
      'overallWinner': overallWinner?.name,
    };
  }

  factory GameData.fromJson(Map<String, dynamic> json) {
    List<List<Player?>> subBoards = [];
    for (int i = 1; i <= 9; i++) {
      subBoards.add(
        (json['subBoard$i'] as List)
            .map((p) => p != null ? Player.values.byName(p) : null)
            .toList(),
      );
    }
    return GameData(
      currentPlayer: Player.values.byName(json['currentPlayer']),
      activeSubBoardIndex: json['activeSubBoardIndex'],
      subBoardWinners:
          (json['subBoardWinners'] as List)
              .map((p) => p != null ? Player.values.byName(p) : null)
              .toList(),
      subBoards: subBoards,
      moveHistory:
          (json['moveHistory'] as List).map((m) {
            return Move.fromJson(Map<String, dynamic>.from(m as Map));
          }).toList(),
      gameFinished: json['gameFinished'],
      overallWinner:
          json['overallWinner'] != null
              ? Player.values.byName(json['overallWinner'])
              : null,
    );
  }
}
