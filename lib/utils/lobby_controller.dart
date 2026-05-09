import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class LobbyController {
  final FirebaseFirestore instance;
  final FirebaseAuth auth;

  LobbyController({required this.instance, required this.auth});

  void dispose() {}

  Future<String> createLobby() async {
    final String hostId = Uuid().v4();
    final lobbyCode = generatePassCode();
    final lobbyRef = instance
        .collection('lobbies')
        .doc(lobbyCode);

    await lobbyRef.set({
      'hostId': hostId,
      'guestId': null,
      'state': 'waiting',
      'hostReady': true,
      'guestReady': false,
    });

    return lobbyCode;
  }

  Future<bool> joinLobby(String lobbyCode) async {
    final String guestId = Uuid().v4();

    final lobbyRef = instance
        .collection('lobbies')
        .doc(lobbyCode);

    await instance.runTransaction((transaction) async {
      final snapShot = await transaction.get(lobbyRef);

      if (!snapShot.exists) return false;

      final data = snapShot.data() as Map<String, dynamic>;

      if (data['guestId'] != null) {
        return false;
      }

      transaction.update(lobbyRef, {
        'guestId': guestId,
        'state': 'ready',
        'guestReady': true,
      });
    });

    return true;
  }

  Future<void> deleteLobby(String lobbyCode) async {
    await instance.collection('lobbies').doc(lobbyCode).delete();
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
}
