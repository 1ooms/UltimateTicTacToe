import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/dialogs/player_customizer.dart';

import '../../models/player_config.dart';
import '../../models/player_setup_result.dart';

class PlayerSetup extends StatelessWidget {
  PlayerSetup({super.key});

  bool gameStarted = false;
  bool isPlayer1First = true;
  PlayerConfig player1Config = PlayerConfig(
    shape: PlayerShape.cross,
    color: Colors.red,
  );
  PlayerConfig player2Config = PlayerConfig(
    shape: PlayerShape.circle,
    color: Colors.blue,
  );

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [AlertDialog(
            title: const Text('Player Setup'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlayerCustomizer(
                      label: 'Player 1',
                      config1: player1Config,
                      config2: player2Config,
                      onChanged: (config) {
                        setState(() {
                          player1Config = config;
                        });
                      },
                    ),
                    Radio<bool>(
                      value: true,
                      groupValue: isPlayer1First,
                      onChanged: (value) {
                        setState(() {
                          isPlayer1First = true;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PlayerCustomizer(
                      label: 'Player 2',
                      config1: player2Config,
                      config2: player1Config,
                      onChanged: (config) {
                        setState(() {
                          player2Config = config;
                        });
                      },
                    ),
                    Radio<bool>(
                      value: false,
                      groupValue: isPlayer1First,
                      onChanged: (value) {
                        setState(() {
                          isPlayer1First = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(PlayerSetupResult(
                    player1: player1Config,
                    player2: player2Config,
                    player1Starts: isPlayer1First,
                  ));
                },
                child: const Text('Start Game'),
              ),
            ],
          ),

          ]
        );
      },
    );
  }
}
