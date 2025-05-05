import 'package:flutter/material.dart';

class OnlineGameScreen extends StatelessWidget {
  const OnlineGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Online Game')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'Online Tic Tac Toe',
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