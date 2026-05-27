import 'package:flutter/material.dart';

import '../../../utils/lobby_controller.dart';

class SessionEndedDialog extends StatefulWidget {
  const SessionEndedDialog({
    super.key,
    required this.lobbyController,
    required this.lobbyCode,
  });

  final LobbyController? lobbyController;
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
            widget.lobbyController?.deleteLobby(widget.lobbyCode!);
            Navigator.of(context).pop(); // Pop the dialog
            Navigator.of(context).pop(); // Pop the screen
          },
          child: const Text('Return home'),
        ),
      ],
    );
  }
}
