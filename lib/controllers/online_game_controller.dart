import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ultimate_tic_tac_toe/models/enum/lobby_state.dart';
import '../models/game_setup.dart';
import '../models/game_data.dart';
import '../models/lobby_data.dart';
import '../controllers/game_controller.dart';
import 'lobby_controller.dart';

class OnlineGameController {
  late LobbyController lobbyController;

  String? currentLobbyCode;
  bool isHost = false;

  StreamSubscription? _lobbySubscription;
  GameController? _gameController;
  void Function(String)? onOnlineSessionEnded;
  void Function()? onGameRestarted;

  OnlineGameController() {
    lobbyController = LobbyController(instance: FirebaseFirestore.instance);
  }

  Future<bool> initialize() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInAnonymously();
        user = userCredential.user;
      }
      return user != null;
    } catch (e) {
      return false;
    }
  }

  Future<String> hostGame() async {
    isHost = true;
    currentLobbyCode = await lobbyController.createLobby();
    return currentLobbyCode!;
  }

  Future<bool> joinGame(String lobbyCode) async {
    isHost = false;
    final success = await lobbyController.joinLobby(lobbyCode);
    if (success) {
      currentLobbyCode = lobbyCode;
    }
    return success;
  }

  Future<void> leaveGame() async {
    if (currentLobbyCode != null) {
      if (isHost) {
        await lobbyController.deleteLobby(currentLobbyCode!);
      } else {
        await lobbyController.leaveLobby(currentLobbyCode!);
      }
      currentLobbyCode = null;
    }
  }

  Future<void> stopHosting() async {
    if (currentLobbyCode != null) {
      await lobbyController.deleteLobby(currentLobbyCode!);
      currentLobbyCode = null;
    }
  }

  Future<void> startGame(GameSetup setup) async {
    if (currentLobbyCode != null && isHost) {
      await lobbyController.startGame(currentLobbyCode!, setup);
    }
  }

  Future<void> sendGameData() async {
    if (currentLobbyCode != null && _gameController != null) {
      await lobbyController.updateGameData(
        currentLobbyCode!,
        extractGameData(),
      );
    }
  }

  Stream<DocumentSnapshot>? getLobbyStream() {
    if (currentLobbyCode == null) return null;
    return lobbyController.getLobbyStream(currentLobbyCode!);
  }

  Future<void> setOtherPlayerLeft() async {
    if (currentLobbyCode != null) {
      await lobbyController.setGameState(
        currentLobbyCode!,
        LobbyState.otherPlayerLeft.name,
      );
    }
  }

  Future<void> undoMove() async {
    if (currentLobbyCode != null && _gameController != null) {
      final gameData = extractGameData();
      final move = gameData.moveHistory.removeLast();
      gameData.subBoardWinners[move.boardIndex] = null;
      gameData.subBoards[move.boardIndex][move.cellIndex] = null;
      gameData.currentPlayer = move.player;
      gameData.activeSubBoardIndex = move.activeBoardIndex;

      await lobbyController.updateGameData(
        currentLobbyCode!,
        gameData,
      );
    }
  }

  void syncWith(
    GameController gameController, {
    required void Function(String) onOnlineSessionEnded,
    required void Function() onGameRestarted,
  }) {
    _gameController = gameController;
    this.onOnlineSessionEnded = onOnlineSessionEnded;
    this.onGameRestarted = onGameRestarted;
    _listenOtherPlayerTurn();
  }

  void cancelSync() {
    _lobbySubscription?.cancel();
    _lobbySubscription = null;
    _gameController = null;
  }

  Future<void> _listenOtherPlayerTurn() async {
    _lobbySubscription?.cancel();
    _lobbySubscription = getLobbyStream()?.listen((event) {
      if (!event.exists) return;
      final data = LobbyData.fromJson(event.data() as Map<String, dynamic>);

      if (data.state == LobbyState.otherPlayerLeft.name ||
          (isHost == true && data.state == LobbyState.waiting.name)) {
        onOnlineSessionEnded?.call(currentLobbyCode!);
        return;
      }

      if (isHost != false &&
          data.gameSetup != null &&
          _gameController != null) {
        final newSetup = data.gameSetup!;
        _gameController!.gameSetup.player1 = newSetup.player1;
        _gameController!.gameSetup.player2 = newSetup.player2;
        _gameController!.gameSetup.player1Starts = newSetup.player1Starts;
        _gameController!.notifyUI();
      }

      if (data.gameData == null) {
        if (_gameController != null &&
            _gameController!.moveHistory.isNotEmpty) {
          onGameRestarted?.call();
          _gameController!.resetAndStartNewGame(_gameController!.gameSetup);
        }
      } else {
        if (_gameController != null) {
          final parsedGameData = data.gameData!;
          if (parsedGameData.moveHistory.length !=
              _gameController!.moveHistory.length) {
            _applyGameData(parsedGameData);
          }
        }
      }
    });
  }

  GameData extractGameData() {
    return GameData(
      currentPlayer: _gameController!.currentPlayer,
      activeSubBoardIndex: _gameController!.activeSubBoardIndex,
      subBoardWinners: _gameController!.subBoardWinners,
      subBoards: _gameController!.subBoards,
      moveHistory: _gameController!.moveHistory,
      gameFinished: _gameController!.gameFinished,
      overallWinner: _gameController!.overallWinner,
    );
  }

  void _applyGameData(GameData data) {
    if (_gameController == null) return;

    final bool wasFinished = _gameController!.gameFinished;

    _gameController!.currentPlayer = data.currentPlayer;
    _gameController!.activeSubBoardIndex = data.activeSubBoardIndex;
    _gameController!.subBoardWinners = List.from(data.subBoardWinners);
    for (int i = 0; i < 9; i++) {
      _gameController!.subBoards[i] = List.from(data.subBoards[i]);
    }
    _gameController!.moveHistory = List.from(data.moveHistory);
    _gameController!.gameFinished = data.gameFinished;
    _gameController!.overallWinner = data.overallWinner;

    _gameController!.notifyUI();

    if (!wasFinished && _gameController!.gameFinished) {
      if (_gameController!.overallWinner != null) {
        _gameController!.onWin?.call(_gameController!.overallWinner!);
      } else {
        _gameController!.onDraw?.call();
      }
    }
  }
}
