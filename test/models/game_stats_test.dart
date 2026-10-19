import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/game_stats.dart';

void main() {
  group('GameStats Model', () {
    test('default constructor initializes all values to zero', () {
      const stats = GameStats();

      expect(stats.localGamesPlayed, equals(0));
      expect(stats.onlineGamesPlayed, equals(0));
      expect(stats.botGamesPlayed, equals(0));
      expect(stats.totalGamesPlayed, equals(0));
      expect(stats.totalBotWins, equals(0));
      expect(stats.lastSyncedAt, isNull);

      for (final difficulty in BotDifficulty.values) {
        expect(stats.botGamesFor(difficulty), equals(0));
        expect(stats.botWinsFor(difficulty), equals(0));
        expect(stats.botWinRateFor(difficulty), isNull);
      }
    });

    test('computed properties calculate sums and win rates correctly', () {
      const stats = GameStats(
        localGamesPlayed: 5,
        onlineGamesPlayed: 3,
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
      );

      expect(stats.totalGamesPlayed, equals(16));
      expect(stats.totalBotWins, equals(4));

      // Easy: 3 wins / 4 games = 75%
      expect(stats.botGamesFor(BotDifficulty.easy), equals(4));
      expect(stats.botWinsFor(BotDifficulty.easy), equals(3));
      expect(stats.botWinRateFor(BotDifficulty.easy), closeTo(75.0, 0.01));

      // Medium: 1 win / 2 games = 50%
      expect(stats.botGamesFor(BotDifficulty.medium), equals(2));
      expect(stats.botWinsFor(BotDifficulty.medium), equals(1));
      expect(stats.botWinRateFor(BotDifficulty.medium), closeTo(50.0, 0.01));

      // Hard: 0 wins / 2 games = 0%
      expect(stats.botGamesFor(BotDifficulty.hard), equals(2));
      expect(stats.botWinsFor(BotDifficulty.hard), equals(0));
      expect(stats.botWinRateFor(BotDifficulty.hard), closeTo(0.0, 0.01));

      // Expert: 0 played = null win rate
      expect(stats.botGamesFor(BotDifficulty.expert), equals(0));
      expect(stats.botWinsFor(BotDifficulty.expert), equals(0));
      expect(stats.botWinRateFor(BotDifficulty.expert), isNull);
    });

    test('toJson and fromJson serialize and deserialize accurately', () {
      final syncTime = DateTime(2026, 10, 19, 12, 0, 0);
      final original = GameStats(
        localGamesPlayed: 10,
        onlineGamesPlayed: 7,
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
        lastSyncedAt: syncTime,
      );

      final json = original.toJson();
      final restored = GameStats.fromJson(json);

      expect(restored.localGamesPlayed, equals(original.localGamesPlayed));
      expect(restored.onlineGamesPlayed, equals(original.onlineGamesPlayed));
      expect(restored.botGamesPlayed, equals(original.botGamesPlayed));
      expect(
        restored.botGamesByDifficulty,
        equals(original.botGamesByDifficulty),
      );
      expect(restored.botWins, equals(original.botWins));
      expect(restored.lastSyncedAt, equals(syncTime));
      expect(restored, equals(original));
    });

    test('fromJson handles empty or partial JSON gracefully', () {
      final restored = GameStats.fromJson(const {});

      expect(restored.localGamesPlayed, equals(0));
      expect(restored.onlineGamesPlayed, equals(0));
      expect(restored.botGamesPlayed, equals(0));
      expect(restored.lastSyncedAt, isNull);

      for (final difficulty in BotDifficulty.values) {
        expect(restored.botGamesFor(difficulty), equals(0));
        expect(restored.botWinsFor(difficulty), equals(0));
      }
    });

    test('merge uses monotonic max strategy for all counters', () {
      final time1 = DateTime(2026, 10, 19, 10, 0, 0);
      final time2 = DateTime(2026, 10, 19, 11, 0, 0);

      final localStats = GameStats(
        localGamesPlayed: 10,
        onlineGamesPlayed: 2,
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
        lastSyncedAt: time1,
      );

      final cloudStats = GameStats(
        localGamesPlayed: 4,
        onlineGamesPlayed: 8,
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
        lastSyncedAt: time2,
      );

      final merged = localStats.merge(cloudStats);

      // Takes max(10, 4) = 10
      expect(merged.localGamesPlayed, equals(10));
      // Takes max(2, 8) = 8
      expect(merged.onlineGamesPlayed, equals(8));
      // Takes max(5, 7) = 7
      expect(merged.botGamesPlayed, equals(7));

      // Easy: max(3, 2) games = 3, max(2, 2) wins = 2
      expect(merged.botGamesFor(BotDifficulty.easy), equals(3));
      expect(merged.botWinsFor(BotDifficulty.easy), equals(2));

      // Medium: max(2, 3) games = 3, max(1, 2) wins = 2
      expect(merged.botGamesFor(BotDifficulty.medium), equals(3));
      expect(merged.botWinsFor(BotDifficulty.medium), equals(2));

      // Hard: max(0, 2) games = 2, max(0, 1) wins = 1
      expect(merged.botGamesFor(BotDifficulty.hard), equals(2));
      expect(merged.botWinsFor(BotDifficulty.hard), equals(1));

      // Picks latest sync time
      expect(merged.lastSyncedAt, equals(time2));
    });

    test('copyWith updates specified fields only', () {
      const original = GameStats(localGamesPlayed: 2, onlineGamesPlayed: 3);

      final updated = original.copyWith(localGamesPlayed: 5);

      expect(updated.localGamesPlayed, equals(5));
      expect(updated.onlineGamesPlayed, equals(3));
      expect(updated.botGamesPlayed, equals(0));
    });
  });
}
