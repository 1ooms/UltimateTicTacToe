import 'dart:math';

import 'package:ultimate_tic_tac_toe/data/win_patterns.dart';

import '../enum/bot_difficulty.dart';
import '../enum/player.dart';
import '../move.dart';
import '../move_parameters.dart';

Map<String, dynamic>? chooseBotMove(Map<String, dynamic> moveParametersJson) {
  final moveParameters = MoveParameters.fromJson(moveParametersJson);

  final board = moveParameters.subBoards;
  final subBoardWinners = moveParameters.subBoardWinners;
  final botPlayerNumber = moveParameters.botPlayer;
  final activeSubBoardIndex = moveParameters.activeSubBoardIndex;
  final difficulty = moveParameters.difficulty;

  final BotPlayer botPlayer = BotPlayer(difficulty: difficulty);

  if (subBoardWinners.every((value) => value == null) &&
      activeSubBoardIndex == null) {
    // First Bot move --> every move is optimal, so just perform a random one
    Move? move = botPlayer.randomMove(
      board,
      subBoardWinners,
      activeSubBoardIndex,
    );
    return (move != null) ? move.toJson() : null;
  }

  switch (difficulty) {
    case BotDifficulty.easy:
      Move? move = botPlayer.randomMove(
        board,
        subBoardWinners,
        activeSubBoardIndex,
      );
      return (move != null) ? move.toJson() : null;

    case BotDifficulty.medium:
      Move? move = botPlayer.minimaxMove(
        board,
        subBoardWinners,
        botPlayerNumber,
        activeSubBoardIndex,
        maxDepth: 2,
      );
      return (move != null) ? move.toJson() : null;

    case BotDifficulty.hard:
      Move? move = botPlayer.minimaxMove(
        board,
        subBoardWinners,
        botPlayerNumber,
        activeSubBoardIndex,
        maxDepth: 4,
      );
      return (move != null) ? move.toJson() : null;

    case BotDifficulty.expert:
      Move? move = botPlayer.minimaxMove(
        board,
        subBoardWinners,
        botPlayerNumber,
        activeSubBoardIndex,
        maxDepth: 9,
      );
      return (move != null) ? move.toJson() : null;
  }
}

class BotPlayer {
  final BotDifficulty difficulty;

  BotPlayer({required this.difficulty});

  final Random _random = Random();

  Move? randomMove(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      int? activeSubBoardIndex,
      ) {
    final validMoves = _getValidMoves(
      board,
      subBoardWinners,
      activeSubBoardIndex,
    );

    if (validMoves.isEmpty) return null;
    return validMoves[_random.nextInt(validMoves.length)];
  }

  Move? minimaxMove(
      List<List<Player?>> board,
      List<Player?> subBoardWinners,
      Player botPlayer,
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

    for (final move in _getValidMoves(
      board,
      subBoardWinners,
      activeSubBoardIndex,
    )) {
      final prevWinner = subBoardWinners[move.boardIndex];
      _applyMove(board, subBoardWinners, move, botPlayer);

      int score = _minimax(
        board,
        subBoardWinners,
        _switchPlayer(botPlayer),
        move.cellIndex,
        1,
        maxDepth,
        -1000000,
        1000000,
        botPlayer,
      );

      _undoMove(board, subBoardWinners, move, prevWinner);

      if (score > bestScore) {
        bestScore = score;
        bestMoves.clear();
        bestMoves.add(move);
      } else if (score == bestScore) {
        bestMoves.add(move);
      }
    }

    Random random = Random();
    int randomBestMoveIndex = random.nextInt(bestMoves.length);

    // print("Considered ${bestMoves.length} moves");

    // for (final move in bestMoves) {
    //   print("Move: ${move.boardIndex}, ${move.cellIndex}");
    // }

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
      Player botPlayer,
      ) {
    // Fallback if sub-board is unplayable
    if (activeSubBoardIndex != null &&
        (subBoardWinners[activeSubBoardIndex] != null ||
            board[activeSubBoardIndex].every((cell) => cell != null))) {
      activeSubBoardIndex = null;
    }

    Player? winner = checkOverallWinner(subBoardWinners);
    if (winner != null) {
      if (winner == botPlayer) {
        return 1000 - depth;
      } else {
        return -1000 + depth;
      }
    }

    if (checkDraw(board, subBoardWinners)) return 0;
    if (depth >= maxDepth) {
      return _evaluateBoard(board, subBoardWinners, botPlayer);
    }

    if (currentPlayer == botPlayer) {
      int maxEval = -1000000;
      for (final move in _getValidMoves(
        board,
        subBoardWinners,
        activeSubBoardIndex,
      )) {
        final prevWinner = subBoardWinners[move.boardIndex];
        _applyMove(board, subBoardWinners, move, currentPlayer);
        int eval = _minimax(
          board,
          subBoardWinners,
          _switchPlayer(currentPlayer),
          move.cellIndex,
          depth + 1,
          maxDepth,
          alpha,
          beta,
          botPlayer,
        );
        _undoMove(board, subBoardWinners, move, prevWinner);
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta <= alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (final move in _getValidMoves(
        board,
        subBoardWinners,
        activeSubBoardIndex,
      )) {
        final prevWinner = subBoardWinners[move.boardIndex];
        _applyMove(board, subBoardWinners, move, currentPlayer);
        int eval = _minimax(
          board,
          subBoardWinners,
          _switchPlayer(currentPlayer),
          move.cellIndex,
          depth + 1,
          maxDepth,
          alpha,
          beta,
          botPlayer,
        );
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
      if (activeSubBoardIndex != null && boardIndex != activeSubBoardIndex) {
        continue;
      }

      for (int cellIndex = 0; cellIndex < 9; cellIndex++) {
        if (board[boardIndex][cellIndex] == null) {
          moves.add(
            Move(boardIndex, cellIndex, Player.two, activeSubBoardIndex),
          );
        }
      }
    }

    return moves;
  }

  bool checkWin(List<Player?> board, Player player) =>
      winPatterns.any((pattern) => pattern.every((i) => board[i] == player));

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
      Player botPlayer,
      ) {
    int score = 0;

    for (int i = 0; i < 9; i++) {
      if (subBoardWinners[i] == botPlayer) {
        score += 10;
      } else if (subBoardWinners[i] != null) {
        score -= 10;
      }

      for (int cell = 0; cell < 9; cell++) {
        if (board[i][cell] == botPlayer) {
          score += 1;
        } else if (board[i][cell] != null && board[i][cell] != botPlayer) {
          score -= 1;
        }
      }
    }

    return score;
  }
}