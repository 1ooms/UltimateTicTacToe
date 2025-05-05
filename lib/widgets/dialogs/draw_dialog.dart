import 'package:flutter/material.dart';

class DrawDialog extends StatefulWidget {
  const DrawDialog({super.key, required this.onPlayAgain});

  final Function onPlayAgain;

  @override
  State<DrawDialog> createState() => _DrawDialogState();
}

class _DrawDialogState extends State<DrawDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('It\'s a draw!'),
      content: const Text('No more moves left.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            widget.onPlayAgain();
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
      ],
    );
  }
}
