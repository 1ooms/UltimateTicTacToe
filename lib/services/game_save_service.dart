import 'dart:convert';
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';
import '../data/pref_keys.dart';
import '../models/enum/game_mode.dart';
import '../models/game_data.dart';
import '../models/game_setup.dart';
import '../models/saved_game.dart';

/// Service responsible for persisting and restoring in-progress game states.
class GameSaveService {
  final SharedPreferences? _prefs;

  const GameSaveService({SharedPreferences? prefs}) : _prefs = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  String? _keyForMode(GameMode mode) {
    switch (mode) {
      case GameMode.local:
        return PrefKeys.savedGameLocal;
      case GameMode.bot:
        return PrefKeys.savedGameBot;
      case GameMode.online:
        return null;
    }
  }

  /// Checks if there is a valid in-progress saved game for the given mode.
  Future<bool> hasSavedGame(GameMode mode) async {
    final key = _keyForMode(mode);
    if (key == null) return false;

    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return false;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      final savedGame = SavedGame.fromJson(json);
      return !savedGame.gameData.gameFinished;
    } catch (e, stack) {
      developer.log(
        'Failed to check saved game for $mode',
        name: 'GameSaveService',
        error: e,
        stackTrace: stack,
      );
      return false;
    }
  }

  /// Retrieves the saved game for the given mode, if one exists and is not finished.
  Future<SavedGame?> getSavedGame(GameMode mode) async {
    final key = _keyForMode(mode);
    if (key == null) return null;

    try {
      final prefs = await _getPrefs();
      final jsonString = prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) return null;

      final Map<String, dynamic> json = jsonDecode(jsonString);
      final savedGame = SavedGame.fromJson(json);
      if (savedGame.gameData.gameFinished) {
        await clearSavedGame(mode);
        return null;
      }
      return savedGame;
    } catch (e, stack) {
      developer.log(
        'Failed to get saved game for $mode',
        name: 'GameSaveService',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  /// Saves the current game progress for the given mode.
  Future<void> saveGame({
    required GameMode mode,
    required GameSetup setup,
    required GameData data,
  }) async {
    final key = _keyForMode(mode);
    if (key == null || data.gameFinished) return;

    try {
      final prefs = await _getPrefs();
      final savedGame = SavedGame(
        gameMode: mode,
        gameSetup: setup,
        gameData: data,
        savedAt: DateTime.now(),
      );
      final jsonString = jsonEncode(savedGame.toJson());
      await prefs.setString(key, jsonString);
    } catch (e, stack) {
      developer.log(
        'Failed to save game for $mode',
        name: 'GameSaveService',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Clears any saved game entry for the given mode.
  Future<void> clearSavedGame(GameMode mode) async {
    final key = _keyForMode(mode);
    if (key == null) return;

    try {
      final prefs = await _getPrefs();
      await prefs.remove(key);
    } catch (e, stack) {
      developer.log(
        'Failed to clear saved game for $mode',
        name: 'GameSaveService',
        error: e,
        stackTrace: stack,
      );
    }
  }
}
