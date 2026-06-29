import 'dart:math';

import 'package:ultimate_tic_tac_toe/data/win_patterns.dart';

import '../../models/enum/bot_difficulty.dart';
import '../../models/enum/player.dart';
import '../../models/move.dart';
import '../../models/move_parameters.dart';

Map<String, dynamic>? chooseBotMove(
  BotPlayer botPlayer,
  MoveParameters moveParameters,
) {
  final board = moveParameters.subBoards;
  final subBoardWinners = moveParameters.subBoardWinners;
  final botPlayerNumber = moveParameters.botPlayer;
  final activeSubBoardIndex = moveParameters.activeSubBoardIndex;
  final difficulty = moveParameters.difficulty;

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

  late List<List<Player?>> _board;
  late List<Player?> _subBoardWinners;
  late Player _botPlayer;

  BotPlayer({required this.difficulty});

  final Random _random = Random();

  Move? randomMove(
    List<List<Player?>> board,
    List<Player?> subBoardWinners,
    int? activeSubBoardIndex,
  ) {
    _board = board;
    _subBoardWinners = subBoardWinners;
    final validMoves = _getValidMoves(activeSubBoardIndex);

    if (validMoves.isEmpty) return null;

    return validMoves[_random.nextInt(validMoves.length)];
  }

  Move? minimaxMove(
    List<List<Player?>> board,
    List<Player?> subBoardWinners,
    Player botPlayer,
    int? activeSubBoardIndex, {
    required int maxDepth,
    int maxTimeMs = 2000,
  }) {
    _board = board;
    _subBoardWinners = subBoardWinners;
    _botPlayer = botPlayer;

    final stopwatch = Stopwatch()..start();

    Move? bestMoveSoFar;
    List<Move> validMoves = _getValidMoves(activeSubBoardIndex);
    if (validMoves.isEmpty) return null;

    try {
      for (int currentDepth = 1; currentDepth <= maxDepth; currentDepth++) {
        int bestScore = -1000000;
        List<Move> bestMoves = [];

        int alpha = -1000000;
        int beta = 1000000;

        // Evaluate the best move from the previous iteration first
        if (bestMoveSoFar != null) {
          validMoves.remove(bestMoveSoFar);
          validMoves.insert(0, bestMoveSoFar);
        }

        for (final move in validMoves) {
          int score = _evaluateMove(
            move,
            botPlayer,
            1,
            currentDepth,
            alpha,
            beta,
            stopwatch,
            maxTimeMs,
          );

          if (score > bestScore) {
            bestScore = score;
            bestMoves.clear();
            bestMoves.add(move);
          } else if (score == bestScore) {
            bestMoves.add(move);
          }
          
          alpha = max(alpha, bestScore);
        }

        if (bestMoves.isNotEmpty) {
          bestMoveSoFar = bestMoves[_random.nextInt(bestMoves.length)];
        }

        // If winning move is found, no need to search deeper
        if (bestScore > 500) {
          break;
        }
      }
    } catch (e) {
      if (e is SearchTimeoutException) {
        // print("Search timed out after ${stopwatch.elapsedMilliseconds} ms.");
      } else {
        rethrow;
      }
    }

    stopwatch.stop();
    // print("minimaxMove completed in ${stopwatch.elapsedMilliseconds} ms");

    // Fallback for timeout before depth 1 completed
    return bestMoveSoFar ?? validMoves[_random.nextInt(validMoves.length)];
  }

  int _minimax(
    Player currentPlayer,
    int? activeSubBoardIndex,
    int depth,
    int maxDepth,
    int alpha,
    int beta,
    Stopwatch stopwatch,
    int maxTimeMs,
  ) {
    if (stopwatch.elapsedMilliseconds > maxTimeMs) {
      throw SearchTimeoutException();
    }

    Player? winner = checkOverallWinner();
    if (winner != null) {
      if (winner == _botPlayer) {
        return 1000 - depth;
      } else {
        return -1000 + depth;
      }
    }

    if (checkDraw()) return 0;
    if (depth >= maxDepth) {
      return _evaluateBoard();
    }

    if (currentPlayer == _botPlayer) {
      int maxEval = -1000000;
      for (final move in _getValidMoves(activeSubBoardIndex)) {
        int eval = _evaluateMove(
          move,
          currentPlayer,
          depth,
          maxDepth,
          alpha,
          beta,
          stopwatch,
          maxTimeMs,
        );
        maxEval = max(maxEval, eval);
        alpha = max(alpha, eval);
        if (beta < alpha) break;
      }
      return maxEval;
    } else {
      int minEval = 1000000;
      for (final move in _getValidMoves(activeSubBoardIndex)) {
        int eval = _evaluateMove(
          move,
          currentPlayer,
          depth,
          maxDepth,
          alpha,
          beta,
          stopwatch,
          maxTimeMs,
        );
        minEval = min(minEval, eval);
        beta = min(beta, eval);
        if (beta < alpha) break;
      }
      return minEval;
    }
  }

  int _evaluateMove(
    Move move,
    Player currentPlayer,
    int depth,
    int maxDepth,
    int alpha,
    int beta,
    Stopwatch stopwatch,
    int maxTimeMs,
  ) {
    final prevWinner = _subBoardWinners[move.boardIndex];
    _applyMove(move, currentPlayer);
    int eval = _minimax(
      _switchPlayer(currentPlayer),
      move.cellIndex,
      depth + 1,
      maxDepth,
      alpha,
      beta,
      stopwatch,
      maxTimeMs,
    );
    _undoMove(move, prevWinner);
    return eval;
  }

  List<Move> _getValidMoves(int? activeSubBoardIndex) {
    final moves = <Move>[];

    // Fallback if target board is not playable
    if (activeSubBoardIndex != null &&
        (_subBoardWinners[activeSubBoardIndex] != null ||
            _board[activeSubBoardIndex].every((cell) => cell != null))) {
      activeSubBoardIndex = null;
    }

    for (int boardIndex = 0; boardIndex < 9; boardIndex++) {
      if (_subBoardWinners[boardIndex] != null) continue;
      if (activeSubBoardIndex != null && boardIndex != activeSubBoardIndex) {
        continue;
      }

      for (int cellIndex = 0; cellIndex < 9; cellIndex++) {
        if (_board[boardIndex][cellIndex] == null) {
          moves.add(
            Move(boardIndex, cellIndex, Player.two, activeSubBoardIndex),
          );
        }
      }
    }

    // Order moves for Alpha-Beta Pruning
    // Prioritize center (4), then corners (0, 2, 6, 8), then edges (1, 3, 5, 7)
    int getMoveValue(Move m) {
      if (m.cellIndex == 4) return 3; // Center
      if (m.cellIndex == 0 ||
          m.cellIndex == 2 ||
          m.cellIndex == 6 ||
          m.cellIndex == 8) {
        return 2; // Corners
      }
      return 1; // Edges
    }

    moves.sort((a, b) => getMoveValue(b).compareTo(getMoveValue(a)));

    return moves;
  }

  bool checkWin(List<Player?> board, Player player) =>
      winPatterns.any((pattern) => pattern.every((i) => board[i] == player));

  bool checkDraw() {
    for (int i = 0; i < 9; i++) {
      if (_subBoardWinners[i] == null && _board[i].contains(null)) {
        return false;
      }
    }
    return checkOverallWinner() == null;
  }

  Player? checkOverallWinner() {
    for (final player in [Player.one, Player.two]) {
      if (checkWin(_subBoardWinners, player)) {
        return player;
      }
    }
    return null;
  }

  void _applyMove(Move move, Player player) {
    _board[move.boardIndex][move.cellIndex] = player;
    if (checkWin(_board[move.boardIndex], player)) {
      _subBoardWinners[move.boardIndex] = player;
    }
  }

  void _undoMove(Move move, Player? previousWinner) {
    _board[move.boardIndex][move.cellIndex] = null;
    _subBoardWinners[move.boardIndex] = previousWinner;
  }

  Player _switchPlayer(Player player) {
    return player == Player.one ? Player.two : Player.one;
  }

  int _evaluateBoard() {
    int score = 0;

    for (int i = 0; i < 9; i++) {
      if (_subBoardWinners[i] == _botPlayer) {
        score += 10;
      } else if (_subBoardWinners[i] != null) {
        score -= 10;
      }

      for (int cell = 0; cell < 9; cell++) {
        if (_board[i][cell] == _botPlayer) {
          score += 1;
        } else if (_board[i][cell] != null && _board[i][cell] != _botPlayer) {
          score -= 1;
        }
      }
    }

    return score;
  }
}

class SearchTimeoutException implements Exception {}
