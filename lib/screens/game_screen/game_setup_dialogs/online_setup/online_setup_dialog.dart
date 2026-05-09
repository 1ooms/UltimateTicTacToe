import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../utils/lobby_controller.dart';

class OnlineSetupDialog extends StatefulWidget {
  const OnlineSetupDialog({super.key});

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
  late String? passCode;
  LobbyController lobbyController = LobbyController(
    instance: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );

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
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: waitingForGuest ? null : _startHostingGame,
                        child: const Text("Host game"),
                      ),
                      SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: waitingForGuest ? _stopHostingGame : null,
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
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Waiting for other player...",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    )
                    : const SizedBox(),
                readyToStart
                    ? Column(
                      children: [
                        Text(
                          "Another player has joined!",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    )
                    : const SizedBox(),
              ],
            ),
            Column(
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
    final lobbyCode = await lobbyController.createLobby();
    setState(() {
      passCode = lobbyCode;
      waitingForGuest = true;
    });
    final lobbyStream = lobbyController.getLobbyStream(lobbyCode);

    lobbyStream.listen((event) {
      if (!event.exists) return;
      final data = event.data() as Map<String, dynamic>;
      if (data['state'] == 'ready') {
        setState(() {
          waitingForGuest = false;
          readyToStart = true;
        });
      }
    });
  }

  Future<void> _stopHostingGame() async {
    if (passCode != null) {
      await lobbyController.deleteLobby(passCode!);
      passCode = null;
    }
    setState(() {
      waitingForGuest = false;
    });
  }

  Future<void> _joinGame() async {
    final success = await lobbyController.joinLobby(textFieldController.text);
    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  void _updateTextField() {
    setState(() {
      joinButtonActive = textFieldController.text.length == 4;
    });
  }
}
