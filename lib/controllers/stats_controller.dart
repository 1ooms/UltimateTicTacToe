import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/pref_keys.dart';
import '../models/enum/bot_difficulty.dart';
import '../models/game_stats.dart';
import '../services/play_games_service.dart';

enum CloudSyncStatus {
  idle,
  syncing,
  synced,
  signedOut,
  error,
}

class StatsController extends ChangeNotifier {
  static final StatsController _singleton = StatsController._internal();

  factory StatsController() => _singleton;

  StatsController._internal({PlayGamesService? playGamesService})
      : _playGamesService = playGamesService ?? PlayGamesService();

  final PlayGamesService _playGamesService;

  GameStats _stats = const GameStats();
  GameStats get stats => _stats;

  CloudSyncStatus _syncStatus = CloudSyncStatus.idle;
  CloudSyncStatus get syncStatus => _syncStatus;

  String? _accountName;
  String? get accountName => _accountName;

  bool _initialized = false;

  /// Loads locally cached stats and attempts silent cloud sync.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    await _loadFromLocal();
    // Non-blocking silent background sync
    syncWithCloud(silent: true);
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = prefs.getString(PrefKeys.gameStats);
      if (statsString != null && statsString.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(statsString);
        _stats = GameStats.fromJson(json);
        notifyListeners();
      }
    } catch (e, stack) {
      developer.log(
        'Failed to load local game stats',
        name: 'StatsController',
        error: e,
        stackTrace: stack,
      );
    }
  }

  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsString = jsonEncode(_stats.toJson());
      await prefs.setString(PrefKeys.gameStats, statsString);
    } catch (e, stack) {
      developer.log(
        'Failed to save local game stats',
        name: 'StatsController',
        error: e,
        stackTrace: stack,
      );
    }
  }

  /// Records a local multiplayer match completion.
  void recordLocalGamePlayed() {
    _stats = _stats.copyWith(
      localGamesPlayed: _stats.localGamesPlayed + 1,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
  }

  /// Records an online multiplayer match completion.
  void recordOnlineGamePlayed() {
    _stats = _stats.copyWith(
      onlineGamesPlayed: _stats.onlineGamesPlayed + 1,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
  }

  /// Records a bot game completion, tracking the difficulty and outcome.
  void recordBotGamePlayed({
    required bool won,
    required BotDifficulty difficulty,
  }) {
    final updatedGamesByDiff =
        Map<BotDifficulty, int>.from(_stats.botGamesByDifficulty);
    updatedGamesByDiff[difficulty] =
        (updatedGamesByDiff[difficulty] ?? 0) + 1;

    final updatedWins = Map<BotDifficulty, int>.from(_stats.botWins);
    if (won) {
      updatedWins[difficulty] = (updatedWins[difficulty] ?? 0) + 1;
    }

    _stats = _stats.copyWith(
      botGamesPlayed: _stats.botGamesPlayed + 1,
      botGamesByDifficulty: updatedGamesByDiff,
      botWins: updatedWins,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
  }

  void _triggerCloudUpload() {
    // Only upload to cloud if signed in; do not block gameplay
    _playGamesService.isSignedIn().then((signedIn) {
      if (signedIn) {
        _uploadCurrentStats();
      }
    });
  }

  Future<void> _uploadCurrentStats() async {
    final jsonString = jsonEncode(_stats.toJson());
    await _playGamesService.saveGame(
      data: jsonString,
      description:
          'Games: ${_stats.totalGamesPlayed}, Bot Wins: ${_stats.totalBotWins}',
    );
  }

  /// Synchronizes local stats with Google Play Saved Games.
  Future<void> syncWithCloud({
    bool forceSignIn = false,
    bool silent = false,
  }) async {
    if (!_playGamesService.isSupportedPlatform) {
      _syncStatus = CloudSyncStatus.signedOut;
      notifyListeners();
      return;
    }

    try {
      if (!silent) {
        _syncStatus = CloudSyncStatus.syncing;
        notifyListeners();
      }

      bool signedIn = await _playGamesService.isSignedIn();
      if (!signedIn && forceSignIn) {
        signedIn = await _playGamesService.signIn();
      }

      if (!signedIn) {
        _syncStatus = CloudSyncStatus.signedOut;
        _accountName = null;
        notifyListeners();
        return;
      }

      _syncStatus = CloudSyncStatus.syncing;
      notifyListeners();

      _accountName = await _playGamesService.getPlayerName();

      // Load cloud save
      final cloudJsonString = await _playGamesService.loadSavedGame();
      if (cloudJsonString != null && cloudJsonString.isNotEmpty) {
        final Map<String, dynamic> cloudJson = jsonDecode(cloudJsonString);
        final cloudStats = GameStats.fromJson(cloudJson);
        // Merge monotonic values
        _stats = _stats.merge(cloudStats);
      } else {
        _stats = _stats.copyWith(lastSyncedAt: DateTime.now());
      }

      // Persist merged state locally and in cloud
      await _saveToLocal();
      await _uploadCurrentStats();

      _syncStatus = CloudSyncStatus.synced;
      notifyListeners();
    } catch (e, stack) {
      developer.log(
        'Cloud sync failed',
        name: 'StatsController',
        error: e,
        stackTrace: stack,
      );
      _syncStatus = CloudSyncStatus.error;
      notifyListeners();
    }
  }
}
