import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/tutorial/tutorial_wizard.dart';

class HowToPlayScreen extends StatelessWidget {
  const HowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('How to play')),
      body: TutorialWizard(),
    );
  }
}
