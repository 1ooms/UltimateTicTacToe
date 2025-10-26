import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../multiplayer/firestore_controller.dart';

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
  late String? passCode;
  FirestoreController firestoreController = FirestoreController(
    instance: FirebaseFirestore.instance,
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
                        onPressed: _startHostingGame,
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

  void _startHostingGame() {
    passCode = _generatePassCode();
    // firestoreController.createLobby(passCode);
    setState(() {
      waitingForGuest = true;
    });
  }

  void _stopHostingGame() {
    passCode = null;
    setState(() {
      waitingForGuest = false;
    });
  }

  void _joinGame() {
    _stopHostingGame();
    // firestoreController.joinLobby(textFieldController.text);
  }

  void _updateTextField() {
    setState(() {
      joinButtonActive = textFieldController.text.length == 4;
    });
  }

  String _generatePassCode() {
    var random = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';

    return String.fromCharCodes(
      Iterable.generate(
        4,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
