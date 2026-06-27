import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/enum/player.dart';
import '../models/game_setup.dart';
import '../models/move.dart';
import 'game_controller.dart';
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
      await lobbyController.updateGameData(currentLobbyCode!, extractGameData());
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
        'other_player_left',
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
      final data = event.data() as Map<String, dynamic>;

      if (data['state'] == 'other_player_left' ||
          (isHost == true && data['state'] == 'waiting')) {
        onOnlineSessionEnded?.call(currentLobbyCode!);
        return;
      }

      final gameData = data['gameData'] as Map<String, dynamic>?;

      if (isHost != false && data['gameSetup'] != null && _gameController != null) {
        final newSetup = GameSetup.fromJson(data['gameSetup']);
        _gameController!.gameSetup.player1 = newSetup.player1;
        _gameController!.gameSetup.player2 = newSetup.player2;
        _gameController!.gameSetup.player1Starts = newSetup.player1Starts;
        _gameController!.notifyUI();
      }

      if (gameData == null) {
        if (_gameController != null && _gameController!.moveHistory.isNotEmpty) {
          onGameRestarted?.call();
          _gameController!.resetAndStartNewGame(_gameController!.gameSetup);
        }
      } else {
        if (_gameController != null) {
          final List remoteMoveHistory = gameData['moveHistory'] as List;
          if (remoteMoveHistory.length != _gameController!.moveHistory.length) {
            _applyGameData(gameData);
          }
        }
      }
    });
  }

  Map<String, dynamic> extractGameData() {
    return {
      'currentPlayer': _gameController!.currentPlayer.name,
      'activeSubBoardIndex': _gameController!.activeSubBoardIndex,
      'subBoardWinners':
          _gameController!.subBoardWinners.map((p) => p?.name).toList(),
      'subBoard1': _gameController!.subBoards[0].map((p) => p?.name).toList(),
      'subBoard2': _gameController!.subBoards[1].map((p) => p?.name).toList(),
      'subBoard3': _gameController!.subBoards[2].map((p) => p?.name).toList(),
      'subBoard4': _gameController!.subBoards[3].map((p) => p?.name).toList(),
      'subBoard5': _gameController!.subBoards[4].map((p) => p?.name).toList(),
      'subBoard6': _gameController!.subBoards[5].map((p) => p?.name).toList(),
      'subBoard7': _gameController!.subBoards[6].map((p) => p?.name).toList(),
      'subBoard8': _gameController!.subBoards[7].map((p) => p?.name).toList(),
      'subBoard9': _gameController!.subBoards[8].map((p) => p?.name).toList(),
      'moveHistory': _gameController!.moveHistory.map((m) => m.toJson()).toList(),
      'gameFinished': _gameController!.gameFinished,
      'overallWinner': _gameController!.overallWinner?.name,
    };
  }

  void _applyGameData(Map<String, dynamic> data) {
    if (_gameController == null) return;
    
    final bool wasFinished = _gameController!.gameFinished;

    _gameController!.currentPlayer = Player.values.byName(data['currentPlayer']);
    _gameController!.activeSubBoardIndex = data['activeSubBoardIndex'];
    _gameController!.subBoardWinners =
        (data['subBoardWinners'] as List)
            .map((p) => p != null ? Player.values.byName(p) : null)
            .toList();
    for (int i = 1; i <= 9; i++) {
      _gameController!.subBoards[i - 1] =
          (data['subBoard$i'] as List)
              .map((p) => p != null ? Player.values.byName(p) : null)
              .toList();
    }
    _gameController!.moveHistory =
        (data['moveHistory'] as List).map((m) {
          return Move.fromJson(Map<String, dynamic>.from(m as Map));
        }).toList();
    _gameController!.gameFinished = data['gameFinished'];
    _gameController!.overallWinner =
        data['overallWinner'] != null
            ? Player.values.byName(data['overallWinner'])
            : null;

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
