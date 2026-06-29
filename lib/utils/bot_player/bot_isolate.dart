import 'dart:async';
import 'dart:isolate';

import '../../models/enum/bot_difficulty.dart';
import '../../models/move.dart';
import '../../models/move_parameters.dart';
import 'bot_isolate_message.dart';
import 'bot_player.dart';

void _botIsolateEntryPoint(SendPort sendPort) {
  final ReceivePort isolateReceivePort = ReceivePort();

  // Send back the SendPort so the main isolate can communicate with this one
  sendPort.send(isolateReceivePort.sendPort);

  BotPlayer? botPlayer;

  isolateReceivePort.listen((message) async {
    if (message is BotIsolateMessage) {
      final moveParameters = MoveParameters.fromJson(message.moveParametersJson);
      if (botPlayer == null || botPlayer!.difficulty != moveParameters.difficulty) {
        botPlayer = BotPlayer(difficulty: moveParameters.difficulty);
      }

      final stopwatch = Stopwatch()..start();
      final move = chooseBotMove(botPlayer!, moveParameters);
      stopwatch.stop();
      print("Bot isolate computed move in ${stopwatch.elapsedMilliseconds} ms");
      message.responsePort.send(
        move,
      ); // Already serialized (Map<String, dynamic>?)
    }
  });
}

class BotIsolate {
  late Isolate _isolate;
  late SendPort _sendPort;
  final Completer<void> _ready = Completer();
  final BotDifficulty botDifficulty;

  BotIsolate(this.botDifficulty) {
    _initialize();
  }

  Future<void> _initialize() async {
    final receivePort = ReceivePort();

    _isolate = await Isolate.spawn(_botIsolateEntryPoint, receivePort.sendPort);

    // Wait for the isolate to send back its SendPort
    _sendPort = await receivePort.first as SendPort;

    _ready.complete();
  }

  Future<Move?> computeMove(MoveParameters parameters) async {
    await _ready.future;

    final responsePort = ReceivePort();

    _sendPort.send(
      BotIsolateMessage(parameters.toJson(), responsePort.sendPort),
    );

    final resultJson = await responsePort.first as Map<String, dynamic>?;
    return resultJson != null ? Move.fromJson(resultJson) : null;
  }

  void dispose() {
    _isolate.kill(priority: Isolate.immediate);
  }
}
