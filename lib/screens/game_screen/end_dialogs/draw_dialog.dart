import 'package:flutter/material.dart';

import '../../../models/enum/game_mode.dart';

class DrawDialog extends StatelessWidget {
  const DrawDialog({
    super.key,
    required this.onPlayAgain,
    required this.onViewBoard,
    required this.gameMode,
    required this.isHost,
  });

  final Function onPlayAgain;
  final Function onViewBoard;
  final GameMode gameMode;
  final bool? isHost;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('It\'s a draw!'),
      content: const Text('No more moves left.'),
      actions: [
        gameMode == GameMode.online && isHost != true
            ? const SizedBox()
            : TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
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
