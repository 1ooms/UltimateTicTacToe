import 'dart:isolate';

class BotIsolateMessage {
  final Map<String, dynamic> moveParametersJson;
  final SendPort responsePort;

  BotIsolateMessage(this.moveParametersJson, this.responsePort);
}
