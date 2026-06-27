import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/enum/player.dart';
import '../models/move_parameters.dart';
import '../utils/bot_player/bot_isolate.dart';
import 'game_controller.dart';

class BotGameController extends ChangeNotifier {
  late final BotIsolate _aiIsolate;
  bool aiThinking = false;

  final GameController _gameController;

  BotGameController({required GameController gameController})
    : _gameController = gameController {
    _aiIsolate = BotIsolate(_gameController.gameSetup.botDifficulty!);
    _gameController.addListener(_handleGameStateChanged);

    _checkBotTurn();
  }

  @override
  void dispose() {
    _gameController.removeListener(_handleGameStateChanged);
    super.dispose();
  }

  void _handleGameStateChanged() {
    _checkBotTurn();
  }

  void _checkBotTurn() {
    if (_gameController.gameFinished) return;
    if (_gameController.currentPlayer == Player.two && !aiThinking) {
      _makeBotMove();
    }
  }

  Future<void> _makeBotMove() async {
    aiThinking = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final moveParameters = MoveParameters(
      _gameController.subBoards,
      _gameController.subBoardWinners,
      Player.two,
      _gameController.activeSubBoardIndex,
      _gameController.gameSetup.botDifficulty!,
    );

    final move = await _aiIsolate.computeMove(moveParameters);

    aiThinking = false;
    notifyListeners();

    if (move != null) {
      _gameController.makeMove(move.boardIndex, move.cellIndex, isBot: true);
    }
  }
}
