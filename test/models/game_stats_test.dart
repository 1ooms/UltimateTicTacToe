import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/game_stats.dart';

void main() {
  group('GameStats Model', () {
    test('default constructor initializes all values to zero', () {
      const stats = GameStats();

      expect(stats.localGamesPlayed, equals(0));
      expect(stats.localPlayer1Wins, equals(0));
      expect(stats.localPlayer2Wins, equals(0));
      expect(stats.localDraws, equals(0));

      expect(stats.onlineGamesPlayed, equals(0));
      expect(stats.onlineWins, equals(0));
      expect(stats.onlineLosses, equals(0));
      expect(stats.onlineDraws, equals(0));
      expect(stats.onlineWinRate, isNull);

      expect(stats.botGamesPlayed, equals(0));
      expect(stats.totalBotWins, equals(0));
      expect(stats.totalBotLosses, equals(0));
      expect(stats.totalBotDraws, equals(0));
      expect(stats.botWinRate, isNull);

      expect(stats.totalDraws, equals(0));
      expect(stats.totalGamesPlayed, equals(0));
      expect(stats.lastSyncedAt, isNull);

      for (final difficulty in BotDifficulty.values) {
        expect(stats.botGamesFor(difficulty), equals(0));
        expect(stats.botWinsFor(difficulty), equals(0));
        expect(stats.botLossesFor(difficulty), equals(0));
        expect(stats.botDrawsFor(difficulty), equals(0));
        expect(stats.botWinRateFor(difficulty), isNull);
      }
    });

    test('computed properties calculate sums and win rates correctly', () {
      const stats = GameStats(
        localGamesPlayed: 5,
        localPlayer1Wins: 3,
        localPlayer2Wins: 1,
        localDraws: 1,
        onlineGamesPlayed: 4,
        onlineWins: 2,
        onlineLosses: 1,
        onlineDraws: 1,
        botGamesPlayed: 8,
        botGamesByDifficulty: {
          BotDifficulty.easy: 4,
          BotDifficulty.medium: 2,
          BotDifficulty.hard: 2,
          BotDifficulty.expert: 0,
        },
        botWins: {
          BotDifficulty.easy: 3,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botLosses: {
          BotDifficulty.easy: 1,
          BotDifficulty.medium: 0,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
        botDraws: {
          BotDifficulty.easy: 0,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
      );

      expect(stats.totalGamesPlayed, equals(17));
      expect(stats.totalBotWins, equals(4));
      expect(stats.totalBotLosses, equals(2));
      expect(stats.totalBotDraws, equals(2));
      expect(stats.totalDraws, equals(4)); // local: 1 + online: 1 + bot: 2

      expect(stats.onlineWinRate, equals(50.0));
      expect(stats.botWinRate, equals(50.0));

      // Easy: 3 wins / 4 games = 75%
      expect(stats.botGamesFor(BotDifficulty.easy), equals(4));
      expect(stats.botWinsFor(BotDifficulty.easy), equals(3));
      expect(stats.botLossesFor(BotDifficulty.easy), equals(1));
      expect(stats.botDrawsFor(BotDifficulty.easy), equals(0));
      expect(stats.botWinRateFor(BotDifficulty.easy), closeTo(75.0, 0.01));

      // Medium: 1 win / 2 games = 50%
      expect(stats.botGamesFor(BotDifficulty.medium), equals(2));
      expect(stats.botWinsFor(BotDifficulty.medium), equals(1));
      expect(stats.botLossesFor(BotDifficulty.medium), equals(0));
      expect(stats.botDrawsFor(BotDifficulty.medium), equals(1));
      expect(stats.botWinRateFor(BotDifficulty.medium), closeTo(50.0, 0.01));

      // Hard: 0 wins / 2 games = 0%
      expect(stats.botGamesFor(BotDifficulty.hard), equals(2));
      expect(stats.botWinsFor(BotDifficulty.hard), equals(0));
      expect(stats.botLossesFor(BotDifficulty.hard), equals(1));
      expect(stats.botDrawsFor(BotDifficulty.hard), equals(1));
      expect(stats.botWinRateFor(BotDifficulty.hard), closeTo(0.0, 0.01));

      // Expert: 0 played = null win rate
      expect(stats.botGamesFor(BotDifficulty.expert), equals(0));
      expect(stats.botWinsFor(BotDifficulty.expert), equals(0));
      expect(stats.botLossesFor(BotDifficulty.expert), equals(0));
      expect(stats.botDrawsFor(BotDifficulty.expert), equals(0));
      expect(stats.botWinRateFor(BotDifficulty.expert), isNull);
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final syncTime = DateTime(2026, 10, 19, 12, 0, 0);
      final original = GameStats(
        localGamesPlayed: 10,
        localPlayer1Wins: 5,
        localPlayer2Wins: 3,
        localDraws: 2,
        onlineGamesPlayed: 7,
        onlineWins: 4,
        onlineLosses: 2,
        onlineDraws: 1,
        botGamesPlayed: 12,
        botGamesByDifficulty: const {
          BotDifficulty.easy: 6,
          BotDifficulty.medium: 4,
          BotDifficulty.hard: 2,
          BotDifficulty.expert: 0,
        },
        botWins: const {
          BotDifficulty.easy: 5,
          BotDifficulty.medium: 3,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
        botLosses: const {
          BotDifficulty.easy: 1,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botDraws: const {
          BotDifficulty.easy: 0,
          BotDifficulty.medium: 0,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
        lastSyncedAt: syncTime,
      );

      final json = original.toJson();
      final restored = GameStats.fromJson(json);

      expect(restored.localGamesPlayed, equals(original.localGamesPlayed));
      expect(restored.localPlayer1Wins, equals(original.localPlayer1Wins));
      expect(restored.localPlayer2Wins, equals(original.localPlayer2Wins));
      expect(restored.localDraws, equals(original.localDraws));

      expect(restored.onlineGamesPlayed, equals(original.onlineGamesPlayed));
      expect(restored.onlineWins, equals(original.onlineWins));
      expect(restored.onlineLosses, equals(original.onlineLosses));
      expect(restored.onlineDraws, equals(original.onlineDraws));

      expect(restored.botGamesPlayed, equals(original.botGamesPlayed));
      expect(restored.totalDraws, equals(original.totalDraws));
      expect(
        restored.botGamesByDifficulty,
        equals(original.botGamesByDifficulty),
      );
      expect(restored.botWins, equals(original.botWins));
      expect(restored.botLosses, equals(original.botLosses));
      expect(restored.botDraws, equals(original.botDraws));
      expect(restored.lastSyncedAt, equals(syncTime));
      expect(restored, equals(original));
    });

    test('fromJson handles empty or partial JSON gracefully', () {
      final restored = GameStats.fromJson(const {});

      expect(restored.localGamesPlayed, equals(0));
      expect(restored.localPlayer1Wins, equals(0));
      expect(restored.localPlayer2Wins, equals(0));
      expect(restored.localDraws, equals(0));
      expect(restored.onlineGamesPlayed, equals(0));
      expect(restored.onlineWins, equals(0));
      expect(restored.onlineLosses, equals(0));
      expect(restored.onlineDraws, equals(0));
      expect(restored.botGamesPlayed, equals(0));
      expect(restored.totalDraws, equals(0));
      expect(restored.lastSyncedAt, isNull);

      for (final difficulty in BotDifficulty.values) {
        expect(restored.botGamesFor(difficulty), equals(0));
        expect(restored.botWinsFor(difficulty), equals(0));
        expect(restored.botLossesFor(difficulty), equals(0));
        expect(restored.botDrawsFor(difficulty), equals(0));
      }
    });

    test('merge uses monotonic max strategy for all counters', () {
      final time1 = DateTime(2026, 10, 19, 10, 0, 0);
      final time2 = DateTime(2026, 10, 19, 11, 0, 0);

      final localStats = GameStats(
        localGamesPlayed: 10,
        localPlayer1Wins: 5,
        localPlayer2Wins: 3,
        localDraws: 2,
        onlineGamesPlayed: 2,
        onlineWins: 1,
        onlineLosses: 1,
        onlineDraws: 0,
        botGamesPlayed: 5,
        botGamesByDifficulty: const {
          BotDifficulty.easy: 3,
          BotDifficulty.medium: 2,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botWins: const {
          BotDifficulty.easy: 2,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botLosses: const {
          BotDifficulty.easy: 1,
          BotDifficulty.medium: 0,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botDraws: const {
          BotDifficulty.easy: 0,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        lastSyncedAt: time1,
      );

      final cloudStats = GameStats(
        localGamesPlayed: 4,
        localPlayer1Wins: 2,
        localPlayer2Wins: 1,
        localDraws: 1,
        onlineGamesPlayed: 8,
        onlineWins: 5,
        onlineLosses: 2,
        onlineDraws: 1,
        botGamesPlayed: 7,
        botGamesByDifficulty: const {
          BotDifficulty.easy: 2,
          BotDifficulty.medium: 3,
          BotDifficulty.hard: 2,
          BotDifficulty.expert: 0,
        },
        botWins: const {
          BotDifficulty.easy: 2,
          BotDifficulty.medium: 2,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
        botLosses: const {
          BotDifficulty.easy: 0,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 1,
          BotDifficulty.expert: 0,
        },
        botDraws: const {
          BotDifficulty.easy: 0,
          BotDifficulty.medium: 0,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        lastSyncedAt: time2,
      );

      final merged = localStats.merge(cloudStats);

      expect(merged.localGamesPlayed, equals(10));
      expect(merged.localPlayer1Wins, equals(5));
      expect(merged.localPlayer2Wins, equals(3));
      expect(merged.localDraws, equals(2));

      expect(merged.onlineGamesPlayed, equals(8));
      expect(merged.onlineWins, equals(5));
      expect(merged.onlineLosses, equals(2));
      expect(merged.onlineDraws, equals(1));

      expect(merged.botGamesPlayed, equals(7));

      // Easy
      expect(merged.botGamesFor(BotDifficulty.easy), equals(3));
      expect(merged.botWinsFor(BotDifficulty.easy), equals(2));
      expect(merged.botLossesFor(BotDifficulty.easy), equals(1));
      expect(merged.botDrawsFor(BotDifficulty.easy), equals(0));

      // Medium
      expect(merged.botGamesFor(BotDifficulty.medium), equals(3));
      expect(merged.botWinsFor(BotDifficulty.medium), equals(2));
      expect(merged.botLossesFor(BotDifficulty.medium), equals(1));
      expect(merged.botDrawsFor(BotDifficulty.medium), equals(1));

      // Hard
      expect(merged.botGamesFor(BotDifficulty.hard), equals(2));
      expect(merged.botWinsFor(BotDifficulty.hard), equals(1));
      expect(merged.botLossesFor(BotDifficulty.hard), equals(1));
      expect(merged.botDrawsFor(BotDifficulty.hard), equals(0));

      expect(merged.lastSyncedAt, equals(time2));
    });

    test('copyWith updates specified fields only', () {
      const original = GameStats(
        localGamesPlayed: 2,
        onlineGamesPlayed: 3,
        localDraws: 1,
      );

      final updated = original.copyWith(localPlayer1Wins: 2);

      expect(updated.localGamesPlayed, equals(2));
      expect(updated.localPlayer1Wins, equals(2));
      expect(updated.onlineGamesPlayed, equals(3));
      expect(updated.localDraws, equals(1));
    });
  });
}
