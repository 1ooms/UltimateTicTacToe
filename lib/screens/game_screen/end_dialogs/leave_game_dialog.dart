import 'package:flutter/material.dart';

import '../../../models/enum/game_mode.dart';

class LeaveGameDialog extends StatelessWidget {
  const LeaveGameDialog({super.key, required this.gameMode});

  final GameMode gameMode;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content:
          gameMode == GameMode.online
              ? const Text("Leave the game? Online session will end.")
              : const Text("Leave the game? Progress will not be saved."),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('No'),
        ),
      ],
    );
  }
}
