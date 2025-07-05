import 'package:ultimate_tic_tac_toe/models/player_config.dart';

import 'enum/ai_difficulty.dart';

class PlayerSetupResult {
  PlayerConfig player1;
  PlayerConfig player2;
  bool player1Starts;
  AIDifficulty? aiDifficulty;

  PlayerSetupResult({required this.player1, required this.player2, required this.player1Starts, this.aiDifficulty});
}