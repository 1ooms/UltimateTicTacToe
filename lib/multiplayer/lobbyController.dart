import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

Future<String> createLobby(String userId) async {
  final lobbyCode = generateLobbyCode();
  final lobbyRef = FirebaseFirestore.instance.collection('lobbies').doc(lobbyCode);

  await lobbyRef.set({
    'hostId': userId,
    'createdAt': FieldValue.serverTimestamp(),
    'isGameStarted': false,
  });

  await lobbyRef.collection('players').doc(userId).set({
    'name': 'Player 1',
    'icon': 'X',
  });

  return lobbyCode;
}

String generateLobbyCode() {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  return List.generate(6, (_) => chars[Random().nextInt(chars.length)]).join();
}

Future<bool> joinLobby(String lobbyCode, String userId) async {
  final lobbyRef = FirebaseFirestore.instance.collection('lobbies').doc(lobbyCode);
  final lobbySnap = await lobbyRef.get();

  if (!lobbySnap.exists) return false;

  await lobbyRef.collection('players').doc(userId).set({
    'name': 'Player 2',
    'icon': 'O',
  });

  return true;
}

Stream<DocumentSnapshot> getLobbyStream(String lobbyCode) {
  return FirebaseFirestore.instance.collection('lobbies').doc(lobbyCode).snapshots();
}

