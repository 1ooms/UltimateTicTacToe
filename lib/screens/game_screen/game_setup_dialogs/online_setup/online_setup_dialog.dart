import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/lobby_state.dart';
import 'package:ultimate_tic_tac_toe/controllers/online_game_controller.dart';

import '../../../../models/lobby_data.dart';
import '../../../../models/online_setup.dart';

class OnlineSetupDialog extends StatefulWidget {
  final OnlineGameController onlineGameController;

  const OnlineSetupDialog({super.key, required this.onlineGameController});

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
                hostLoading ? CircularProgressIndicator() : SizedBox(),
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
                            Navigator.of(context).pop(
                              OnlineSetup(
                                lobbyCode: passCode!,
                                isHost: true,
                                gameSetup: null,
                              ),
                            );
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
                    SizedBox(height: 16),
                    joinLoading
                        ? CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: joinButtonActive ? _joinGame : null,
                          child: const Text("Join game"),
                        ),
                  ],
                ),
          ],
        ),
      ),
    ];

    void popDialog() {
      if (passCode != null) {
        if (tabController.index == 0) {
          _stopHostingGame();
        } else if (waitingForHostToStart) {
          _leaveLobby();
        }
      }
      Navigator.of(context).pop(); // Pop the dialog
      Navigator.of(context).pop(); // Pop the screen
    }

    return Stack(
      children: [
        PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              popDialog();
            }
          },
          child: AlertDialog(
            scrollable: true,
            content:
              Column(mainAxisSize: MainAxisSize.min, children: content),
            actions: [
              TextButton(
                onPressed: () {
                  popDialog();
                },
                child: const Text('Go back'),
              ),
            ]
          ),
        ),
      ],
    );
  }

  bool hostLoading = false;
  bool joinLoading = false;

  Future<void> _startHostingGame() async {
    setState(() {
      hostLoading = true;
    });

    final lobbyCode = await widget.onlineGameController.hostGame();
    setState(() {
      passCode = lobbyCode;
      waitingForGuest = true;
    });
    lobbySubscription = widget.onlineGameController.getLobbyStream()?.listen((
      event,
    ) {
      if (!event.exists) return;
      final data = LobbyData.fromJson(event.data() as Map<String, dynamic>);
      if (mounted) {
        setState(() {
          if (data.state == LobbyState.ready.toString()) {
            waitingForGuest = false;
            readyToStart = true;
          } else if (data.state == LobbyState.waiting.toString()) {
            waitingForGuest = true;
            readyToStart = false;
          }
        });
      }
    });

    setState(() {
      hostLoading = false;
    });
  }

  Future<void> _stopHostingGame() async {
    if (passCode != null) {
      await widget.onlineGameController.stopHosting();
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
    setState(() {
      joinLoading = true;
    });

    final code = textFieldController.text.toUpperCase();
    final success = await widget.onlineGameController.joinGame(code);
    if (success) {
      setState(() {
        waitingForHostToStart = true;
        passCode = code;
      });

      lobbySubscription = widget.onlineGameController.getLobbyStream()?.listen((
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
        final data = LobbyData.fromJson(event.data() as Map<String, dynamic>);
        if (data.state == LobbyState.playing.toString()) {
          if (mounted) {
            Navigator.of(context).pop(
              OnlineSetup(
                lobbyCode: code,
                isHost: false,
                gameSetup: data.gameSetup,
              ),
            );
          }
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lobby does not exist or is already playing!"),
          ),
        );
      }
    }

    setState(() {
      joinLoading = false;
    });
  }

  Future<void> _leaveLobby() async {
    if (passCode != null) {
      await widget.onlineGameController.leaveGame();
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
