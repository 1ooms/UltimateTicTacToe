import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import '../models/game_setup.dart';

class LobbyController {
  final FirebaseDatabase instance;

  LobbyController({required this.instance});

  void dispose() {}

  Future<String> createLobby() async {
    final lobbyCode = generatePassCode();
    final lobbyRef = instance.ref('lobbies/$lobbyCode');

    await lobbyRef.set({'state': 'waiting'});

    return lobbyCode;
  }

  Future<bool> joinLobby(String lobbyCode) async {
    final lobbyRef = instance.ref('lobbies/$lobbyCode');

    final doc = await lobbyRef.get();

    if (!doc.exists) {
      return false;
    }

    final TransactionResult result = await lobbyRef.runTransaction((Object? lobby) {
      if (lobby == null) {
        return Transaction.abort();
      }

      Map<String, dynamic> data = Map<String, dynamic>.from(lobby as Map);

      if (data['state'] != 'waiting') {
        return Transaction.abort();
      }

      data['state'] = 'ready';
      return Transaction.success(data);
    });

    return result.committed;
  }

  Future<void> deleteLobby(String lobbyCode) async {
    await instance.ref('lobbies/$lobbyCode').remove();
  }

  Future<void> leaveLobby(String lobbyCode) async {
    final lobbyRef = instance.ref('lobbies/$lobbyCode');
    await lobbyRef.update({'state': 'waiting'});
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

  Stream<DatabaseEvent> getLobbyStream(String lobbyCode) {
    return instance.ref('lobbies/$lobbyCode').onValue;
  }

  Future<void> setGameState(String lobbyCode, String state) async {
    await instance.ref('lobbies/$lobbyCode').update({
      'state': state,
    });
  }

  Future<void> startGame(String lobbyCode, GameSetup setup) async {
    await instance.ref('lobbies/$lobbyCode').update({
      'state': 'playing',
      'gameSetup': setup.toJson(),
      'gameData': null,
    });
  }

  Future<void> updateGameData(
    String lobbyCode,
    Map<String, dynamic> gameData,
  ) async {
    await instance.ref('lobbies/$lobbyCode').update({
      'gameData': gameData,
    });
  }

  Future<GameSetup?> getGameSetup(String lobbyCode) async {
    final doc = await instance.ref('lobbies/$lobbyCode').get();
    if (doc.exists) {
      final data = doc.value as Map?;
      if (data != null && data['gameSetup'] != null) {
        return GameSetup.fromJson(Map<String, dynamic>.from(data['gameSetup'] as Map));
      }
    }
    return null;
  }
}
