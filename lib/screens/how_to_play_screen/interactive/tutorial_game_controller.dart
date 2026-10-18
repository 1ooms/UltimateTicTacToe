import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/controllers/game_controller.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';
import 'package:ultimate_tic_tac_toe/models/game_setup.dart';
import 'package:ultimate_tic_tac_toe/models/player_config.dart';
import 'package:ultimate_tic_tac_toe/models/tutorial_step.dart';

class TutorialGameController extends ChangeNotifier {
  final List<TutorialStep> steps;
  int currentStepIndex = 0;

  late final GameController _game;
  GameController get game => _game;

  bool _isAutoMovePending = false;
  bool get isInteractionLocked => _isAutoMovePending;

  bool _disposed = false;

  final PlayerConfig player1 = PlayerConfig(
    color: Colors.red,
    shape: PlayerShape.cross,
  );

  final PlayerConfig player2 = PlayerConfig(
    color: Colors.blue,
    shape: PlayerShape.circle,
  );

  TutorialGameController({required this.steps}) {
    _game = GameController(
      gameMode: GameMode.local,
      gameSetup: GameSetup(
        player1: player1,
        player2: player2,
        player1Starts: true,
      ),
    );
  }

  TutorialStep get currentStep => steps[currentStepIndex];
  int get totalSteps => steps.length;
  bool get isFinished => currentStep.phase == TutorialPhase.finished;

  /// Handles cell tap from user.
  /// Returns `true` if this tap matched the tutorial's expected move and advanced.
  /// Returns `false` otherwise (wrong cell or wrong phase).
  bool handleUserTap(int boardIndex, int cellIndex) {
    if (_isAutoMovePending || isFinished) return false;
    if (currentStep.phase != TutorialPhase.userMove) return false;

    if (currentStep.boardIndex == boardIndex &&
        currentStep.cellIndex == cellIndex) {
      _game.makeMove(boardIndex, cellIndex);
      advance();
      return true;
    }

    return false;
  }

  /// Advances past informational, consequence, active board, won, fast-forward, or auto-move steps.
  void advance() {
    if (_disposed || _isAutoMovePending || isFinished) return;

    if (currentStepIndex < steps.length - 1) {
      currentStepIndex++;
      notifyListeners();

      if (currentStep.phase == TutorialPhase.autoMove) {
        _executeAutoMove();
      } else if (currentStep.phase == TutorialPhase.fastForward) {
        _executeFastForward();
      }
    }
  }

  Future<void> _executeAutoMove() async {
    _isAutoMovePending = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));
    if (_disposed) return;

    final step = currentStep;
    if (step.phase == TutorialPhase.autoMove &&
        step.boardIndex != null &&
        step.cellIndex != null) {
      _game.makeMove(step.boardIndex!, step.cellIndex!, isBot: true);
    }

    _isAutoMovePending = false;
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> _executeFastForward() async {
    _isAutoMovePending = true;
    notifyListeners();

    final step = currentStep;
    if (step.fastForwardMoves != null) {
      for (final move in step.fastForwardMoves!) {
        await Future.delayed(const Duration(milliseconds: 200));
        if (_disposed) return;
        _game.makeMove(move.$1, move.$2, isBot: true);
        notifyListeners();
      }
    }

    _isAutoMovePending = false;
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _game.dispose();
    super.dispose();
  }
}
