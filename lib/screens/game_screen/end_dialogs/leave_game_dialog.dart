import 'package:flutter/material.dart';

import '../../../models/enum/game_mode.dart';
import '../../../utils/lobby_controller.dart';

class LeaveGameDialog extends StatefulWidget {
  const LeaveGameDialog({
    super.key,
    required this.gameMode,
    required this.lobbyController,
    required this.lobbyCode,
  });

  final GameMode gameMode;
  final LobbyController? lobbyController;
  final String? lobbyCode;

  @override
  State<LeaveGameDialog> createState() => _LeaveGameDialogState();
}

class _LeaveGameDialogState extends State<LeaveGameDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content:
          widget.gameMode == GameMode.online
              ? const Text("Leave the game? Online session will end.")
              : const Text("Leave the game? Progress will not be saved."),
      actions: [
        TextButton(
          onPressed: () {
            if (widget.gameMode == GameMode.online) {
              widget.lobbyController?.setGameState(
                widget.lobbyCode!,
                'other_player_left',
              );
            }
            Navigator.of(context).pop(); // Pop the dialog
            Navigator.of(context).pop(); // Pop the screen
          },
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}
