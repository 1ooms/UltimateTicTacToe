import 'package:flutter/material.dart';

class ComputerGameScreen extends StatelessWidget {
  const ComputerGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Computer Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Computer Tic Tac Toe',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            // const TicTacToeBoard(),
          ],
        ),
      ),
    );
  }
}