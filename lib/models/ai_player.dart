import 'dart:math';

import 'ai_difficulty.dart';
import 'move.dart';
import 'player.dart';

class AIPlayer {
  final AIDifficulty difficulty;
  final bool Function(List<Player?>, Player) checkWin;

  AIPlayer({
    required this.difficulty,
    required this.checkWin,
  });

  final Random _random = Random();

  Future<Move?> chooseAIMove({
    required List<List<Player?>> board,
    required List<Player?> subBoardWinners,
    required Player aiPlayer,
    required int? activeSubBoardIndex,
    required AIDifficulty difficulty,
  }) async {

    switch (difficulty) {
      case AIDifficulty.easy:
        return _randomMove(board, subBoardWinners, activeSubBoardIndex);

      case AIDifficulty.medium:
        return _minimaxMove(board, subBoardWinners, aiPlayer, activeSubBoardIndex, maxDepth: 2);

      case AIDifficulty.hard:
        return _minimaxMove(board, subBoardWinners, aiPlayer, activeSubBoardIndex, maxDepth: 4);

      case AIDifficulty.expert:
        return _minimaxMove(board, subBoardWinners, aiPlayer, activeSubBoardIndex, maxDepth: 9);
    }
  }

  Move? _randomMove(List<List<Player?>> board, List<Player?> subBoardWinners, int? activeSubBoardIndex) {
    final validMoves = _getValidMoves(board, subBoardWinners, activeSubBoardIndex);
    if (validMoves.isEmpty) return null;
    return validMoves[_random.nextInt(validMoves.length)];
  }

  Move? _minimaxMove(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Player aiPlayer,
      int? activeSubBoardIndex, {
        required int maxDepth,
      }) {
    int bestScore = -1000000;
    List<Move> bestMoves = List<Move>.empty(growable: true);

    // Handle full or won sub-board
    if (activeSubBoardIndex != null &&
        (subBoardWinners[activeSubBoardIndex] != null ||
            board[activeSubBoardIndex].every((cell) => cell != null))) {
      activeSubBoardIndex = null;
    }

    for (final move in _getValidMoves(board, subBoardWinners, activeSubBoardIndex)) {
      final prevWinner = subBoardWinners[move.boardIndex];
      _applyMove(board, subBoardWinners, move, aiPlayer);

      int score = _minimax(
        board,
        subBoardWinners,
        _switchPlayer(aiPlayer),
        move.cellIndex,
        1,
        maxDepth,
        -1000000,
        1000000,
        aiPlayer,
      );

      _undoMove(board, subBoardWinners, move, prevWinner);

      if (score > bestScore) {
        bestScore = score;
        bestMoves.clear();
        bestMoves.add(move);
      }

      if (score == bestScore) {
        bestMoves.add(move);
      }
    }

    Random random = Random();
    int randomBestMoveIndex = random.nextInt(bestMoves.length);

    return bestMoves[randomBestMoveIndex];
  }

  int _minimax(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Player currentPlayer,
      int? activeSubBoardIndex,
      int depth,
      int maxDepth,
      int alpha,
      int beta,
      Player aiPlayer,
      ) {
    // Fallback if sub-board is unplayable
    if (activeSubBoardIndex != null &&
        (subBoardWinners[activeSubBoardIndex] != null ||
            board[activeSubBoardIndex].every((cell) => cell != null))) {
      activeSubBoardIndex = null;
    }

    Player? winner = checkOverallWinner(subBoardWinners);
    if (winner != null) {
      if (winner == aiPlayer) {
        return 1000 - depth;
      } else {
        return -1000 + depth;
      }
    }

    if (checkDraw(board, subBoardWinners)) return 0;
    if (depth >= maxDepth) return _evaluateBoard(board, subBoardWinners, aiPlayer);

    if (currentPlayer == aiPlayer) {
      int maxEval = -1000000;
      for (final move in _getValidMoves(board, subBoardWinners, activeSubBoardIndex)) {
        final prevWinner = subBoardWinners[move.boardIndex];
        _applyMove(board, subBoardWinners, move, currentPlayer);
        int eval = _minimax(board, subBoardWinners, _switchPlayer(currentPlayer), move.cellIndex, depth + 1, maxDepth, alpha, beta, aiPlayer);
        _undoMove(board, subBoardWinners, move, prevWinner);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (final move in _getValidMoves(board, subBoardWinners, activeSubBoardIndex)) {
        final prevWinner = subBoardWinners[move.boardIndex];
        _applyMove(board, subBoardWinners, move, currentPlayer);
        int eval = _minimax(board, subBoardWinners, _switchPlayer(currentPlayer), move.cellIndex, depth + 1, maxDepth, alpha, beta, aiPlayer);
        _undoMove(board, subBoardWinners, move, prevWinner);
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta <= alpha) break;
      }
      return minEval;
    }
  }

  List<Move> _getValidMoves(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      int? activeSubBoardIndex,
      ) {
    final moves = <Move>[];

    // Fallback if target board is not playable
    if (activeSubBoardIndex != null &&
        (subBoardWinners[activeSubBoardIndex] != null ||
            board[activeSubBoardIndex].every((cell) => cell != null))) {
      activeSubBoardIndex = null;
    }

    for (int boardIndex = 0; boardIndex < 9; boardIndex++) {
      if (subBoardWinners[boardIndex] != null) continue;
      if (activeSubBoardIndex != null && boardIndex != activeSubBoardIndex) continue;

      for (int cellIndex = 0; cellIndex < 9; cellIndex++) {
        if (board[boardIndex][cellIndex] == null) {
          moves.add(Move(boardIndex, cellIndex, Player.two, activeSubBoardIndex));
        }
      }
    }

    return moves;
  }

  bool checkDraw(subBoards, subBoardWinners) =>
      subBoardWinners.every(
            (winner) =>
        winner != null ||
            !subBoards[subBoardWinners.indexOf(winner)].contains(null),
      ) &&
          checkOverallWinner(subBoardWinners) == null;

  Player? checkOverallWinner(subBoardWinners) {
    for (final player in [Player.one, Player.two]) {
      if (checkWin(subBoardWinners, player)) {
        return player;
      }
    }
    return null;
  }

  void _applyMove(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Move move,
      Player player,
      ) {
    board[move.boardIndex][move.cellIndex] = player;
    if (checkWin(board[move.boardIndex], player)) {
      subBoardWinners[move.boardIndex] = player;
    }
  }

  void _undoMove(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Move move,
      Player? previousWinner,
      ) {
    board[move.boardIndex][move.cellIndex] = null;
    subBoardWinners[move.boardIndex] = previousWinner;
  }

  Player _switchPlayer(Player player) {
    return player == Player.one ? Player.two : Player.one;
  }

  int _evaluateBoard(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Player aiPlayer,
      ) {
    int score = 0;

    for (int i = 0; i < 9; i++) {
      if (subBoardWinners[i] == aiPlayer) {
        score += 10;
      } else if (subBoardWinners[i] != null) {
        score -= 10;
      }

      for (int cell = 0; cell < 9; cell++) {
        if (board[i][cell] == aiPlayer) {
          score += 1;
        } else if (board[i][cell] != null && board[i][cell] != aiPlayer) {
          score -= 1;
        }
      }
    }

    return score;
  }
}
