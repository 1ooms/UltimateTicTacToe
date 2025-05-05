import 'package:flutter/material.dart';

import '../../models/player.dart';
import '../../models/player_config.dart';
import '../dialogs/player_customizer.dart';

class CurrentPlayerIndicator extends StatefulWidget {
  const CurrentPlayerIndicator({super.key, required this.currentPlayer, required this.player1, required this.player2});

  final Player currentPlayer;
  final PlayerConfig player1;
  final PlayerConfig player2;

  @override
  State<CurrentPlayerIndicator> createState() => _CurrentPlayerIndicatorState();
}

class _CurrentPlayerIndicatorState extends State<CurrentPlayerIndicator> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Current Player: ',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        widget.currentPlayer == Player.one
            ? buildIcon(widget.player1.shape, widget.player1.color, 28)
            : buildIcon(widget.player2.shape, widget.player2.color, 28),
      ],
    );
  }
}