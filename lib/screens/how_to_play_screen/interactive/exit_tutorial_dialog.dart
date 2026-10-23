import 'package:flutter/material.dart';

class ExitTutorialDialog extends StatelessWidget {
  const ExitTutorialDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Exit tutorial?'),
      content: const Text(
        'Your progress in the tutorial will not be saved. You can play the tutorial again via the menu.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Exit'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
