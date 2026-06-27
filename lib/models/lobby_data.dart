import 'package:ultimate_tic_tac_toe/models/game_data.dart';
import 'package:ultimate_tic_tac_toe/models/game_setup.dart';

class LobbyData {
  final String? state;
  final GameData? gameData;
  final GameSetup? gameSetup;
  final String? hostId;
  final String? guestId;

  LobbyData({
    this.state,
    this.gameData,
    this.gameSetup,
    this.hostId,
    this.guestId,
  });

  factory LobbyData.fromJson(Map<String, dynamic> json) {
    return LobbyData(
      state: json['state'] as String,
      gameData: json['gameData'] != null
          ? GameData.fromJson(json['gameData'] as Map<String, dynamic>)
          : null,
      gameSetup: json['gameSetup'] != null
          ? GameSetup.fromJson(json['gameSetup'] as Map<String, dynamic>)
          : null,
      hostId: json['hostId'] as String?,
      guestId: json['guestId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (state != null) 'state': state,
      if (gameData != null) 'gameData': gameData!.toJson(),
      if (gameSetup != null) 'gameSetup': gameSetup!.toJson(),
      if (hostId != null) 'hostId': hostId,
      if (guestId != null) 'guestId': guestId,
    };
  }
}
