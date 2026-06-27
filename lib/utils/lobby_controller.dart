import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/game_setup.dart';

class LobbyController {
  final FirebaseFirestore instance;

  LobbyController({required this.instance});

  void dispose() {}

  Future<String> createLobby() async {
    final lobbyCode = generatePassCode();
    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);

    await lobbyRef.set({
      'state': 'waiting',
      'hostId': FirebaseAuth.instance.currentUser?.uid,
    });

    return lobbyCode;
  }

  Future<bool> joinLobby(String lobbyCode) async {
    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);

    final doc = await lobbyRef.get();

    if (!doc.exists) {
      return false;
    }

    final result = await instance.runTransaction<bool>((transaction) async {
      final snapShot = await transaction.get(lobbyRef);

      if (!snapShot.exists) return false;

      final data = snapShot.data() as Map<String, dynamic>;

      if (data['guestId'] != null || data['state'] != 'waiting') {
        return false;
      }

      transaction.update(lobbyRef, {
        'guestId': FirebaseAuth.instance.currentUser?.uid,
        'state': 'ready'
      });

      return true;
    });

    return result;
  }

  Future<void> deleteLobby(String lobbyCode) async {
    await instance.collection('lobbies').doc(lobbyCode).delete();
  }

  Future<void> leaveLobby(String lobbyCode) async {
    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);
    await lobbyRef.update({
      'guestId': null,
      'state': 'waiting'
    });
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
        .collection('lobbies')
        .doc(lobbyCode)
        .snapshots();
  }

  Future<void> setGameState(String lobbyCode, String state) async {
    await instance.collection('lobbies').doc(lobbyCode).update({
      'state': state,
    });
  }

  Future<void> startGame(String lobbyCode, GameSetup setup) async {
    await instance.collection('lobbies').doc(lobbyCode).update({
      'state': 'playing',
      'gameSetup': setup.toJson(),
      'gameData': null,
    });
  }

  Future<void> updateGameData(
      String lobbyCode,
      Map<String, dynamic> gameData,
      ) async {
    await instance.collection('lobbies').doc(lobbyCode).update({
      'gameData': gameData,
    });
  }

  Future<GameSetup?> getGameSetup(String lobbyCode) async {
    final doc = await instance.collection('lobbies').doc(lobbyCode).get();
    if (doc.exists && doc.data()?['gameSetup'] != null) {
      return GameSetup.fromJson(doc.data()?['gameSetup']);
    }
    return null;
  }
}
