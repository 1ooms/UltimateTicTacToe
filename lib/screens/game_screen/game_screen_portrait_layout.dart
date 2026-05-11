import 'package:flutter/material.dart';

class GameScreenPortraitLayout extends StatelessWidget {
  final Widget boardWidget;
  final Widget playerStatusIndicator;
  final Widget playAgainButton;
  final Widget aiThinkingIndicator;

  const GameScreenPortraitLayout({super.key,
    required this.boardWidget,
    required this.playerStatusIndicator,
    required this.playAgainButton,
    required this.aiThinkingIndicator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                playerStatusIndicator,
                const SizedBox(height: 16),
                AspectRatio(aspectRatio: 1, child: boardWidget),
                const SizedBox(height: 16),
                playAgainButton,
                aiThinkingIndicator,
              ],
            ),
          ),
        ),
      ],
    );
  }
}