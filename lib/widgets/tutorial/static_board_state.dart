import '../../models/enum/player.dart';
import '../../models/move.dart';
import '../../models/win_patterns.dart';

class StaticBoardState {
  final List<List<Player?>> subBoards;
  final List<Player?> subBoardWinners;
  final Player currentPlayer;
  final int? activeSubBoardIndex;
  final Move? lastMove;

  StaticBoardState({
    required this.subBoards,
    required this.subBoardWinners,
    required this.currentPlayer,
    required this.activeSubBoardIndex,
    required this.lastMove,
  });
}

StaticBoardState buildStaticBoardState(List<Move> moves) {
  final subBoards = List.generate(9, (_) => List<Player?>.filled(9, null));
  final subBoardWinners = List<Player?>.filled(9, null);
  int? activeSubBoardIndex;
  Player currentPlayer = Player.one;
  Move? lastMove;

  for (final move in moves) {
    subBoards[move.boardIndex][move.cellIndex] = move.player;
    lastMove = move;

    // Check if that subBoard has a winner now
    if (winPatterns.any((pattern) =>
        pattern.every((i) => subBoards[move.boardIndex][i] == move.player))) {
      subBoardWinners[move.boardIndex] = move.player;
    }

    activeSubBoardIndex = move.cellIndex;

    if (subBoardWinners[activeSubBoardIndex] != null ||
        !subBoards[activeSubBoardIndex].contains(null)) {
      activeSubBoardIndex = null;
    }

    currentPlayer = move.player == Player.one ? Player.two : Player.one;
  }

  return StaticBoardState(
    subBoards: subBoards,
    subBoardWinners: subBoardWinners,
    currentPlayer: currentPlayer,
    activeSubBoardIndex: activeSubBoardIndex,
    lastMove: lastMove,
  );
}
