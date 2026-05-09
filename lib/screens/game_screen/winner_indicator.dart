import 'package:flutter/material.dart';

import '../../models/enum/player.dart';
import '../../models/player_config.dart';
import '../../utils/ui_helpers.dart';

class WinnerIndicator extends StatefulWidget {
  const WinnerIndicator({
    super.key,
    required this.overallWinner,
    required this.player1,
    required this.player2,
    required this.playingAgainstAI,
  });

  final Player? overallWinner;
  final PlayerConfig player1;
  final PlayerConfig player2;
  final bool playingAgainstAI;

  @override
  State<WinnerIndicator> createState() => _WinnerIndicatorState();
}

class _WinnerIndicatorState extends State<WinnerIndicator> {
  @override
  Widget build(BuildContext context) {
    Widget buildWinnerText() {
      return Row(
        children: [
          Text('Winner: ', style: Theme.of(context).textTheme.titleMedium),
          widget.overallWinner == Player.one
              ? buildIcon(widget.player1.shape, widget.player1.color, 28)
              : buildIcon(widget.player2.shape, widget.player2.color, 28),
          widget.playingAgainstAI
              ? widget.overallWinner == Player.two
                  ? const Text(' (AI)')
                  : const Text(' (You)')
              : const SizedBox(),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.overallWinner == null
            ? const Text("It's a draw.")
            : buildWinnerText(),
      ],
    );
  }
}
