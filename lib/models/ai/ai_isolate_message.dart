import 'dart:isolate';

class AIIsolateMessage {
  final Map<String, dynamic> moveParametersJson;
  final SendPort responsePort;

  AIIsolateMessage(this.moveParametersJson, this.responsePort);
}
