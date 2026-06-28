import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/enum/lobby_state.dart';
import '../models/game_setup.dart';
import '../models/game_data.dart';
import '../models/lobby_data.dart';

class LobbyController {
  final FirebaseFirestore instance;
  final String lobbies = 'lobbies';

  LobbyController({required this.instance});

  void dispose() {}

  Future<String> createLobby() async {
    final lobbyCode = generatePassCode();
    final lobbyRef = instance.collection(lobbies).doc(lobbyCode);

    await lobbyRef.set(
      LobbyData(
        state: LobbyState.waiting.name,
        hostId: FirebaseAuth.instance.currentUser?.uid,
      ).toJson(),
    );

    return lobbyCode;
  }

  Future<bool> joinLobby(String lobbyCode) async {
    final lobbyRef = instance.collection(lobbies).doc(lobbyCode);

    final doc = await lobbyRef.get();

    if (!doc.exists) {
      return false;
    }

    final result = await instance.runTransaction<bool>((transaction) async {
      final snapShot = await transaction.get(lobbyRef);

      if (!snapShot.exists) return false;

      final lobbyData = LobbyData.fromJson(
        snapShot.data() as Map<String, dynamic>,
      );

      if (lobbyData.guestId != null ||
          lobbyData.state != LobbyState.waiting.name) {
        return false;
      }

      transaction.update(
        lobbyRef,
        LobbyData(
          guestId: FirebaseAuth.instance.currentUser?.uid,
          state: LobbyState.ready.name,
        ).toJson(),
      );

      return true;
    });

    return result;
  }

  Future<void> deleteLobby(String lobbyCode) async {
    await instance.collection(lobbies).doc(lobbyCode).delete();
  }

  Future<void> leaveLobby(String lobbyCode) async {
    final lobbyRef = instance.collection(lobbies).doc(lobbyCode);
    await lobbyRef.update(
      LobbyData(guestId: null, state: LobbyState.waiting.name).toJson(),
    );
  }

  String generatePassCode() {
    var random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

    return String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  Stream<DocumentSnapshot> getLobbyStream(String lobbyCode) {
    return FirebaseFirestore.instance
        .collection(lobbies)
        .doc(lobbyCode)
        .snapshots();
  }

  Future<void> setGameState(String lobbyCode, String state) async {
    await instance
        .collection(lobbies)
        .doc(lobbyCode)
        .update(LobbyData(state: state).toJson());
  }

  Future<void> startGame(String lobbyCode, GameSetup setup) async {
    await instance
        .collection(lobbies)
        .doc(lobbyCode)
        .update(
          LobbyData(
            state: LobbyState.playing.name,
            gameSetup: setup,
            gameData: null,
          ).toJson(),
        );
  }

  Future<void> updateGameData(String lobbyCode, GameData gameData) async {
    await instance
        .collection(lobbies)
        .doc(lobbyCode)
        .update(LobbyData(gameData: gameData).toJson());
  }

  Future<GameSetup?> getGameSetup(String lobbyCode) async {
    final doc = await instance.collection(lobbies).doc(lobbyCode).get();
    final data = LobbyData.fromJson(doc.data() as Map<String, dynamic>);
    if (data.gameSetup != null) {
      return data.gameSetup;
    }
    return null;
  }
}
