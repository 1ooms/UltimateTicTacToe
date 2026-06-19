part of '../screens/game_screen/board/game_state.dart';

mixin OnlineHandler on State<GameState> {
  StreamSubscription? lobbySubscription;
  late Player _localPlayer;

  void _initOnline() {
    if (widget.gameMode == GameMode.online) {
      _localPlayer = widget.isHost! ? Player.one : Player.two;
      _listenOtherPlayerTurn();
    }
  }

  void _disposeOnline() {
    cancelOnlineSubscription();
  }

  void cancelOnlineSubscription() {
    lobbySubscription?.cancel();
  }

  Future<void> _listenOtherPlayerTurn() async {
    final state = this as GameStateState;
    lobbySubscription = widget.lobbyController
        ?.getLobbyStream(widget.lobbyCode!)
        .listen((event) {
      if (!event.exists) return;
      final data = event.data() as Map<String, dynamic>;

      if (data['state'] == 'other_player_left' ||
          (widget.isHost == true && data['state'] == 'waiting')) {
        _showSessionEndedDialog(widget.lobbyCode!);
        return;
      }

      final gameData = data['gameData'] as Map<String, dynamic>?;

      if (widget.isHost != false && data['gameSetup'] != null) {
        final newSetup = GameSetup.fromJson(data['gameSetup']);
        setState(() {
              widget.gameSetup.player1 = newSetup.player1;
              widget.gameSetup.player2 = newSetup.player2;
              widget.gameSetup.player1Starts = newSetup.player1Starts;
            });
          }

          if (gameData == null) {
            if (state._moveHistory.isNotEmpty) {
              state._confettiController.stop();
              if (widget.isHost == false && state._isEndDialogOpen) {
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
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
      'subBoard1': state._subBoards[0].map((p) => p?.name).toList(),
      'subBoard2': state._subBoards[1].map((p) => p?.name).toList(),
      'subBoard3': state._subBoards[2].map((p) => p?.name).toList(),
      'subBoard4': state._subBoards[3].map((p) => p?.name).toList(),
      'subBoard5': state._subBoards[4].map((p) => p?.name).toList(),
      'subBoard6': state._subBoards[5].map((p) => p?.name).toList(),
      'subBoard7': state._subBoards[6].map((p) => p?.name).toList(),
      'subBoard8': state._subBoards[7].map((p) => p?.name).toList(),
      'subBoard9': state._subBoards[8].map((p) => p?.name).toList(),
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
      for (int i = 1; i <= 9; i++) {
        state._subBoards[i - 1] =
            (data['subBoard$i'] as List)
                .map((p) => p != null ? Player.values.byName(p) : null)
                .toList();
      }
      state._moveHistory =
          (data['moveHistory'] as List).map((m) {
            return Move.fromJson(Map<String, dynamic>.from(m as Map));
          }).toList();
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

  Future<void> _showSessionEndedDialog(String lobbyCode) async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => SessionEndedDialog(
            lobbyController: widget.lobbyController,
            lobbyCode: widget.lobbyCode,
          ),
    );
  }
}
