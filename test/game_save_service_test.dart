import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/controllers/game_controller.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';
import 'package:ultimate_tic_tac_toe/models/game_data.dart';
import 'package:ultimate_tic_tac_toe/models/game_setup.dart';
import 'package:ultimate_tic_tac_toe/models/move.dart';
import 'package:ultimate_tic_tac_toe/models/player_config.dart';
import 'package:ultimate_tic_tac_toe/models/saved_game.dart';
import 'package:ultimate_tic_tac_toe/services/game_save_service.dart';

import 'package:ultimate_tic_tac_toe/controllers/audio_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AudioController().soundSetting = false;
  });

  group('GameSetup Serialization', () {
    test('serializes and deserializes botDifficulty properly', () {
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: true,
        botDifficulty: BotDifficulty.hard,
      );

      final json = setup.toJson();
      expect(json['botDifficulty'], equals('hard'));

      final restored = GameSetup.fromJson(json);
      expect(restored.botDifficulty, equals(BotDifficulty.hard));
      expect(restored.player1Starts, isTrue);
      expect(restored.player1.shape, equals(PlayerShape.cross));
    });

    test('handles null botDifficulty', () {
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: false,
        botDifficulty: null,
      );

      final json = setup.toJson();
      expect(json['botDifficulty'], isNull);

      final restored = GameSetup.fromJson(json);
      expect(restored.botDifficulty, isNull);
      expect(restored.player1Starts, isFalse);
    });
  });

  group('SavedGame Model', () {
    test('serializes and deserializes complete game state', () {
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: true,
        botDifficulty: BotDifficulty.medium,
      );

      final subBoards = List.generate(9, (i) => List<Player?>.filled(9, null));
      subBoards[0][4] = Player.one;

      final gameData = GameData(
        currentPlayer: Player.two,
        activeSubBoardIndex: 4,
        subBoardWinners: List<Player?>.filled(9, null),
        subBoards: subBoards,
        moveHistory: [Move(0, 4, Player.one, null)],
        gameFinished: false,
        overallWinner: null,
      );

      final savedGame = SavedGame(
        gameMode: GameMode.bot,
        gameSetup: setup,
        gameData: gameData,
        savedAt: DateTime(2026, 10, 19, 14, 0),
      );

      final json = savedGame.toJson();
      final restored = SavedGame.fromJson(json);

      expect(restored.gameMode, equals(GameMode.bot));
      expect(restored.gameSetup.botDifficulty, equals(BotDifficulty.medium));
      expect(restored.gameData.currentPlayer, equals(Player.two));
      expect(restored.gameData.activeSubBoardIndex, equals(4));
      expect(restored.gameData.subBoards[0][4], equals(Player.one));
      expect(restored.gameData.moveHistory.length, equals(1));
      expect(restored.gameData.moveHistory.first.boardIndex, equals(0));
      expect(restored.gameData.moveHistory.first.cellIndex, equals(4));
      expect(restored.savedAt, equals(DateTime(2026, 10, 19, 14, 0)));
    });
  });

  group('GameSaveService', () {
    test(
      'save, get, has, and clear operations for local and bot modes',
      () async {
        final service = GameSaveService();

        expect(await service.hasSavedGame(GameMode.local), isFalse);
        expect(await service.getSavedGame(GameMode.local), isNull);

        final setup = GameSetup(
          player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
          player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
          player1Starts: true,
        );

        final gameData = GameData(
          currentPlayer: Player.one,
          subBoardWinners: List<Player?>.filled(9, null),
          subBoards: List.generate(9, (_) => List<Player?>.filled(9, null)),
          moveHistory: [],
          gameFinished: false,
        );

        // Save local game
        await service.saveGame(
          mode: GameMode.local,
          setup: setup,
          data: gameData,
        );

        expect(await service.hasSavedGame(GameMode.local), isTrue);
        expect(await service.hasSavedGame(GameMode.bot), isFalse);

        final loaded = await service.getSavedGame(GameMode.local);
        expect(loaded, isNotNull);
        expect(loaded!.gameMode, equals(GameMode.local));

        // Clear local game
        await service.clearSavedGame(GameMode.local);
        expect(await service.hasSavedGame(GameMode.local), isFalse);
        expect(await service.getSavedGame(GameMode.local), isNull);
      },
    );

    test('ignores online game mode', () async {
      final service = GameSaveService();
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: true,
      );
      final gameData = GameData(
        currentPlayer: Player.one,
        subBoardWinners: List<Player?>.filled(9, null),
        subBoards: List.generate(9, (_) => List<Player?>.filled(9, null)),
        moveHistory: [],
        gameFinished: false,
      );

      await service.saveGame(
        mode: GameMode.online,
        setup: setup,
        data: gameData,
      );

      expect(await service.hasSavedGame(GameMode.online), isFalse);
      expect(await service.getSavedGame(GameMode.online), isNull);
    });

    test('does not save or return finished games', () async {
      final service = GameSaveService();
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: true,
      );
      final finishedData = GameData(
        currentPlayer: Player.one,
        subBoardWinners: List<Player?>.filled(9, null),
        subBoards: List.generate(9, (_) => List<Player?>.filled(9, null)),
        moveHistory: [],
        gameFinished: true,
        overallWinner: Player.one,
      );

      await service.saveGame(
        mode: GameMode.local,
        setup: setup,
        data: finishedData,
      );

      expect(await service.hasSavedGame(GameMode.local), isFalse);
      expect(await service.getSavedGame(GameMode.local), isNull);
    });
  });

  group('GameController.restore and toGameData', () {
    test('restores board, active subboard, and supports undo', () {
      final setup = GameSetup(
        player1: PlayerConfig(shape: PlayerShape.cross, color: Colors.red),
        player2: PlayerConfig(shape: PlayerShape.circle, color: Colors.blue),
        player1Starts: true,
      );

      final controller = GameController(
        gameMode: GameMode.local,
        gameSetup: setup,
      );

      controller.makeMove(0, 4); // Player 1 moves at board 0, cell 4
      expect(controller.currentPlayer, equals(Player.two));
      expect(controller.activeSubBoardIndex, equals(4));

      final exportedData = controller.toGameData();
      expect(exportedData.currentPlayer, equals(Player.two));
      expect(exportedData.activeSubBoardIndex, equals(4));
      expect(exportedData.subBoards[0][4], equals(Player.one));
      expect(exportedData.moveHistory.length, equals(1));

      // Restore to a new controller
      final restoredController = GameController.restore(
        gameMode: GameMode.local,
        gameSetup: setup,
        savedData: exportedData,
      );

      expect(restoredController.currentPlayer, equals(Player.two));
      expect(restoredController.activeSubBoardIndex, equals(4));
      expect(restoredController.subBoards[0][4], equals(Player.one));
      expect(restoredController.moveHistory.length, equals(1));

      // Check undo functionality on restored controller
      restoredController.undoMove();
      expect(restoredController.currentPlayer, equals(Player.one));
      expect(restoredController.activeSubBoardIndex, isNull);
      expect(restoredController.subBoards[0][4], isNull);
      expect(restoredController.moveHistory, isEmpty);
    });
  });
}
