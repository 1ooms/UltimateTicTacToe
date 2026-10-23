import 'dart:math';
import 'enum/bot_difficulty.dart';

/// Default zero-map for all bot difficulties.
const Map<BotDifficulty, int> _defaultBotDifficultyMap = {
  BotDifficulty.easy: 0,
  BotDifficulty.medium: 0,
  BotDifficulty.hard: 0,
  BotDifficulty.expert: 0,
};

/// Represents all tracked player game statistics.
class GameStats {
  // Local mode metrics
  final int localGamesPlayed;
  final int localPlayer1Wins;
  final int localPlayer2Wins;
  final int localDraws;

  // Online mode metrics
  final int onlineGamesPlayed;
  final int onlineWins;
  final int onlineLosses;
  final int onlineDraws;

  // Bot mode metrics
  final int botGamesPlayed;
  final Map<BotDifficulty, int> botGamesByDifficulty;
  final Map<BotDifficulty, int> botWins;
  final Map<BotDifficulty, int> botLosses;
  final Map<BotDifficulty, int> botDraws;

  final DateTime? lastSyncedAt;

  const GameStats({
    this.localGamesPlayed = 0,
    this.localPlayer1Wins = 0,
    this.localPlayer2Wins = 0,
    this.localDraws = 0,
    this.onlineGamesPlayed = 0,
    this.onlineWins = 0,
    this.onlineLosses = 0,
    this.onlineDraws = 0,
    this.botGamesPlayed = 0,
    this.botGamesByDifficulty = _defaultBotDifficultyMap,
    this.botWins = _defaultBotDifficultyMap,
    this.botLosses = _defaultBotDifficultyMap,
    this.botDraws = _defaultBotDifficultyMap,
    int totalDraws = 0,
    this.lastSyncedAt,
  });

  /// Total games played across all modes.
  int get totalGamesPlayed =>
      localGamesPlayed + onlineGamesPlayed + botGamesPlayed;

  /// Total bot games won across all difficulties.
  int get totalBotWins => botWins.values.fold(0, (sum, count) => sum + count);

  /// Total bot games lost across all difficulties.
  int get totalBotLosses =>
      botLosses.values.fold(0, (sum, count) => sum + count);

  /// Total bot games ending in a draw across all difficulties.
  int get totalBotDraws => botDraws.values.fold(0, (sum, count) => sum + count);

  /// Total draws across all game modes.
  int get totalDraws =>
      (localDraws + onlineDraws + totalBotDraws);

  /// Number of games played for a specific bot difficulty.
  int botGamesFor(BotDifficulty difficulty) =>
      botGamesByDifficulty[difficulty] ?? 0;

  /// Number of wins for a specific bot difficulty.
  int botWinsFor(BotDifficulty difficulty) => botWins[difficulty] ?? 0;

  /// Number of losses for a specific bot difficulty.
  int botLossesFor(BotDifficulty difficulty) => botLosses[difficulty] ?? 0;

  /// Number of draws for a specific bot difficulty.
  int botDrawsFor(BotDifficulty difficulty) => botDraws[difficulty] ?? 0;

  /// Win rate percentage (0 - 100) for a specific bot difficulty,
  /// or null if no games were played at that difficulty.
  double? botWinRateFor(BotDifficulty difficulty) {
    final played = botGamesFor(difficulty);
    if (played == 0) return null;
    return (botWinsFor(difficulty) / played) * 100;
  }

  /// Online win rate percentage (0 - 100), or null if no games played.
  double? get onlineWinRate {
    if (onlineGamesPlayed == 0) return null;
    return (onlineWins / onlineGamesPlayed) * 100;
  }

  /// Overall bot win rate percentage (0 - 100), or null if no games played.
  double? get botWinRate {
    if (botGamesPlayed == 0) return null;
    return (totalBotWins / botGamesPlayed) * 100;
  }

  /// Creates a copy with optionally updated fields.
  GameStats copyWith({
    int? localGamesPlayed,
    int? localPlayer1Wins,
    int? localPlayer2Wins,
    int? localDraws,
    int? onlineGamesPlayed,
    int? onlineWins,
    int? onlineLosses,
    int? onlineDraws,
    int? botGamesPlayed,
    Map<BotDifficulty, int>? botGamesByDifficulty,
    Map<BotDifficulty, int>? botWins,
    Map<BotDifficulty, int>? botLosses,
    Map<BotDifficulty, int>? botDraws,
    int? totalDraws,
    DateTime? lastSyncedAt,
  }) {
    return GameStats(
      localGamesPlayed: localGamesPlayed ?? this.localGamesPlayed,
      localPlayer1Wins: localPlayer1Wins ?? this.localPlayer1Wins,
      localPlayer2Wins: localPlayer2Wins ?? this.localPlayer2Wins,
      localDraws: localDraws ?? this.localDraws,
      onlineGamesPlayed: onlineGamesPlayed ?? this.onlineGamesPlayed,
      onlineWins: onlineWins ?? this.onlineWins,
      onlineLosses: onlineLosses ?? this.onlineLosses,
      onlineDraws: onlineDraws ?? this.onlineDraws,
      botGamesPlayed: botGamesPlayed ?? this.botGamesPlayed,
      botGamesByDifficulty:
          botGamesByDifficulty ??
          Map<BotDifficulty, int>.from(this.botGamesByDifficulty),
      botWins: botWins ?? Map<BotDifficulty, int>.from(this.botWins),
      botLosses: botLosses ?? Map<BotDifficulty, int>.from(this.botLosses),
      botDraws: botDraws ?? Map<BotDifficulty, int>.from(this.botDraws),
      totalDraws: totalDraws ?? this.totalDraws,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Converts this instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'localGamesPlayed': localGamesPlayed,
      'localPlayer1Wins': localPlayer1Wins,
      'localPlayer2Wins': localPlayer2Wins,
      'localDraws': localDraws,
      'onlineGamesPlayed': onlineGamesPlayed,
      'onlineWins': onlineWins,
      'onlineLosses': onlineLosses,
      'onlineDraws': onlineDraws,
      'botGamesPlayed': botGamesPlayed,
      'totalDraws': totalDraws,
      'botGamesByDifficulty': botGamesByDifficulty.map(
        (key, value) => MapEntry(key.name, value),
      ),
      'botWins': botWins.map((key, value) => MapEntry(key.name, value)),
      'botLosses': botLosses.map((key, value) => MapEntry(key.name, value)),
      'botDraws': botDraws.map((key, value) => MapEntry(key.name, value)),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Creates a [GameStats] instance from a JSON Map.
  factory GameStats.fromJson(Map<String, dynamic> json) {
    Map<BotDifficulty, int> parseDifficultyMap(String key) {
      final raw = json[key] as Map<String, dynamic>? ?? {};
      final map = <BotDifficulty, int>{};
      for (final difficulty in BotDifficulty.values) {
        map[difficulty] = (raw[difficulty.name] as num?)?.toInt() ?? 0;
      }
      return map;
    }

    return GameStats(
      localGamesPlayed: (json['localGamesPlayed'] as num?)?.toInt() ?? 0,
      localPlayer1Wins: (json['localPlayer1Wins'] as num?)?.toInt() ?? 0,
      localPlayer2Wins: (json['localPlayer2Wins'] as num?)?.toInt() ?? 0,
      localDraws: (json['localDraws'] as num?)?.toInt() ?? 0,
      onlineGamesPlayed: (json['onlineGamesPlayed'] as num?)?.toInt() ?? 0,
      onlineWins: (json['onlineWins'] as num?)?.toInt() ?? 0,
      onlineLosses: (json['onlineLosses'] as num?)?.toInt() ?? 0,
      onlineDraws: (json['onlineDraws'] as num?)?.toInt() ?? 0,
      botGamesPlayed: (json['botGamesPlayed'] as num?)?.toInt() ?? 0,
      botGamesByDifficulty: parseDifficultyMap('botGamesByDifficulty'),
      botWins: parseDifficultyMap('botWins'),
      botLosses: parseDifficultyMap('botLosses'),
      botDraws: parseDifficultyMap('botDraws'),
      totalDraws: (json['totalDraws'] as num?)?.toInt() ?? 0,
      lastSyncedAt:
          json['lastSyncedAt'] != null
              ? DateTime.tryParse(json['lastSyncedAt'] as String)
              : null,
    );
  }

  /// Merges this [GameStats] with another (e.g. from cloud save)
  /// using monotonic max strategy to prevent losing stats.
  GameStats merge(GameStats other) {
    Map<BotDifficulty, int> mergeMap(
      Map<BotDifficulty, int> a,
      Map<BotDifficulty, int> b,
    ) {
      final merged = <BotDifficulty, int>{};
      for (final difficulty in BotDifficulty.values) {
        merged[difficulty] = max(a[difficulty] ?? 0, b[difficulty] ?? 0);
      }
      return merged;
    }

    DateTime? mergedSync;
    if (lastSyncedAt == null) {
      mergedSync = other.lastSyncedAt;
    } else if (other.lastSyncedAt == null) {
      mergedSync = lastSyncedAt;
    } else {
      mergedSync =
          lastSyncedAt!.isAfter(other.lastSyncedAt!)
              ? lastSyncedAt
              : other.lastSyncedAt;
    }

    return GameStats(
      localGamesPlayed: max(localGamesPlayed, other.localGamesPlayed),
      localPlayer1Wins: max(localPlayer1Wins, other.localPlayer1Wins),
      localPlayer2Wins: max(localPlayer2Wins, other.localPlayer2Wins),
      localDraws: max(localDraws, other.localDraws),
      onlineGamesPlayed: max(onlineGamesPlayed, other.onlineGamesPlayed),
      onlineWins: max(onlineWins, other.onlineWins),
      onlineLosses: max(onlineLosses, other.onlineLosses),
      onlineDraws: max(onlineDraws, other.onlineDraws),
      botGamesPlayed: max(botGamesPlayed, other.botGamesPlayed),
      botGamesByDifficulty: mergeMap(
        botGamesByDifficulty,
        other.botGamesByDifficulty,
      ),
      botWins: mergeMap(botWins, other.botWins),
      botLosses: mergeMap(botLosses, other.botLosses),
      botDraws: mergeMap(botDraws, other.botDraws),
      totalDraws: max(totalDraws, other.totalDraws),
      lastSyncedAt: mergedSync ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStats &&
          runtimeType == other.runtimeType &&
          localGamesPlayed == other.localGamesPlayed &&
          localPlayer1Wins == other.localPlayer1Wins &&
          localPlayer2Wins == other.localPlayer2Wins &&
          localDraws == other.localDraws &&
          onlineGamesPlayed == other.onlineGamesPlayed &&
          onlineWins == other.onlineWins &&
          onlineLosses == other.onlineLosses &&
          onlineDraws == other.onlineDraws &&
          botGamesPlayed == other.botGamesPlayed &&
          totalDraws == other.totalDraws &&
          _mapsEqual(botGamesByDifficulty, other.botGamesByDifficulty) &&
          _mapsEqual(botWins, other.botWins) &&
          _mapsEqual(botLosses, other.botLosses) &&
          _mapsEqual(botDraws, other.botDraws);

  @override
  int get hashCode =>
      localGamesPlayed.hashCode ^
      localPlayer1Wins.hashCode ^
      localPlayer2Wins.hashCode ^
      localDraws.hashCode ^
      onlineGamesPlayed.hashCode ^
      onlineWins.hashCode ^
      onlineLosses.hashCode ^
      onlineDraws.hashCode ^
      botGamesPlayed.hashCode ^
      totalDraws.hashCode ^
      botGamesByDifficulty.hashCode ^
      botWins.hashCode ^
      botLosses.hashCode ^
      botDraws.hashCode;

  static bool _mapsEqual(Map<BotDifficulty, int> a, Map<BotDifficulty, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
