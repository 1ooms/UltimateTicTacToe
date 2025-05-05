import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/board/big_board.dart';
import 'package:ultimate_tic_tac_toe/widgets/dialogs/player_setup.dart';

import '../../models/player_config.dart';
import '../../models/player_setup_result.dart';

class LocalGameScreen extends StatefulWidget {
  LocalGameScreen({
    super.key,
    required this.player1,
    required this.player2,
    required this.player1Starts,
  });

  PlayerConfig player1;
  PlayerConfig player2;
  bool player1Starts;

  @override
  State<LocalGameScreen> createState() => _LocalGameScreenState();
}

class _LocalGameScreenState extends State<LocalGameScreen> {
  bool gameStarted = false;

  final GlobalKey<BigBoardState> _boardKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((ctx) {
      _showPlayerSetupDialog(context);
    });
  }

  Future<void> _showPlayerSetupDialog(BuildContext context) async {
    final result = await showDialog<PlayerSetupResult>(
      context: context,
      builder: (context) => PlayerSetup(),
    );

    if (result != null) {
      setState(() {
        widget.player1 = result.player1;
        widget.player2 = result.player2;
        widget.player1Starts = result.player1Starts;
        gameStarted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Local Game'),
        actions: [
          IconButton(
            onPressed: () {
              _boardKey.currentState?.performUndo();
            },
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            gameStarted
                ? BigBoard(
                  key: _boardKey,
                  player1: widget.player1,
                  player2: widget.player2,
                  player1Starts: widget.player1Starts,
                )
                : const Text("Waiting for game to start..."),
          ],
        ),
      ),
    );
  }
}
