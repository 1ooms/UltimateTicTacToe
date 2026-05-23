part of '../screens/game_screen/board/game_state.dart';

mixin OnlineHandler on State<GameState> {
  StreamSubscription? lobbySubscription;
  late Player _localPlayer;

  void _initOnline() {
    _localPlayer = widget.isHost ? Player.one : Player.two;
    if (widget.playingOnline) {
      _listenOtherPlayerTurn();
    }
  }

  void _disposeOnline() {
    lobbySubscription?.cancel();
  }

  Future<void> _listenOtherPlayerTurn() async {
    final state = this as GameStateState;
    lobbySubscription =
        widget.lobbyController?.getLobbyStream(widget.lobbyCode!).listen((
          event,
        ) {
          if (!event.exists) return;
          final data = event.data() as Map<String, dynamic>;
          final gameData = data['gameData'] as Map<String, dynamic>?;

          if (!widget.isHost && data['gameSetup'] != null) {
            final newSetup = GameSetup.fromJson(data['gameSetup']);
            setState(() {
              widget.gameSetup.player1 = newSetup.player1;
              widget.gameSetup.player2 = newSetup.player2;
              widget.gameSetup.player1Starts = newSetup.player1Starts;
            });
          }

          if (gameData == null) {
            if (state._moveHistory.isNotEmpty) {
              setState(() {
                state._initializeGame();
                state._moveHistory.clear();
              });
            }
          } else {
            final List remoteMoveHistory = gameData['moveHistory'] as List;
            if (remoteMoveHistory.length != state._moveHistory.length) {
              _updateStateFromData(gameData);
            }
          }
        });
  }

  Map<String, dynamic> _getGameData() {
    final state = this as GameStateState;
    return {
      'currentPlayer': state._currentPlayer.name,
      'activeSubBoardIndex': state._activeSubBoardIndex,
      'subBoardWinners': state._subBoardWinners.map((p) => p?.name).toList(),
      'subBoards':
          state._subBoards
              .map((board) => board.map((p) => p?.name).toList())
              .toList(),
      'moveHistory': state._moveHistory.map((m) => m.toJson()).toList(),
      'gameFinished': state.gameFinished,
      'overallWinner': state.overallWinner?.name,
    };
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    if (!mounted) return;
    final state = this as GameStateState;
    final bool wasFinished = state.gameFinished;

    setState(() {
      state._currentPlayer = Player.values.byName(data['currentPlayer']);
      state._activeSubBoardIndex = data['activeSubBoardIndex'];
      state._subBoardWinners =
          (data['subBoardWinners'] as List)
              .map((p) => p != null ? Player.values.byName(p) : null)
              .toList();
      state._subBoards =
          (data['subBoards'] as List)
              .map(
                (board) =>
                    (board as List)
                        .map((p) => p != null ? Player.values.byName(p) : null)
                        .toList(),
              )
              .toList();
      state._moveHistory =
          (data['moveHistory'] as List).map((m) => Move.fromJson(m)).toList();
      state.gameFinished = data['gameFinished'];
      state.overallWinner =
          data['overallWinner'] != null
              ? Player.values.byName(data['overallWinner'])
              : null;
    });

    if (!wasFinished && state.gameFinished) {
      if (state.overallWinner != null) {
        state._showWinDialog(state.overallWinner!);
      } else {
        state._showDrawDialog();
      }
    }
  }
}
