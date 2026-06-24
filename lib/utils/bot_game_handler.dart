part of 'game_controller.dart';

mixin BotHandler on ChangeNotifier {
  late final BotIsolate _aiIsolate;
  bool aiThinking = false;

  void initBot() {
    final controller = this as GameController;
    if (controller.gameMode == GameMode.bot) {
      _aiIsolate = BotIsolate(controller.gameSetup.botDifficulty!);
    }
  }

  Future<void> makeBotMove() async {
    if (aiThinking) return;
    aiThinking = true;
    notifyListeners();

    final controller = this as GameController;

    await Future.delayed(const Duration(milliseconds: 500));

    final moveParameters = MoveParameters(
      controller.subBoards,
      controller.subBoardWinners,
      Player.two,
      controller.activeSubBoardIndex,
      controller.gameSetup.botDifficulty!,
    );

    final move = await _aiIsolate.computeMove(moveParameters);

    aiThinking = false;

    if (move != null) {
      controller.handleTap(move.boardIndex, move.cellIndex);
    } else {
      notifyListeners();
    }
  }
}
