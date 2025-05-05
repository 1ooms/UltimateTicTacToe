import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../models/player_config.dart';

class WinDialog extends StatelessWidget {
  const WinDialog({
    super.key,
    required this.viewingBoard,
    required this.confettiController,
    required this.onPlayAgain,
    required this.buildIcon,
    required this.winningPlayer,
    required this.winnerConfig,
    required this.onViewBoard,
  });

  final Player winningPlayer;
  final PlayerConfig winnerConfig;
  final bool viewingBoard;
  final ConfettiController confettiController;
  final Function onPlayAgain;
  final Function onViewBoard;
  final Function buildIcon;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('We have a winner!'),
      content: Row(
        children: [
          const Text('Player: '),
          buildIcon(winnerConfig.shape, winnerConfig.color, 28.toDouble()),
        ],
      ),
      actions: [
        TextButton(
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
