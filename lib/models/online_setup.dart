class OnlineSetup {
  final int passCode;
  String hostPlayerId;
  late String guestPlayerId;
  bool isOpen;

  OnlineSetup({
    required this.passCode,
    required this.hostPlayerId,
    required this.isOpen,
  });
}
