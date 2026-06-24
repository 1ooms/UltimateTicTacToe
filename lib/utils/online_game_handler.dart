part of 'game_controller.dart';

mixin OnlineHandler on ChangeNotifier {
  StreamSubscription? lobbySubscription;
  late Player localPlayer;

  void initOnline() {
    final controller = this as GameController;
    if (controller.gameMode == GameMode.online) {
      localPlayer = controller.isHost! ? Player.one : Player.two;
      _listenOtherPlayerTurn();
    }
  }

  void cancelOnlineSubscription() {
    lobbySubscription?.cancel();
  }

  Future<void> _listenOtherPlayerTurn() async {
    final controller = this as GameController;
    lobbySubscription = controller.onlineGameController
        ?.getLobbyStream()
        ?.listen((event) {
          if (!event.exists) return;
          final data = event.data() as Map<String, dynamic>;

          if (data['state'] == 'other_player_left' ||
              (controller.isHost == true && data['state'] == 'waiting')) {
            controller.onOnlineSessionEnded?.call(controller.lobbyCode!);
            return;
          }

          final gameData = data['gameData'] as Map<String, dynamic>?;

          if (controller.isHost != false && data['gameSetup'] != null) {
            final newSetup = GameSetup.fromJson(data['gameSetup']);
            controller.gameSetup.player1 = newSetup.player1;
            controller.gameSetup.player2 = newSetup.player2;
            controller.gameSetup.player1Starts = newSetup.player1Starts;
            notifyListeners();
          }

          if (gameData == null) {
            if (controller.moveHistory.isNotEmpty) {
              controller.onGameRestarted?.call();
              controller._initializeGame();
              controller.moveHistory.clear();
              notifyListeners();
            }
          } else {
            final List remoteMoveHistory = gameData['moveHistory'] as List;
            if (remoteMoveHistory.length != controller.moveHistory.length) {
              _updateStateFromData(gameData);
            }
          }
        });
  }

  Map<String, dynamic> getGameData() {
    final controller = this as GameController;
    return {
      'currentPlayer': controller.currentPlayer.name,
      'activeSubBoardIndex': controller.activeSubBoardIndex,
      'subBoardWinners':
          controller.subBoardWinners.map((p) => p?.name).toList(),
      'subBoard1': controller.subBoards[0].map((p) => p?.name).toList(),
      'subBoard2': controller.subBoards[1].map((p) => p?.name).toList(),
      'subBoard3': controller.subBoards[2].map((p) => p?.name).toList(),
      'subBoard4': controller.subBoards[3].map((p) => p?.name).toList(),
      'subBoard5': controller.subBoards[4].map((p) => p?.name).toList(),
      'subBoard6': controller.subBoards[5].map((p) => p?.name).toList(),
      'subBoard7': controller.subBoards[6].map((p) => p?.name).toList(),
      'subBoard8': controller.subBoards[7].map((p) => p?.name).toList(),
      'subBoard9': controller.subBoards[8].map((p) => p?.name).toList(),
      'moveHistory': controller.moveHistory.map((m) => m.toJson()).toList(),
      'gameFinished': controller.gameFinished,
      'overallWinner': controller.overallWinner?.name,
    };
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    final controller = this as GameController;
    final bool wasFinished = controller.gameFinished;

    controller.currentPlayer = Player.values.byName(data['currentPlayer']);
    controller.activeSubBoardIndex = data['activeSubBoardIndex'];
    controller.subBoardWinners =
        (data['subBoardWinners'] as List)
            .map((p) => p != null ? Player.values.byName(p) : null)
            .toList();
    for (int i = 1; i <= 9; i++) {
      controller.subBoards[i - 1] =
          (data['subBoard$i'] as List)
              .map((p) => p != null ? Player.values.byName(p) : null)
              .toList();
    }
    controller.moveHistory =
        (data['moveHistory'] as List).map((m) {
          return Move.fromJson(Map<String, dynamic>.from(m as Map));
        }).toList();
    controller.gameFinished = data['gameFinished'];
    controller.overallWinner =
        data['overallWinner'] != null
            ? Player.values.byName(data['overallWinner'])
            : null;

    notifyListeners();

    if (!wasFinished && controller.gameFinished) {
      if (controller.overallWinner != null) {
        controller.onWin?.call(controller.overallWinner!);
      } else {
        controller.onDraw?.call();
      }
    }
  }
}
