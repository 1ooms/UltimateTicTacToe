import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/stats_controller.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/game_stats.dart';
import 'package:ultimate_tic_tac_toe/screens/statistics_screen/statistics_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    StatsController().resetForTesting();
  });

  Widget buildSubject({Size size = const Size(400, 800)}) {
    return MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: const StatisticsScreen(),
      ),
    );
  }

  group('StatisticsScreen Widget Tests', () {
    testWidgets('renders all headers and default zero metrics', (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Statistics'), findsOneWidget);

      // Section headers
      expect(find.text('Total Played'), findsOneWidget);
      expect(find.text('Bot Games Won'), findsOneWidget);
      expect(find.text('Games played per mode'), findsOneWidget);
      expect(find.text('Bot Games By Difficulty'), findsOneWidget);

      // Mode cards
      expect(find.text('Local Games'), findsOneWidget);
      expect(find.text('Online Games'), findsOneWidget);
      expect(find.text('Bot Games'), findsOneWidget);

      // Bot difficulty tiles
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
      expect(find.text('Expert'), findsOneWidget);

      // Metric labels per difficulty (4 tiles x 1 each)
      expect(find.text('Games Played: '), findsNWidgets(4));
      expect(find.text('Games Won: '), findsNWidgets(4));
      expect(find.text('Win Rate: '), findsNWidgets(4));
    });

    testWidgets('displays updated stats correctly', (tester) async {
      const customStats = GameStats(
        localGamesPlayed: 14,
        onlineGamesPlayed: 6,
        botGamesPlayed: 10,
        botGamesByDifficulty: {
          BotDifficulty.easy: 6,
          BotDifficulty.medium: 4,
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
        botWins: {
          BotDifficulty.easy: 3, // 50%
          BotDifficulty.medium: 4, // 100%
          BotDifficulty.hard: 0,
          BotDifficulty.expert: 0,
        },
      );

      StatsController().resetForTesting(stats: customStats);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Total played = 14 + 6 + 10 = 30
      expect(find.text('30'), findsOneWidget);
      // Total bot wins = 3 + 4 = 7
      expect(find.text('7'), findsOneWidget);

      // Mode counts
      expect(find.text('14'), findsOneWidget); // Local
      expect(find.text('6'), findsWidgets); // Online & Easy played

      // Specific difficulty metrics
      expect(find.text('50%'), findsOneWidget); // Easy win rate
      expect(find.text('100%'), findsOneWidget); // Medium win rate
      expect(find.text('0%'), findsNWidgets(2)); // Hard & Expert win rate
    });

    testWidgets('renders in landscape without overflow', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(size: const Size(1280, 800)));
      await tester.pumpAndSettle();

      // Confirms both columns are rendered
      expect(find.text('Games played per mode'), findsOneWidget);
      expect(find.text('Bot Games By Difficulty'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('reactively updates UI when StatsController records a game', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Total Played'), findsOneWidget);
      expect(find.text('0'), findsWidgets);

      // Record a bot victory
      StatsController().recordBotGamePlayed(
        won: true,
        difficulty: BotDifficulty.hard,
      );

      await tester.pump();

      // Hard win rate is now 100%
      expect(find.text('100%'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });
  });
}
