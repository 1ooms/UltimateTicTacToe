import 'package:flutter/material.dart';

class LeaveGameDialog extends StatefulWidget {
  const LeaveGameDialog({super.key});

  @override
  State<LeaveGameDialog> createState() => _LeaveGameDialogState();
}

class _LeaveGameDialogState extends State<LeaveGameDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Text("Leave the game? Progress will not be saved."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Pop the dialog
            Navigator.of(context).pop(); // Pop the screen
          },
          child: const Text('Yes'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('No'),
        ),
      ],
    );
  }
}
