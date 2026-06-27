import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/controllers/online_game_controller.dart';

class SessionEndedDialog extends StatefulWidget {
  const SessionEndedDialog({
    super.key,
    required this.onlineGameController,
    required this.lobbyCode,
  });

  final OnlineGameController? onlineGameController;
  final String? lobbyCode;

  @override
  State<SessionEndedDialog> createState() => _SessionEndedDialogState();
}

class _SessionEndedDialogState extends State<SessionEndedDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: const Text("The other player left the game."),
      actions: [
        TextButton(
          onPressed: () {
            widget.onlineGameController?.stopHosting();
            Navigator.of(context).pop(); // Pop the dialog
            Navigator.of(context).pop(); // Pop the screen
          },
          child: const Text('Return home'),
        ),
      ],
    );
  }
}
