import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/how_to_play_screen.dart';

import '../../data/pref_keys.dart';

class WelcomeDialog extends StatelessWidget {
  WelcomeDialog({super.key}) {
    _savePrefs();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(PrefKeys.firstLogin, false);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Welcome to Ultimate Tic Tac Toe!"),
      content: Text(
        "It looks like this is your first time playing. Let's go through the rules of the game.",
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HowToPlayScreen()),
            );
          },
          child: const Text("Continue"),
        ),
      ],
    );
  }
}
