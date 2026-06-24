import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_setup.dart';
import 'lobby_controller.dart';

class OnlineGameController {
  late LobbyController lobbyController;

  String? currentLobbyCode;
  bool isHost = false;

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

  Future<void> sendGameData(Map<String, dynamic> gameData) async {
    if (currentLobbyCode != null) {
      await lobbyController.updateGameData(currentLobbyCode!, gameData);
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
}
