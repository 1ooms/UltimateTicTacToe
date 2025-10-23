import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/models/enum/ai_difficulty.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';
import 'package:ultimate_tic_tac_toe/widgets/dialogs/game_setup/player_icon_preview.dart';
import 'package:ultimate_tic_tac_toe/widgets/difficulty_slider.dart';

import '../../../models/enum/game_mode.dart';
import '../../../models/player_config.dart';
import '../../../models/player_setup_result.dart';

class GameSetup extends StatefulWidget {
  const GameSetup({
    super.key,
    required this.gameMode,
    required this.gameStarted,
  });

  final GameMode gameMode;
  final bool gameStarted;

  @override
  State<GameSetup> createState() => _GameSetupState();
}

class _GameSetupState extends State<GameSetup> {
  late SharedPreferences prefs;

  late bool isPlayer1First;
  late PlayerConfig player1Config;
  late PlayerConfig player2Config;
  bool isLoading = true;
  AIDifficulty aiDifficulty = AIDifficulty.medium;

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
    if (prefs.getString('aiDifficulty') != null) {
      aiDifficulty = AIDifficulty.values.firstWhere(
        (element) => element.name == prefs.getString('aiDifficulty'),
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
    prefs.setString('aiDifficulty', aiDifficulty.name);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    ThemeData theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final playerSetup = Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Players', style: theme.textTheme.titleSmall),
            Text('Who starts?', style: theme.textTheme.titleSmall),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 10),
                PlayerCustomizer(
                  config1: player1Config,
                  config2: player2Config,
                  onChanged: (config) {
                    setState(() {
                      player1Config = config;
                    });
                  },
                ),
              ],
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
            Row(
              children: [
                widget.gameMode == GameMode.computer
                    ? Icon(Icons.smart_toy_outlined)
                    : widget.gameMode == GameMode.online
                    ? Icon(Icons.language)
                    : Icon(Icons.person_outline),
                const SizedBox(width: 10),
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
    );

    final difficultyWidget =
        widget.gameMode == GameMode.computer
            ? DifficultySlider(
              selectedDifficulty: aiDifficulty,
              onChanged: (difficulty) {
                setState(() {
                  aiDifficulty = difficulty;
                });
              },
            )
            : Container();

    return StatefulBuilder(
      builder: (context, setState) {
        return Stack(
          children: [
            PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop) {
                  Navigator.of(context).pop(); // Pop the dialog
                  Navigator.of(context).pop(); // Pop the screen
                }
              },
              child: AlertDialog(
                scrollable: true,
                title: Text('Setup', style: theme.textTheme.titleLarge),
                content:
                    !isLandscape
                        ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            playerSetup,
                            const SizedBox(height: 32),
                            difficultyWidget,
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: playerSetup),
                            const SizedBox(width: 64),
                            Expanded(child: difficultyWidget),
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
                        PlayerSetupResult(
                          player1: player1Config,
                          player2: player2Config,
                          player1Starts: isPlayer1First,
                          aiDifficulty: aiDifficulty,
                        ),
                      );
                    },
                    child:
                        widget.gameStarted
                            ? const Text('Continue game')
                            : const Text('Start Game'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
