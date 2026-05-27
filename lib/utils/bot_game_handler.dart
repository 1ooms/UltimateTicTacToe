part of '../screens/game_screen/board/game_state.dart';

mixin BotHandler on State<GameState> {
  late final BotIsolate _aiIsolate;
  bool _aiThinking = false;

  void _initBot() {
    if (widget.gameMode == GameMode.bot) {
      _aiIsolate = BotIsolate(widget.gameSetup.botDifficulty!);
    }
  }

  Future<void> _makeBotMove() async {
    if (_aiThinking) return;
    _aiThinking = true;

    final state = this as GameStateState;

    await Future.delayed(const Duration(milliseconds: 500));

    final moveParameters = MoveParameters(
      state._subBoards,
      state._subBoardWinners,
      Player.two,
      state._activeSubBoardIndex,
      widget.gameSetup.botDifficulty!,
    );

    final move = await _aiIsolate.computeMove(moveParameters);

    _aiThinking = false;

    if (move != null) {
      state._handleTap(move.boardIndex, move.cellIndex);
    }
  }
}
