import 'game_setup.dart';

class OnlineSetup {
  final String lobbyCode;
  final bool isHost;
  final GameSetup? gameSetup;

  OnlineSetup({
    required this.lobbyCode,
    required this.isHost,
    required this.gameSetup,
  });
}
