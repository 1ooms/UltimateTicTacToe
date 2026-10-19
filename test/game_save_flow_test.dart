import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/ad_controller.dart';
import 'package:ultimate_tic_tac_toe/controllers/audio_controller.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';
import 'package:ultimate_tic_tac_toe/models/game_data.dart';
import 'package:ultimate_tic_tac_toe/models/game_setup.dart';
import 'package:ultimate_tic_tac_toe/models/move.dart';
import 'package:ultimate_tic_tac_toe/models/player_config.dart';
import 'package:ultimate_tic_tac_toe/models/saved_game.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/board/ultimate_board.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_setup_dialogs/game_setup/game_setup_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/continue_game_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/game_mode_card.dart';
import 'package:ultimate_tic_tac_toe/screens/home_screen/home_screen.dart';
import 'package:ultimate_tic_tac_toe/services/game_save_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AdController().adSettingNotifier.value = false;
    AudioController().soundSetting = false;
  });

  SavedGame createSampleSavedGame(GameMode mode) {
    final setup = GameSetup(
      player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
      player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
      player1Starts: true,
      botDifficulty: mode == GameMode.bot ? BotDifficulty.medium : null,
    );
    final subBoards = List.generate(9, (_) => List<Player?>.filled(9, null));
    subBoards[0][4] = Player.one;

    return SavedGame(
      gameMode: mode,
      gameSetup: setup,
      gameData: GameData(
        currentPlayer: Player.two,
        activeSubBoardIndex: 4,
        subBoardWinners: List<Player?>.filled(9, null),
        subBoards: subBoards,
        moveHistory: [Move(0, 4, Player.one, null)],
        gameFinished: false,
      ),
      savedAt: DateTime.now(),
    );
  }

  Widget createHomeScreen({GameSaveService? gameSaveService}) {
    return MaterialApp(
      home: HomeScreen(
        onChangeThemeMode: (_) {},
        themeMode: ThemeMode.light,
        showWelcomeDialog: false,
        gameSaveService: gameSaveService,
      ),
    );
  }

  testWidgets('tapping local game with no saved game opens GameScreen setup', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(createHomeScreen());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(GameModeCard, 'Local game'));
    await tester.pumpAndSettle();

    // No ContinueGameDialog
    expect(find.byType(ContinueGameDialog), findsNothing);
    // GameSetupDialog is displayed
    expect(find.byType(GameSetupDialog), findsOneWidget);
  });

  testWidgets(
    'tapping local game with saved game prompts ContinueGameDialog, and Continue resumes match',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final saveService = GameSaveService();
      final sample = createSampleSavedGame(GameMode.local);
      await saveService.saveGame(
        mode: GameMode.local,
        setup: sample.gameSetup,
        data: sample.gameData,
      );

      await tester.pumpWidget(createHomeScreen(gameSaveService: saveService));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(GameModeCard, 'Local game'));
      await tester.pumpAndSettle();

      // ContinueGameDialog should be shown
      expect(find.byType(ContinueGameDialog), findsOneWidget);

      // Tap 'Continue'
      await tester.tap(find.widgetWithText(ElevatedButton, 'Continue'));
      await tester.pumpAndSettle();

      // Should be in GameScreen with restored board, and NO GameSetupDialog
      expect(find.byType(GameSetupDialog), findsNothing);
      expect(find.byType(UltimateBoard), findsOneWidget);
    },
  );

  testWidgets(
    'tapping New Game in ContinueGameDialog clears saved game and opens setup dialog',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final saveService = GameSaveService();
      final sample = createSampleSavedGame(GameMode.local);
      await saveService.saveGame(
        mode: GameMode.local,
        setup: sample.gameSetup,
        data: sample.gameData,
      );

      await tester.pumpWidget(createHomeScreen(gameSaveService: saveService));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(GameModeCard, 'Local game'));
      await tester.pumpAndSettle();

      expect(find.byType(ContinueGameDialog), findsOneWidget);

      // Tap 'New Game'
      await tester.tap(find.widgetWithText(TextButton, 'New Game'));
      await tester.pumpAndSettle();

      // Saved game should be cleared
      expect(await saveService.hasSavedGame(GameMode.local), isFalse);

      // Fresh GameSetupDialog should now be shown
      expect(find.byType(GameSetupDialog), findsOneWidget);
    },
  );

  testWidgets('online game never shows ContinueGameDialog', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final saveService = GameSaveService();
    final sample = createSampleSavedGame(GameMode.local);
    await saveService.saveGame(
      mode: GameMode.local,
      setup: sample.gameSetup,
      data: sample.gameData,
    );

    await tester.pumpWidget(createHomeScreen(gameSaveService: saveService));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(GameModeCard, 'Online game'), findsOneWidget);
    expect(find.byType(ContinueGameDialog), findsNothing);
  });
}
