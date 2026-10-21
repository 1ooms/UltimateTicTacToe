import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/stats_controller.dart';
import 'package:ultimate_tic_tac_toe/data/achievement_ids.dart';
import 'package:ultimate_tic_tac_toe/data/pref_keys.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/game_stats.dart';
import 'package:ultimate_tic_tac_toe/services/play_games_service.dart';

class FakePlayGamesService extends PlayGamesService {
  bool signedIn = false;
  String? cloudSaveData;
  String? savedDescription;
  String? playerName = 'TestPlayer';
  int saveCount = 0;
  final List<String> unlockedAchievements = [];
  final Map<String, int> achievementSteps = {};
  bool showAchievementsCalled = false;

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

  @override
  Future<bool> unlockAchievement(String androidId, {String? iOSId}) async {
    if (!unlockedAchievements.contains(androidId)) {
      unlockedAchievements.add(androidId);
    }
    return true;
  }

  @override
  Future<bool> setAchievementSteps(
    String androidId, {
    required int steps,
    String? iOSId,
  }) async {
    achievementSteps[androidId] = steps;
    return true;
  }

  @override
  Future<void> showAchievements() async {
    showAchievementsCalled = true;
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
      expect(controller.stats.localPlayer1Wins, equals(0));
      expect(controller.stats.localPlayer2Wins, equals(0));
      expect(controller.stats.localDraws, equals(0));

      expect(controller.stats.onlineGamesPlayed, equals(0));
      expect(controller.stats.onlineWins, equals(0));
      expect(controller.stats.onlineLosses, equals(0));
      expect(controller.stats.onlineDraws, equals(0));

      expect(controller.stats.botGamesPlayed, equals(0));
      expect(controller.stats.totalBotWins, equals(0));
      expect(controller.stats.totalBotLosses, equals(0));
      expect(controller.stats.totalBotDraws, equals(0));
      expect(controller.stats.totalDraws, equals(0));
    });

    test('loads cached stats from SharedPreferences on initialize', () async {
      final initialStats = const GameStats(
        localGamesPlayed: 7,
        localPlayer1Wins: 4,
        localPlayer2Wins: 2,
        localDraws: 1,
        onlineGamesPlayed: 3,
        onlineWins: 2,
        onlineLosses: 1,
        onlineDraws: 0,
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
        botLosses: {
          BotDifficulty.easy: 1,
          BotDifficulty.medium: 0,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botDraws: {
          BotDifficulty.easy: 0,
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
      expect(freshController.stats.localPlayer1Wins, equals(4));
      expect(freshController.stats.localPlayer2Wins, equals(2));
      expect(freshController.stats.localDraws, equals(1));

      expect(freshController.stats.onlineGamesPlayed, equals(3));
      expect(freshController.stats.onlineWins, equals(2));
      expect(freshController.stats.onlineLosses, equals(1));

      expect(freshController.stats.botGamesPlayed, equals(5));
      expect(freshController.stats.totalBotWins, equals(3));
      expect(freshController.stats.totalBotLosses, equals(1));
      expect(freshController.stats.totalBotDraws, equals(1));

      expect(freshController.stats.totalDraws, equals(2)); // local 1 + bot 1
      expect(freshController.stats.totalGamesPlayed, equals(15));
    });

    test('recordLocalGamePlayed tracks Player 1 win', () async {
      controller.recordLocalGamePlayed(winner: Player.one);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.localGamesPlayed, equals(1));
      expect(controller.stats.localPlayer1Wins, equals(1));
      expect(controller.stats.localPlayer2Wins, equals(0));
      expect(controller.stats.localDraws, equals(0));
    });

    test('recordLocalGamePlayed tracks Player 2 win', () async {
      controller.recordLocalGamePlayed(winner: Player.two);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.localGamesPlayed, equals(1));
      expect(controller.stats.localPlayer1Wins, equals(0));
      expect(controller.stats.localPlayer2Wins, equals(1));
      expect(controller.stats.localDraws, equals(0));
    });

    test('recordLocalGamePlayed tracks draw', () async {
      controller.recordLocalGamePlayed(isDraw: true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.localGamesPlayed, equals(1));
      expect(controller.stats.localPlayer1Wins, equals(0));
      expect(controller.stats.localPlayer2Wins, equals(0));
      expect(controller.stats.localDraws, equals(1));
      expect(controller.stats.totalDraws, equals(1));
    });

    test('recordOnlineGamePlayed tracks wins, losses, and draws', () async {
      controller.recordOnlineGamePlayed(won: true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.onlineGamesPlayed, equals(1));
      expect(controller.stats.onlineWins, equals(1));
      expect(controller.stats.onlineLosses, equals(0));
      expect(controller.stats.onlineDraws, equals(0));

      controller.recordOnlineGamePlayed(won: false);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.onlineGamesPlayed, equals(2));
      expect(controller.stats.onlineWins, equals(1));
      expect(controller.stats.onlineLosses, equals(1));
      expect(controller.stats.onlineDraws, equals(0));

      controller.recordOnlineGamePlayed(isDraw: true);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.onlineGamesPlayed, equals(3));
      expect(controller.stats.onlineWins, equals(1));
      expect(controller.stats.onlineLosses, equals(1));
      expect(controller.stats.onlineDraws, equals(1));
      expect(controller.stats.totalDraws, equals(1));
    });

    test('recordBotGamePlayed tracks win, loss, and draw per difficulty', () {
      controller.recordBotGamePlayed(won: true, difficulty: BotDifficulty.hard);

      expect(controller.stats.botGamesPlayed, equals(1));
      expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botLossesFor(BotDifficulty.hard), equals(0));
      expect(controller.stats.botDrawsFor(BotDifficulty.hard), equals(0));

      controller.recordBotGamePlayed(
        won: false,
        difficulty: BotDifficulty.hard,
      );

      expect(controller.stats.botGamesPlayed, equals(2));
      expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(2));
      expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botLossesFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botDrawsFor(BotDifficulty.hard), equals(0));

      controller.recordBotGamePlayed(
        won: false,
        difficulty: BotDifficulty.hard,
        isDraw: true,
      );

      expect(controller.stats.botGamesPlayed, equals(3));
      expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(3));
      expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botLossesFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.botDrawsFor(BotDifficulty.hard), equals(1));
      expect(controller.stats.totalBotDraws, equals(1));
      expect(controller.stats.totalDraws, equals(1));
    });

    test(
      'syncWithCloud merges remote stats and persists to local and cloud',
      () async {
        controller.recordLocalGamePlayed(winner: Player.one);
        controller.recordLocalGamePlayed(winner: Player.two);
        controller.recordLocalGamePlayed(isDraw: true);
        controller.recordBotGamePlayed(
          won: true,
          difficulty: BotDifficulty.hard,
        );
        await Future<void>.delayed(Duration.zero);

        fakePlayGamesService.signedIn = true;
        fakePlayGamesService.cloudSaveData = jsonEncode(
          const GameStats(
            localGamesPlayed: 5,
            localPlayer1Wins: 3,
            localPlayer2Wins: 1,
            localDraws: 1,
            onlineGamesPlayed: 10,
            onlineWins: 6,
            onlineLosses: 3,
            onlineDraws: 1,
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
            botLosses: {
              BotDifficulty.easy: 1,
              BotDifficulty.medium: 2,
              BotDifficulty.hard: 0,
              BotDifficulty.expert: 0,
            },
            botDraws: {
              BotDifficulty.easy: 0,
              BotDifficulty.medium: 0,
              BotDifficulty.hard: 0,
              BotDifficulty.expert: 0,
            },
          ).toJson(),
        );

        await controller.syncWithCloud();

        expect(controller.syncStatus, equals(CloudSyncStatus.synced));
        expect(controller.accountName, equals('TestPlayer'));

        expect(controller.stats.localGamesPlayed, equals(5));
        expect(controller.stats.localPlayer1Wins, equals(3));
        expect(controller.stats.localPlayer2Wins, equals(1));
        expect(controller.stats.localDraws, equals(1));

        expect(controller.stats.onlineGamesPlayed, equals(10));
        expect(controller.stats.onlineWins, equals(6));
        expect(controller.stats.onlineLosses, equals(3));
        expect(controller.stats.onlineDraws, equals(1));

        expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(1));
        expect(controller.stats.botGamesFor(BotDifficulty.hard), equals(1));
        expect(controller.stats.botWinsFor(BotDifficulty.easy), equals(3));
        expect(controller.stats.botWinsFor(BotDifficulty.medium), equals(2));

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

  group('Achievements Integration Tests', () {
    setUp(() {
      fakePlayGamesService.signedIn = true;
    });

    test('unlocks 1-game and 10-games local achievements', () async {
      controller.recordLocalGamePlayed(winner: Player.one);
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playLocal1),
      );
      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playLocal10],
        equals(1),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        isNot(contains(AchievementIds.playLocal10)),
      );

      for (int i = 0; i < 9; i++) {
        controller.recordLocalGamePlayed(winner: Player.two);
      }
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playLocal10],
        equals(10),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playLocal10),
      );
    });

    test('unlocks 1-game and 10-games online achievements', () async {
      controller.recordOnlineGamePlayed(won: true);
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playOnline1),
      );
      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playOnline10],
        equals(1),
      );

      for (int i = 0; i < 9; i++) {
        controller.recordOnlineGamePlayed(won: false);
      }
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playOnline10],
        equals(10),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playOnline10),
      );
    });

    test('unlocks 1-game and 10-games bot achievements', () async {
      controller.recordBotGamePlayed(
        won: false,
        difficulty: BotDifficulty.easy,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playBot1),
      );
      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playBot10],
        equals(1),
      );

      for (int i = 0; i < 9; i++) {
        controller.recordBotGamePlayed(
          won: false,
          difficulty: BotDifficulty.easy,
        );
      }
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playBot10],
        equals(10),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playBot10),
      );
    });

    test('unlocks achievements for defeating each bot difficulty', () async {
      controller.recordBotGamePlayed(won: true, difficulty: BotDifficulty.easy);
      await Future<void>.delayed(Duration.zero);
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.defeatBotEasy),
      );

      controller.recordBotGamePlayed(
        won: true,
        difficulty: BotDifficulty.medium,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.defeatBotMedium),
      );

      controller.recordBotGamePlayed(won: true, difficulty: BotDifficulty.hard);
      await Future<void>.delayed(Duration.zero);
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.defeatBotHard),
      );

      controller.recordBotGamePlayed(
        won: true,
        difficulty: BotDifficulty.expert,
      );
      await Future<void>.delayed(Duration.zero);
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.defeatBotExpert),
      );
    });

    test('bot loss does not unlock defeat bot achievements', () async {
      controller.recordBotGamePlayed(
        won: false,
        difficulty: BotDifficulty.expert,
      );
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.unlockedAchievements,
        isNot(contains(AchievementIds.defeatBotExpert)),
      );
    });

    test('unlocks 100 total games milestone achievement', () async {
      for (int i = 0; i < 99; i++) {
        controller.recordLocalGamePlayed(winner: Player.one);
      }
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playTotal100],
        equals(99),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        isNot(contains(AchievementIds.playTotal100)),
      );

      controller.recordOnlineGamePlayed(won: true);
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.achievementSteps[AchievementIds.playTotal100],
        equals(100),
      );
      expect(
        fakePlayGamesService.unlockedAchievements,
        contains(AchievementIds.playTotal100),
      );
    });

    test(
      'local draw increments totalDraws and unlocks draw achievement',
      () async {
        expect(controller.stats.totalDraws, equals(0));
        controller.recordLocalGamePlayed(isDraw: true);
        await Future<void>.delayed(Duration.zero);

        expect(controller.stats.localGamesPlayed, equals(1));
        expect(controller.stats.localDraws, equals(1));
        expect(controller.stats.totalDraws, equals(1));
        expect(
          fakePlayGamesService.unlockedAchievements,
          contains(AchievementIds.drawGame),
        );
      },
    );

    test(
      'online draw increments totalDraws and unlocks draw achievement',
      () async {
        expect(controller.stats.totalDraws, equals(0));
        controller.recordOnlineGamePlayed(isDraw: true);
        await Future<void>.delayed(Duration.zero);

        expect(controller.stats.onlineGamesPlayed, equals(1));
        expect(controller.stats.onlineDraws, equals(1));
        expect(controller.stats.totalDraws, equals(1));
        expect(
          fakePlayGamesService.unlockedAchievements,
          contains(AchievementIds.drawGame),
        );
      },
    );

    test(
      'bot draw increments totalDraws and unlocks draw achievement without bot win',
      () async {
        expect(controller.stats.totalDraws, equals(0));
        controller.recordBotGamePlayed(
          won: false,
          difficulty: BotDifficulty.hard,
          isDraw: true,
        );
        await Future<void>.delayed(Duration.zero);

        expect(controller.stats.botGamesPlayed, equals(1));
        expect(controller.stats.botDrawsFor(BotDifficulty.hard), equals(1));
        expect(controller.stats.totalDraws, equals(1));
        expect(controller.stats.botWinsFor(BotDifficulty.hard), equals(0));
        expect(
          fakePlayGamesService.unlockedAchievements,
          contains(AchievementIds.drawGame),
        );
      },
    );

    test('non-draw game does not unlock draw achievement', () async {
      controller.recordLocalGamePlayed(winner: Player.one);
      controller.recordOnlineGamePlayed(won: true);
      controller.recordBotGamePlayed(won: true, difficulty: BotDifficulty.easy);
      await Future<void>.delayed(Duration.zero);

      expect(controller.stats.totalDraws, equals(0));
      expect(
        fakePlayGamesService.unlockedAchievements,
        isNot(contains(AchievementIds.drawGame)),
      );
    });

    test('cloud sync evaluates and unlocks retroactive achievements', () async {
      fakePlayGamesService.cloudSaveData = jsonEncode(
        const GameStats(
          localGamesPlayed: 15,
          localDraws: 1,
          onlineGamesPlayed: 10,
          onlineDraws: 1,
          botGamesPlayed: 12,
          botWins: {
            BotDifficulty.easy: 5,
            BotDifficulty.medium: 4,
            BotDifficulty.hard: 2,
            BotDifficulty.expert: 1,
          },
        ).toJson(),
      );

      await controller.syncWithCloud();
      await Future<void>.delayed(Duration.zero);

      expect(
        fakePlayGamesService.unlockedAchievements,
        containsAll([
          AchievementIds.playLocal1,
          AchievementIds.playLocal10,
          AchievementIds.playOnline1,
          AchievementIds.playOnline10,
          AchievementIds.playBot1,
          AchievementIds.playBot10,
          AchievementIds.defeatBotEasy,
          AchievementIds.defeatBotMedium,
          AchievementIds.defeatBotHard,
          AchievementIds.defeatBotExpert,
          AchievementIds.drawGame,
        ]),
      );
    });

    test('showAchievements forwards call to PlayGamesService', () async {
      await controller.showAchievements();
      expect(fakePlayGamesService.showAchievementsCalled, isTrue);
    });
  });
}
