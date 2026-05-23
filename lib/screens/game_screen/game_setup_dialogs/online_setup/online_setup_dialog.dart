import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../utils/lobby_controller.dart';

class OnlineSetupDialog extends StatefulWidget {
  final LobbyController lobbyController;

  const OnlineSetupDialog({super.key, required this.lobbyController});

  @override
  State<OnlineSetupDialog> createState() => _OnlineSetupDialogState();
}

class _OnlineSetupDialogState extends State<OnlineSetupDialog>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late TextEditingController textFieldController;
  bool joinButtonActive = false;
  bool waitingForGuest = false;
  bool readyToStart = false;
  bool waitingForHostToStart = false;
  String? passCode;
  StreamSubscription? lobbySubscription;

  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      setState(() {});
    });
    textFieldController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    textFieldController.dispose();
    lobbySubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final content = [
      TabBar(
        controller: tabController,
        tabs: [Tab(text: 'Host'), Tab(text: 'Join')],
      ),
      SizedBox(
        height: 150,
        width: 250,
        child: TabBarView(
          controller: tabController,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                readyToStart
                    ? SizedBox()
                    : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed:
                                waitingForGuest ? null : _startHostingGame,
                            child: const Text("Host game"),
                          ),
                          SizedBox(width: 8),
                          ElevatedButton(
                            onPressed:
                                waitingForGuest ? _stopHostingGame : null,
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ),
                waitingForGuest
                    ? Column(
                      children: [
                        Text(
                          "Join code: $passCode",
                          textAlign: TextAlign.center,
                          style: textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Waiting for other player...",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                      ],
                    )
                    : const SizedBox(),
                readyToStart
                    ? Column(
                      children: [
                        SizedBox(height: 32),
                        Text(
                          "Another player has joined!",
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).pop({'lobbyCode': passCode, 'isHost': true});
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    )
                    : const SizedBox(),
              ],
            ),
            waitingForHostToStart
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Waiting for host\nto start game.",
                      style: textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                  ],
                )
                : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: textFieldController,
                      onChanged: (text) {
                        _updateTextField();
                      },
                      decoration: InputDecoration(labelText: "Enter code"),
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: joinButtonActive ? _joinGame : null,
                      child: const Text("Join game"),
                    ),
                  ],
                ),
          ],
        ),
      ),
    ];

    return Stack(
      children: [
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              if (passCode != null) {
                if (tabController.index == 0) {
                  // Host tab
                  _stopHostingGame();
                } else if (waitingForHostToStart) {
                  // Join tab and actually joined
                  _leaveLobby();
                }
              }
              Navigator.of(context).pop(); // Pop the dialog
              Navigator.of(context).pop(); // Pop the screen
            }
          },
          child: Dialog(
            child:
                !isLandscape
                    ? Column(mainAxisSize: MainAxisSize.min, children: content)
                    : Row(mainAxisSize: MainAxisSize.min, children: content),
          ),
        ),
      ],
    );
  }

  Future<void> _startHostingGame() async {
    final lobbyCode = await widget.lobbyController.createLobby();
    setState(() {
      passCode = lobbyCode;
      waitingForGuest = true;
    });
    lobbySubscription = widget.lobbyController.getLobbyStream(lobbyCode).listen(
      (event) {
        if (!event.exists) return;
        final data = event.data() as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            if (data['state'] == 'ready') {
              waitingForGuest = false;
              readyToStart = true;
            } else if (data['state'] == 'waiting') {
              waitingForGuest = true;
              readyToStart = false;
            }
          });
        }
      },
    );
  }

  Future<void> _stopHostingGame() async {
    if (passCode != null) {
      await widget.lobbyController.deleteLobby(passCode!);
      passCode = null;
    }
    lobbySubscription?.cancel();
    if (mounted) {
      setState(() {
        waitingForGuest = false;
        readyToStart = false;
      });
    }
  }

  Future<void> _joinGame() async {
    final code = textFieldController.text.toUpperCase();
    final success = await widget.lobbyController.joinLobby(code);
    if (success) {
      setState(() {
        waitingForHostToStart = true;
        passCode = code;
      });

      lobbySubscription = widget.lobbyController.getLobbyStream(code).listen((
        event,
      ) {
        if (!event.exists) {
          if (mounted) {
            setState(() {
              waitingForHostToStart = false;
              passCode = null;
            });
            lobbySubscription?.cancel();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Host closed the lobby")),
            );
          }
          return;
        }
        final data = event.data() as Map<String, dynamic>;
        if (data['state'] == 'playing') {
          if (mounted) {
            Navigator.of(context).pop({
              'lobbyCode': code,
              'isHost': false,
              'gameSetup': data['gameSetup'],
            });
          }
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lobby does not exist!")));
      }
    }
  }

  Future<void> _leaveLobby() async {
    if (passCode != null) {
      await widget.lobbyController.leaveLobby(passCode!);
      passCode = null;
    }
    lobbySubscription?.cancel();
    if (mounted) {
      setState(() {
        waitingForHostToStart = false;
      });
    }
  }

  void _updateTextField() {
    setState(() {
      joinButtonActive = textFieldController.text.length == 4;
    });
  }
}
