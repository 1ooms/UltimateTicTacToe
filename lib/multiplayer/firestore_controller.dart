import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreController {
  final FirebaseFirestore instance;

  FirestoreController({required this.instance}) {}

  void dispose() {}

  Future<void> _updateFirestoreFromLocal() async {}

  void _updateLocalFromFirestore() {}
}

class FirebaseControllerException implements Exception {
  final String message;

  FirebaseControllerException(this.message);

  @override
  String toString() => 'FirebaseControllerException: $message';
}
