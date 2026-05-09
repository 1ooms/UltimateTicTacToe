import 'package:ultimate_tic_tac_toe/models/player_config.dart';

import 'enum/bot_difficulty.dart';

class GameSetup {
  PlayerConfig player1;
  PlayerConfig player2;
  bool player1Starts;
  BotDifficulty? botDifficulty;

  GameSetup({
    required this.player1,
    required this.player2,
    required this.player1Starts,
    this.botDifficulty,
  });
}
