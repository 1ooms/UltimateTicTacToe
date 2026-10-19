import 'dart:math';
import 'enum/bot_difficulty.dart';

/// Represents all tracked player game statistics.
class GameStats {
  final int localGamesPlayed;
  final int onlineGamesPlayed;
  final int botGamesPlayed;
  final Map<BotDifficulty, int> botGamesByDifficulty;
  final Map<BotDifficulty, int> botWins;
  final DateTime? lastSyncedAt;

  const GameStats({
    this.localGamesPlayed = 0,
    this.onlineGamesPlayed = 0,
    this.botGamesPlayed = 0,
    this.botGamesByDifficulty = const {
      BotDifficulty.easy: 0,
      BotDifficulty.medium: 0,
      BotDifficulty.hard: 0,
      BotDifficulty.expert: 0,
    },
    this.botWins = const {
      BotDifficulty.easy: 0,
      BotDifficulty.medium: 0,
      BotDifficulty.hard: 0,
      BotDifficulty.expert: 0,
    },
    this.lastSyncedAt,
  });

  /// Total games played across all modes.
  int get totalGamesPlayed =>
      localGamesPlayed + onlineGamesPlayed + botGamesPlayed;

  /// Total bot games won across all difficulties.
  int get totalBotWins =>
      botWins.values.fold(0, (sum, count) => sum + count);

  /// Number of games played for a specific bot difficulty.
  int botGamesFor(BotDifficulty difficulty) =>
      botGamesByDifficulty[difficulty] ?? 0;

  /// Number of wins for a specific bot difficulty.
  int botWinsFor(BotDifficulty difficulty) => botWins[difficulty] ?? 0;

  /// Win rate percentage (0 - 100) for a specific bot difficulty,
  /// or null if no games were played at that difficulty.
  double? botWinRateFor(BotDifficulty difficulty) {
    final played = botGamesFor(difficulty);
    if (played == 0) return null;
    return (botWinsFor(difficulty) / played) * 100;
  }

  /// Creates a copy with optionally updated fields.
  GameStats copyWith({
    int? localGamesPlayed,
    int? onlineGamesPlayed,
    int? botGamesPlayed,
    Map<BotDifficulty, int>? botGamesByDifficulty,
    Map<BotDifficulty, int>? botWins,
    DateTime? lastSyncedAt,
  }) {
    return GameStats(
      localGamesPlayed: localGamesPlayed ?? this.localGamesPlayed,
      onlineGamesPlayed: onlineGamesPlayed ?? this.onlineGamesPlayed,
      botGamesPlayed: botGamesPlayed ?? this.botGamesPlayed,
      botGamesByDifficulty: botGamesByDifficulty ??
          Map<BotDifficulty, int>.from(this.botGamesByDifficulty),
      botWins: botWins ?? Map<BotDifficulty, int>.from(this.botWins),
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Converts this instance to a JSON Map.
  Map<String, dynamic> toJson() {
    return {
      'localGamesPlayed': localGamesPlayed,
      'onlineGamesPlayed': onlineGamesPlayed,
      'botGamesPlayed': botGamesPlayed,
      'botGamesByDifficulty':
          botGamesByDifficulty.map((key, value) => MapEntry(key.name, value)),
      'botWins': botWins.map((key, value) => MapEntry(key.name, value)),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Creates a [GameStats] instance from a JSON Map.
  factory GameStats.fromJson(Map<String, dynamic> json) {
    final rawBotWins = json['botWins'] as Map<String, dynamic>? ?? {};
    final parsedBotWins = <BotDifficulty, int>{};

    for (final difficulty in BotDifficulty.values) {
      parsedBotWins[difficulty] =
          (rawBotWins[difficulty.name] as num?)?.toInt() ?? 0;
    }

    final rawBotGames =
        json['botGamesByDifficulty'] as Map<String, dynamic>? ?? {};
    final parsedBotGames = <BotDifficulty, int>{};

    for (final difficulty in BotDifficulty.values) {
      parsedBotGames[difficulty] =
          (rawBotGames[difficulty.name] as num?)?.toInt() ?? 0;
    }

    return GameStats(
      localGamesPlayed: (json['localGamesPlayed'] as num?)?.toInt() ?? 0,
      onlineGamesPlayed: (json['onlineGamesPlayed'] as num?)?.toInt() ?? 0,
      botGamesPlayed: (json['botGamesPlayed'] as num?)?.toInt() ?? 0,
      botGamesByDifficulty: parsedBotGames,
      botWins: parsedBotWins,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.tryParse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Merges this [GameStats] with another (e.g. from cloud save)
  /// using monotonic max strategy to prevent losing stats.
  GameStats merge(GameStats other) {
    final mergedWins = <BotDifficulty, int>{};
    final mergedGamesByDiff = <BotDifficulty, int>{};

    for (final difficulty in BotDifficulty.values) {
      mergedWins[difficulty] = max(
        botWinsFor(difficulty),
        other.botWinsFor(difficulty),
      );
      mergedGamesByDiff[difficulty] = max(
        botGamesFor(difficulty),
        other.botGamesFor(difficulty),
      );
    }

    DateTime? mergedSync;
    if (lastSyncedAt == null) {
      mergedSync = other.lastSyncedAt;
    } else if (other.lastSyncedAt == null) {
      mergedSync = lastSyncedAt;
    } else {
      mergedSync = lastSyncedAt!.isAfter(other.lastSyncedAt!)
          ? lastSyncedAt
          : other.lastSyncedAt;
    }

    return GameStats(
      localGamesPlayed: max(localGamesPlayed, other.localGamesPlayed),
      onlineGamesPlayed: max(onlineGamesPlayed, other.onlineGamesPlayed),
      botGamesPlayed: max(botGamesPlayed, other.botGamesPlayed),
      botGamesByDifficulty: mergedGamesByDiff,
      botWins: mergedWins,
      lastSyncedAt: mergedSync ?? DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStats &&
          runtimeType == other.runtimeType &&
          localGamesPlayed == other.localGamesPlayed &&
          onlineGamesPlayed == other.onlineGamesPlayed &&
          botGamesPlayed == other.botGamesPlayed &&
          _mapsEqual(botGamesByDifficulty, other.botGamesByDifficulty) &&
          _mapsEqual(botWins, other.botWins);

  @override
  int get hashCode =>
      localGamesPlayed.hashCode ^
      onlineGamesPlayed.hashCode ^
      botGamesPlayed.hashCode ^
      botGamesByDifficulty.hashCode ^
      botWins.hashCode;

  static bool _mapsEqual(
    Map<BotDifficulty, int> a,
    Map<BotDifficulty, int> b,
  ) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (b[key] != a[key]) return false;
    }
    return true;
  }
}
