import 'enum/game_mode.dart';
import 'game_data.dart';
import 'game_setup.dart';

/// Represents a persisted snapshot of an in-progress game.
class SavedGame {
  final GameMode gameMode;
  final GameSetup gameSetup;
  final GameData gameData;
  final DateTime savedAt;

  const SavedGame({
    required this.gameMode,
    required this.gameSetup,
    required this.gameData,
    required this.savedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'gameMode': gameMode.name,
      'gameSetup': gameSetup.toJson(),
      'gameData': gameData.toJson(),
      'savedAt': savedAt.toIso8601String(),
    };
  }

  factory SavedGame.fromJson(Map<String, dynamic> json) {
    return SavedGame(
      gameMode: GameMode.values.byName(json['gameMode'] as String),
      gameSetup: GameSetup.fromJson(
        Map<String, dynamic>.from(json['gameSetup'] as Map),
      ),
      gameData: GameData.fromJson(
        Map<String, dynamic>.from(json['gameData'] as Map),
      ),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}
