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

  Map<String, dynamic> toJson() {
    return {
      'player1': player1.toJson(),
      'player2': player2.toJson(),
      'player1Starts': player1Starts,
      'botDifficulty': botDifficulty?.name,
    };
  }

  factory GameSetup.fromJson(Map<String, dynamic> json) {
    return GameSetup(
      player1: PlayerConfig.fromJson(json['player1']),
      player2: PlayerConfig.fromJson(json['player2']),
      player1Starts: json['player1Starts'],
      botDifficulty: json['botDifficulty'] != null
          ? BotDifficulty.values.byName(json['botDifficulty'])
          : null,
    );
  }
}
