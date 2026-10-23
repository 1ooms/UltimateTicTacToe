import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/achievement_ids.dart';
import '../data/pref_keys.dart';
import '../models/enum/bot_difficulty.dart';
import '../models/enum/player.dart';
import '../models/game_stats.dart';
import '../services/play_games_service.dart';

enum CloudSyncStatus { idle, syncing, synced, signedOut, error }

class StatsController extends ChangeNotifier {
  static final StatsController _singleton = StatsController._internal();

  factory StatsController() => _singleton;

  StatsController._internal({PlayGamesService? playGamesService})
    : _playGamesService = playGamesService ?? PlayGamesService();

  @visibleForTesting
  StatsController.forTesting({
    PlayGamesService? playGamesService,
    GameStats initialStats = const GameStats(),
  }) : _playGamesService = playGamesService ?? PlayGamesService(),
       _stats = initialStats,
       _initialized = true;

  @visibleForTesting
  void resetForTesting({GameStats stats = const GameStats()}) {
    _stats = stats;
    _initialized = false;
    _syncStatus = CloudSyncStatus.idle;
    _accountName = null;
  }

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
  void recordLocalGamePlayed({Player? winner, bool isDraw = false}) {
    final isP1Win = !isDraw && winner == Player.one;
    final isP2Win = !isDraw && winner == Player.two;

    _stats = _stats.copyWith(
      localGamesPlayed: _stats.localGamesPlayed + 1,
      localPlayer1Wins:
          isP1Win ? _stats.localPlayer1Wins + 1 : _stats.localPlayer1Wins,
      localPlayer2Wins:
          isP2Win ? _stats.localPlayer2Wins + 1 : _stats.localPlayer2Wins,
      localDraws: isDraw ? _stats.localDraws + 1 : _stats.localDraws,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
    _evaluateAchievements();
  }

  /// Records an online multiplayer match completion.
  void recordOnlineGamePlayed({bool won = false, bool isDraw = false}) {
    final isWin = !isDraw && won == true;
    final isLoss = !isDraw && won == false;

    _stats = _stats.copyWith(
      onlineGamesPlayed: _stats.onlineGamesPlayed + 1,
      onlineWins: isWin ? _stats.onlineWins + 1 : _stats.onlineWins,
      onlineLosses: isLoss ? _stats.onlineLosses + 1 : _stats.onlineLosses,
      onlineDraws: isDraw ? _stats.onlineDraws + 1 : _stats.onlineDraws,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
    _evaluateAchievements();
  }

  /// Records a bot game completion, tracking the difficulty and outcome.
  void recordBotGamePlayed({
    required BotDifficulty difficulty,
    bool won = false,
    bool isDraw = false,
  }) {
    final updatedGamesByDiff = Map<BotDifficulty, int>.from(
      _stats.botGamesByDifficulty,
    );
    updatedGamesByDiff[difficulty] = (updatedGamesByDiff[difficulty] ?? 0) + 1;

    final updatedWins = Map<BotDifficulty, int>.from(_stats.botWins);
    final updatedLosses = Map<BotDifficulty, int>.from(_stats.botLosses);
    final updatedDraws = Map<BotDifficulty, int>.from(_stats.botDraws);

    if (isDraw) {
      updatedDraws[difficulty] = (updatedDraws[difficulty] ?? 0) + 1;
    } else if (won) {
      updatedWins[difficulty] = (updatedWins[difficulty] ?? 0) + 1;
    } else {
      updatedLosses[difficulty] = (updatedLosses[difficulty] ?? 0) + 1;
    }

    _stats = _stats.copyWith(
      botGamesPlayed: _stats.botGamesPlayed + 1,
      botGamesByDifficulty: updatedGamesByDiff,
      botWins: updatedWins,
      botLosses: updatedLosses,
      botDraws: updatedDraws,
    );
    notifyListeners();
    _saveToLocal();
    _triggerCloudUpload();
    _evaluateAchievements();
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
          'Games: ${_stats.totalGamesPlayed}, Bot Wins: ${_stats.totalBotWins}, Draws: ${_stats.totalDraws}',
    );
  }

  /// Opens the native Google Play Games achievements UI overlay.
  Future<void> showAchievements() => _playGamesService.showAchievements();

  @visibleForTesting
  void evaluateAchievementsForTesting() => _evaluateAchievements();

  /// Evaluates stats against achievement thresholds and syncs with Play Games.
  void _evaluateAchievements() {
    _playGamesService
        .isSignedIn()
        .then((signedIn) {
          if (!signedIn) return;

          // 1-Game played achievements
          if (_stats.localGamesPlayed >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.playLocal1);
          }
          if (_stats.onlineGamesPlayed >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.playOnline1);
          }
          if (_stats.botGamesPlayed >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.playBot1);
          }

          // 10-Games played achievements
          if (_stats.localGamesPlayed > 0) {
            _playGamesService.setAchievementSteps(
              AchievementIds.playLocal10,
              steps: _stats.localGamesPlayed,
            );
          }
          if (_stats.localGamesPlayed >= 10) {
            _playGamesService.unlockAchievement(AchievementIds.playLocal10);
          }

          if (_stats.onlineGamesPlayed > 0) {
            _playGamesService.setAchievementSteps(
              AchievementIds.playOnline10,
              steps: _stats.onlineGamesPlayed,
            );
          }
          if (_stats.onlineGamesPlayed >= 10) {
            _playGamesService.unlockAchievement(AchievementIds.playOnline10);
          }

          if (_stats.botGamesPlayed > 0) {
            _playGamesService.setAchievementSteps(
              AchievementIds.playBot10,
              steps: _stats.botGamesPlayed,
            );
          }
          if (_stats.botGamesPlayed >= 10) {
            _playGamesService.unlockAchievement(AchievementIds.playBot10);
          }

          // Defeating each bot difficulty
          if (_stats.botWinsFor(BotDifficulty.easy) >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.defeatBotEasy);
          }
          if (_stats.botWinsFor(BotDifficulty.medium) >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.defeatBotMedium);
          }
          if (_stats.botWinsFor(BotDifficulty.hard) >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.defeatBotHard);
          }
          if (_stats.botWinsFor(BotDifficulty.expert) >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.defeatBotExpert);
          }

          // 100 Total games milestone
          if (_stats.totalGamesPlayed > 0) {
            _playGamesService.setAchievementSteps(
              AchievementIds.playTotal100,
              steps: _stats.totalGamesPlayed,
            );
          }
          if (_stats.totalGamesPlayed >= 100) {
            _playGamesService.unlockAchievement(AchievementIds.playTotal100);
          }

          // Draw milestone (end any game in a draw)
          if (_stats.totalDraws >= 1) {
            _playGamesService.unlockAchievement(AchievementIds.drawGame);
          }
        })
        .catchError((e, stack) {
          developer.log(
            'Failed to evaluate achievements',
            name: 'StatsController',
            error: e,
            stackTrace: stack,
          );
        });
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
      _evaluateAchievements();

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
