import 'package:flutter/material.dart';
import '../../extensions/string_extension.dart';
import '../../models/enum/game_mode.dart';

enum ContinueGameAction { continueGame, newGame }

/// Dialog prompted when a player selects a game mode that has an in-progress game.
class ContinueGameDialog extends StatelessWidget {
  const ContinueGameDialog({super.key, required this.gameMode});

  final GameMode gameMode;

  @override
  Widget build(BuildContext context) {
    final modeLabel = '${gameMode.name.capitalize()} Game';

    return AlertDialog(
      title: const Text('Continue saved game?'),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [
          ElevatedButton(
            onPressed:
                () => Navigator.of(context).pop(ContinueGameAction.newGame),
            child: const Text('New Game'),
          ),
          FilledButton(
            onPressed:
                () =>
                    Navigator.of(context).pop(ContinueGameAction.continueGame),
            child: const Text('Continue'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
