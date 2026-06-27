import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../../models/enum/game_mode.dart';
import '../../../models/enum/player.dart';
import '../../../models/player_config.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({
    super.key,
    required this.gameMode,
    required this.isHost,
    required this.viewingBoard,
    required this.confettiController,
    required this.onPlayAgain,
    required this.buildIcon,
    required this.winningPlayer,
    required this.winnerConfig,
    required this.onViewBoard,
  });

  final GameMode gameMode;
  final bool? isHost;
  final Player winningPlayer;
  final PlayerConfig winnerConfig;
  final bool viewingBoard;
  final ConfettiController confettiController;
  final Function onPlayAgain;
  final Function onViewBoard;
  final Function buildIcon;

  @override
  Widget build(BuildContext context) {
    var title = '';

    if (gameMode == GameMode.online) {
      if (isHost == true && winningPlayer == Player.one ||
          isHost == false && winningPlayer == Player.two) {
        title = 'You have won!';
      } else {
        title = 'You have lost!';
      }
    } else if (gameMode == GameMode.bot) {
      if (winningPlayer == Player.one) {
        title = 'You have won!';
      } else {
        title = 'The bot has won!';
      }
    } else {
      title = 'We have a winner!';
    }

    return AlertDialog(
      title: Text(title),
      content: Row(
        children: [
          const Text('Winner: '),
          buildIcon(winnerConfig.shape, winnerConfig.color, 28.toDouble()),
        ],
      ),
      actions: [
        gameMode == GameMode.online && isHost != true
            ? const SizedBox()
            : TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                confettiController.stop();
                onPlayAgain();
              },
              child: const Text('Play Again'),
            ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Go back to Home
          },
          child: const Text('Return Home'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onViewBoard();
          },
          child: const Text('View board'),
        ),
      ],
    );
  }
}
