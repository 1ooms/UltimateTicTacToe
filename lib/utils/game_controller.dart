import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:ultimate_tic_tac_toe/data/win_patterns.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/game_setup.dart';
import 'package:ultimate_tic_tac_toe/models/move.dart';
import 'package:ultimate_tic_tac_toe/models/move_parameters.dart';
import 'package:ultimate_tic_tac_toe/utils/audio_controller.dart';
import 'package:ultimate_tic_tac_toe/utils/bot_player/bot_isolate.dart';

part 'bot_game_handler.dart';

class GameController extends ChangeNotifier with BotHandler {
  GameMode gameMode;
  GameSetup gameSetup;
  Player? localPlayer;

  final void Function(Player winner)? onWin;
  final void Function()? onDraw;
  final void Function()? onGameStateChanged;

  late List<List<Player?>> subBoards;
  late List<Player?> subBoardWinners;
  List<Move> moveHistory = [];
  late Player currentPlayer;
  int? activeSubBoardIndex;
  Player? overallWinner;

  bool gameFinished = false;

  AudioController audioController = AudioController();

  GameController({
    required this.gameMode,
    required this.gameSetup,
    this.localPlayer,
    this.onWin,
    this.onDraw,
    this.onGameStateChanged,
  }) {
    _initializeGame();

    if (gameMode == GameMode.bot) {
      initBot();
    }

    if (gameMode == GameMode.bot && currentPlayer == Player.two) {
      makeBotMove();
    }
  }

  void _initializeGame() {
    subBoards = List.generate(9, (ctx) => List<Player?>.filled(9, null));
    subBoardWinners = List<Player?>.filled(9, null);
    currentPlayer = gameSetup.player1Starts ? Player.one : Player.two;
    activeSubBoardIndex = null;
    gameFinished = false;
    overallWinner = null;
  }

  void resetAndStartNewGame(GameSetup setup) {
    gameSetup.player1 = setup.player1;
    gameSetup.player2 = setup.player2;
    gameSetup.player1Starts = setup.player1Starts;
    gameSetup.botDifficulty = setup.botDifficulty;

    moveHistory.clear();
    _initializeGame();
    if (gameMode == GameMode.bot && currentPlayer == Player.two) {
      makeBotMove();
    }
    notifyListeners();
  }

  void handleTap(int boardIndex, int cellIndex) {
    if (aiThinking) return;
    if (gameMode == GameMode.online && currentPlayer != localPlayer) {
      return;
    }

    if (!isValidMove(boardIndex, cellIndex)) return;

    audioController.playSound("assets/sounds/tap.wav");

    subBoards[boardIndex][cellIndex] = currentPlayer;
    moveHistory.add(
      Move(boardIndex, cellIndex, currentPlayer, activeSubBoardIndex),
    );

    // check for winner
    if (checkWin(subBoards[boardIndex], currentPlayer)) {
      subBoardWinners[boardIndex] = currentPlayer;

      if (checkOverallWinner() != null) {
        overallWinner = currentPlayer;
        gameFinished = true;
        onWin?.call(currentPlayer);
        onGameStateChanged?.call();
        notifyListeners();
        return;
      }
    }

    // check for draw
    if (checkDraw()) {
      gameFinished = true;
      onDraw?.call();
      onGameStateChanged?.call();
      notifyListeners();
      return;
    }

    activeSubBoardIndex = cellIndex;

    // check if new board available
    if (subBoardWinners[activeSubBoardIndex!] != null ||
        !subBoards[activeSubBoardIndex!].contains(null)) {
      activeSubBoardIndex = null;
    }

    // switch player turn
    currentPlayer = currentPlayer == Player.one ? Player.two : Player.one;

    if (gameMode == GameMode.bot && currentPlayer == Player.two) {
      makeBotMove();
    }

    onGameStateChanged?.call();
    notifyListeners();
  }

  void notifyUI() {
    notifyListeners();
  }

  bool isValidMove(int boardIndex, int cellIndex) {
    if (gameFinished) return false;
    final boardPlayable =
        subBoardWinners[boardIndex] == null &&
        (activeSubBoardIndex == null || boardIndex == activeSubBoardIndex);
    final cellEmpty = subBoards[boardIndex][cellIndex] == null;
    return boardPlayable && cellEmpty;
  }

  bool checkWin(List<Player?> board, Player player) =>
      winPatterns.any((pattern) => pattern.every((i) => board[i] == player));

  bool checkDraw() {
    if (checkOverallWinner() != null) return false;

    for (int i = 0; i < 9; i++) {
      if (subBoardWinners[i] == null && subBoards[i].contains(null)) {
        return false;
      }
    }
    return true;
  }

  Player? checkOverallWinner() {
    for (final player in [Player.one, Player.two]) {
      if (checkWin(subBoardWinners, player)) {
        return player;
      }
    }
    return null;
  }

  void undoMove() {
    if (moveHistory.isEmpty || aiThinking) return;

    audioController.playSound("assets/sounds/tap.wav");

    int movesToUndo = gameMode == GameMode.bot ? 2 : 1;

    for (int i = 0; i < movesToUndo && moveHistory.isNotEmpty; i++) {
      final move = moveHistory.removeLast();
      subBoards[move.boardIndex][move.cellIndex] = null;
      subBoardWinners[move.boardIndex] = null;
      currentPlayer = move.player;
      activeSubBoardIndex = move.activeBoardIndex;
    }

    gameFinished = false;
    notifyListeners();

    if (gameMode == GameMode.bot && currentPlayer == Player.two) {
      makeBotMove();
    }
  }
}
