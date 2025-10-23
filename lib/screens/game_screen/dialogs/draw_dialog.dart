import 'package:flutter/material.dart';

class DrawDialog extends StatelessWidget {
  const DrawDialog({
    super.key,
    required this.onPlayAgain,
    required this.onViewBoard,
  });

  final Function onPlayAgain;
  final Function onViewBoard;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('It\'s a draw!'),
      content: const Text('No more moves left.'),
      actions: [
        TextButton(
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
