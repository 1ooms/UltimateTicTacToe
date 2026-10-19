import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/stats_controller.dart';
import 'package:ultimate_tic_tac_toe/data/pref_keys.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/game_stats.dart';
import 'package:ultimate_tic_tac_toe/services/play_games_service.dart';

class FakePlayGamesService extends PlayGamesService {
  bool signedIn = false;
  String? cloudSaveData;
  String? savedDescription;
  String? playerName = 'TestPlayer';
  int saveCount = 0;

  @override
  bool get isSupportedPlatform => true;

  @override
  Future<bool> isSignedIn() async => signedIn;

  @override
  Future<bool> signIn() async {
    signedIn = true;
    return true;
  }

  @override
  Future<String?> getPlayerName() async => playerName;

  @override
  Future<String?> loadSavedGame([String name = 'player_stats']) async =>
      cloudSaveData;

  @override
  Future<bool> saveGame({
    String name = 'player_stats',
    required String data,
    String? description,
  }) async {
    cloudSaveData = data;
    savedDescription = description;
    saveCount++;
    return true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakePlayGamesService fakePlayGamesService;
  late StatsController controller;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    fakePlayGamesService = FakePlayGamesService();
    controller = StatsController.forTesting(
      playGamesService: fakePlayGamesService,
    );
  });

  group('StatsController Unit Tests', () {
    test('initializes with default zeroed stats', () {
      expect(controller.stats.totalGamesPlayed, equals(0));
      expect(controller.stats.localGamesPlayed, equals(0));
      expect(controller.stats.onlineGamesPlayed, equals(0));
      expect(controller.stats.botGamesPlayed, equals(0));
    });

    test('loads cached stats from SharedPreferences on initialize', () async {
      final initialStats = const GameStats(
        localGamesPlayed: 7,
        onlineGamesPlayed: 3,
        botGamesPlayed: 5,
        botGamesByDifficulty: {
          BotDifficulty.easy: 3,
          BotDifficulty.medium: 2,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botWins: {
          BotDifficulty.easy: 2,
          BotDifficulty.medium: 1,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
      );

      SharedPreferences.setMockInitialValues({
        PrefKeys.gameStats: jsonEncode(initialStats.toJson()),
      });

      final freshController = StatsController.forTesting(
        playGamesService: fakePlayGamesService,
      );
      freshController.resetForTesting();
      await freshController.initialize();

      expect(freshController.stats.localGamesPlayed, equals(7));
      expect(freshController.stats.onlineGamesPlayed, equals(3));
      expect(freshController.stats.botGamesPlayed, equals(5));
      expect(freshController.stats.botWinsFor(BotDifficulty.easy), equals(2));
    });

    test(
      'recordLocalGamePlayed increments local counter and persists',
      () async {
        controller.recordLocalGamePlayed();
        await Future<void>.delayed(Duration.zero);

        expect(controller.stats.localGamesPlayed, equals(1));
        expect(controller.stats.totalGamesPlayed, equals(1));

        final prefs = await SharedPreferences.getInstance();
        final savedString = prefs.getString(PrefKeys.gameStats);
        expect(savedString, isNotNull);

        final parsed = GameStats.fromJson(jsonDecode(savedString!));
        expect(parsed.localGamesPlayed, equals(1));
      },
    );

    test(
      'recordOnlineGamePlayed increments online counter and persists',
      () async {
        controller.recordOnlineGamePlayed();
        await Future<void>.delayed(Duration.zero);

        expect(controller.stats.onlineGamesPlayed, equals(1));
        expect(controller.stats.totalGamesPlayed, equals(1));

        final prefs = await SharedPreferences.getInstance();
        final savedString = prefs.getString(PrefKeys.gameStats);
        expect(savedString, isNotNull);

        final parsed = GameStats.fromJson(jsonDecode(savedString!));
        expect(parsed.onlineGamesPlayed, equals(1));
      },
    );

    test('recordBotGamePlayed records win and difficulty played', () {
      controller.recordBotGamePlayed(won: true, difficulty: BotDifficulty.hard);

      expect(controller.stats.botGamesPlayed, equals(1));
      expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botWinRateFor(BotDifficulty.hard), equals(100.0));

      // Other difficulties remain 0
      expect(controller.stats.botGamesFor(BotDifficulty.easy), equals(0));
      expect(controller.stats.botWinsFor(BotDifficulty.easy), equals(0));
    });

    test('recordBotGamePlayed records loss without incrementing wins', () {
      controller.recordBotGamePlayed(
        won: false,
        difficulty: BotDifficulty.expert,
      );

      expect(controller.stats.botGamesPlayed, equals(1));
      expect(controller.stats.botGamesFor(BotDifficulty.expert), equals(1));
      expect(controller.stats.botWinsFor(BotDifficulty.expert), equals(0));
      expect(controller.stats.botWinRateFor(BotDifficulty.expert), equals(0.0));
    });

    test(
      'syncWithCloud merges remote stats and persists to local and cloud',
      () async {
        // Local has played 3 local games and 1 hard bot game
        controller.recordLocalGamePlayed();
        controller.recordLocalGamePlayed();
        controller.recordLocalGamePlayed();
        controller.recordBotGamePlayed(
          won: true,
          difficulty: BotDifficulty.hard,
        );
        await Future<void>.delayed(Duration.zero);

        // Now simulate remote cloud save having additional progress
        fakePlayGamesService.signedIn = true;
        fakePlayGamesService.cloudSaveData = jsonEncode(
          const GameStats(
            localGamesPlayed: 5,
            onlineGamesPlayed: 10,
            botGamesPlayed: 8,
            botGamesByDifficulty: {
              BotDifficulty.easy: 4,
              BotDifficulty.medium: 4,
              BotDifficulty.hard: 0,
              BotDifficulty.expert: 0,
            },
            botWins: {
              BotDifficulty.easy: 3,
              BotDifficulty.medium: 2,
              BotDifficulty.hard: 0,
              BotDifficulty.expert: 0,
            },
          ).toJson(),
        );

        await controller.syncWithCloud();

        expect(controller.syncStatus, equals(CloudSyncStatus.synced));
        expect(controller.accountName, equals('TestPlayer'));

        // Merged local: max(3, 5) = 5
        expect(controller.stats.localGamesPlayed, equals(5));
        // Merged online: max(0, 10) = 10
        expect(controller.stats.onlineGamesPlayed, equals(10));
        // Hard bot win preserved from local
        expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
        expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(1));
        // Easy/Medium bot wins preserved from cloud
        expect(controller.stats.botWinsFor(BotDifficulty.easy), equals(3));
        expect(controller.stats.botWinsFor(BotDifficulty.medium), equals(2));

        // Saved back to cloud
        expect(fakePlayGamesService.saveCount, greaterThanOrEqualTo(1));
      },
    );

    test('syncWithCloud handles signed out state gracefully', () async {
      fakePlayGamesService.signedIn = false;

      await controller.syncWithCloud(forceSignIn: false);

      expect(controller.syncStatus, equals(CloudSyncStatus.signedOut));
      expect(controller.accountName, isNull);
    });
  });
}
