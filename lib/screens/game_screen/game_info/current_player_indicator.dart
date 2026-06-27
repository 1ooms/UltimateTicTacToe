import 'package:flutter/material.dart';

import '../../../../models/enum/player.dart';
import '../../../../models/player_config.dart';
import '../../../../utils/ui_helpers.dart';

class CurrentPlayerIndicator extends StatefulWidget {
  const CurrentPlayerIndicator({
    super.key,
    required this.currentPlayer,
    required this.player1,
    required this.player2,
    required this.playingAgainstBot,
    required this.playingOnline,
    required this.isHost,
  });

  final Player currentPlayer;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool playingAgainstBot;
  final bool playingOnline;
  final bool? isHost;

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
        widget.playingAgainstBot
            ? widget.currentPlayer == Player.two
                ? const Text(' (Bot)')
                : const Text(' (You)')
            : const SizedBox(),
        widget.playingOnline
            ? widget.isHost ?? false
                ? widget.currentPlayer == Player.one
                    ? const Text(' (You)')
                    : const Text(' (Opponent)')
                : widget.currentPlayer == Player.one
                ? const Text(' (Opponent)')
                : const Text(' (You)')
            : const SizedBox(),
      ],
    );
  }
}
