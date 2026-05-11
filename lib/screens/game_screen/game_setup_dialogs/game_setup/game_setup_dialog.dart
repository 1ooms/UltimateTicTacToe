import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/models/enum/bot_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_setup_dialogs/game_setup/player_customizer.dart';

import '../../../../models/enum/game_mode.dart';
import '../../../../models/game_setup.dart';
import '../../../../models/player_config.dart';
import 'difficulty_slider.dart';

class GameSetupDialog extends StatefulWidget {
  const GameSetupDialog({
    super.key,
    required this.gameMode,
    required this.gameStarted,
  });

  final GameMode gameMode;
  final bool gameStarted;

  @override
  State<GameSetupDialog> createState() => _GameSetupDialogState();
}

class _GameSetupDialogState extends State<GameSetupDialog> {
  late SharedPreferences prefs;

  late bool isPlayer1First;
  late PlayerConfig player1Config;
  late PlayerConfig player2Config;
  bool isLoading = true;
  BotDifficulty botDifficulty = BotDifficulty.medium;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    prefs = await SharedPreferences.getInstance();

    final String player1ShapeName =
        prefs.getString('player1Shape') ?? PlayerShape.cross.name;
    final String player2ShapeName =
        prefs.getString('player2Shape') ?? PlayerShape.circle.name;
    final int player1Color =
        prefs.getInt('player1Color') ?? Colors.red.toARGB32();
    final int player2Color =
        prefs.getInt('player2Color') ?? Colors.blue.toARGB32();
    isPlayer1First = prefs.getBool('isPlayer1First') ?? true;
    if (prefs.getString('botDifficulty') != null) {
      botDifficulty = BotDifficulty.values.firstWhere(
        (element) => element.name == prefs.getString('botDifficulty'),
      );
    }

    final player1Shape = PlayerShape.values.firstWhere(
      (e) => e.name == player1ShapeName,
      orElse: () => PlayerShape.cross,
    );

    final player2Shape = PlayerShape.values.firstWhere(
      (e) => e.name == player2ShapeName,
      orElse: () => PlayerShape.circle,
    );

    setState(() {
      player1Config = PlayerConfig(
        color: Color(player1Color),
        shape: player1Shape,
      );
      player2Config = PlayerConfig(
        color: Color(player2Color),
        shape: player2Shape,
      );
      isLoading = false;
    });
  }

  void _savePrefs() async {
    prefs = await SharedPreferences.getInstance();

    prefs.setString('player1Shape', player1Config.shape.name);
    prefs.setString('player2Shape', player2Config.shape.name);
    prefs.setInt('player1Color', player1Config.color.toARGB32());
    prefs.setInt('player2Color', player2Config.color.toARGB32());
    prefs.setBool('isPlayer1First', isPlayer1First);
    prefs.setString('botDifficulty', botDifficulty.name);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    ThemeData theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final gameSetup = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Player', style: theme.textTheme.titleSmall),
            Text('Icon', style: theme.textTheme.titleSmall,),
            Text('Who starts?', style: theme.textTheme.titleSmall),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(height: 24.0),
                widget.gameMode == GameMode.bot
                    ? const Icon(Icons.smart_toy_outlined)
                    : widget.gameMode == GameMode.online
                        ? const Icon(Icons.language)
                        : const Icon(Icons.person_outline),
              ],
            ),
            Column(
              children: [
                PlayerCustomizer(
                  config1: player1Config,
                  config2: player2Config,
                  onChanged: (config) {
                    setState(() {
                      player1Config = config;
                    });
                  },
                ),
                const SizedBox(height: 10),
                PlayerCustomizer(
                  config1: player2Config,
                  config2: player1Config,
                  onChanged: (config) {
                    setState(() {
                      player2Config = config;
                    });
                  },
                ),
              ],
            ),
            RadioGroup<bool>(
              groupValue: isPlayer1First,
              onChanged: (bool? value) {
                setState(() {
                  isPlayer1First = value!;
                });
              },
              child: Column(children: [
                Radio<bool>(value: true,),
                Radio<bool>(value: false,),
              ],)
            )
          ],
        ),
      ],
    );

    final difficultyWidget = DifficultySlider(
      selectedDifficulty: botDifficulty,
      onChanged: (difficulty) {
        setState(() {
          botDifficulty = difficulty;
        });
      },
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !widget.gameStarted) {
          Navigator.of(context).pop(); // Pop the dialog
          Navigator.of(context).pop(); // Pop the screen
        } else if (!didPop && widget.gameStarted) {
          Navigator.of(context).pop();
        }
      },
      child: AlertDialog(
        scrollable: true,
        title: Text('Setup', style: theme.textTheme.titleLarge),
        content: !isLandscape
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  gameSetup,
                  const SizedBox(height: 32),
                  if (widget.gameMode == GameMode.bot) difficultyWidget,
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: gameSetup),
                  if (widget.gameMode == GameMode.bot) ...[
                    const SizedBox(width: 32),
                    Expanded(child: difficultyWidget),
                  ],
                ],
              ),
        actions: [
          TextButton(
            onPressed: () {
              if (widget.gameStarted) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _savePrefs();
              Navigator.of(context).pop(
                GameSetup(
                  player1: player1Config,
                  player2: player2Config,
                  player1Starts: isPlayer1First,
                  botDifficulty: botDifficulty,
                ),
              );
            },
            child: Text(widget.gameStarted ? 'Continue game' : 'Start Game'),
          ),
        ],
      ),
    );
  }
}
