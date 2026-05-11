import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/game_setup.dart';

class LobbyController {
  final FirebaseFirestore instance;

  LobbyController({required this.instance});

  void dispose() {}

  Future<String> createLobby() async {
    final String hostId = Uuid().v4();
    final lobbyCode = generatePassCode();
    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);

    await lobbyRef.set({'hostId': hostId, 'guestId': null, 'state': 'waiting'});

    return lobbyCode;
  }

  Future<bool> joinLobby(String lobbyCode) async {
    final String guestId = Uuid().v4();

    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);

    final doc = await lobbyRef.get();

    if (!doc.exists) {
      return false;
    }

    await instance.runTransaction((transaction) async {
      final snapShot = await transaction.get(lobbyRef);

      if (!snapShot.exists) return false;

      final data = snapShot.data() as Map<String, dynamic>;

      if (data['guestId'] != null) {
        return false;
      }

      transaction.update(lobbyRef, {'guestId': guestId, 'state': 'ready'});
    });

    return true;
  }

  Future<void> deleteLobby(String lobbyCode) async {
    await instance.collection('lobbies').doc(lobbyCode).delete();
  }

  Future<void> leaveLobby(String lobbyCode) async {
    final lobbyRef = instance.collection('lobbies').doc(lobbyCode);
    await lobbyRef.update({'guestId': null, 'state': 'waiting'});
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
