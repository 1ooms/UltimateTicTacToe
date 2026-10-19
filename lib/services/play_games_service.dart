import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:games_services/games_services.dart';

/// Service interface/wrapper for Google Play Games Saved Games integration.
class PlayGamesService {
  static const String statsSaveSlotName = 'player_stats';

  bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  /// Signs the player into Google Play Games.
  Future<bool> signIn() async {
    if (!isSupportedPlatform) return false;

    try {
      final result = await GameAuth.signIn();
      developer.log('Play Games sign in result: $result', name: 'PlayGamesService');
      return await isSignedIn();
    } catch (e, stack) {
      developer.log(
        'Google Play Games sign-in failed',
        name: 'PlayGamesService',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Checks if the player is currently signed in.
  Future<bool> isSignedIn() async {
    if (!isSupportedPlatform) return false;

    try {
      return await GameAuth.isSignedIn;
    } catch (e) {
      return false;
    }
  }

  /// Retrieves the player's display name, if signed in.
  Future<String?> getPlayerName() async {
    if (!isSupportedPlatform) return null;

    try {
      return await Player.getPlayerName();
    } catch (e) {
      return null;
    }
  }

  /// Loads raw saved game data from Google Play Games.
  Future<String?> loadSavedGame([String name = statsSaveSlotName]) async {
    if (!isSupportedPlatform) return null;

    try {
      final data = await SaveGame.loadGame(name: name);
      developer.log('Loaded saved game "$name"', name: 'PlayGamesService');
      return data;
    } catch (e, stack) {
      developer.log(
        'Failed to load saved game "$name"',
        name: 'PlayGamesService',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Saves raw game data to Google Play Games.
  Future<bool> saveGame({
    String name = statsSaveSlotName,
    required String data,
    String? description,
  }) async {
    if (!isSupportedPlatform) return false;

    try {
      await SaveGame.saveGame(
        name: name,
        data: data,
        description: description ?? 'Ultimate Tic Tac Toe Player Statistics',
      );
      developer.log('Saved game "$name" successfully', name: 'PlayGamesService');
      return true;
    } catch (e, stack) {
      developer.log(
        'Failed to save game "$name"',
        name: 'PlayGamesService',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }
}
