import 'package:flutter/material.dart';

import '../../widgets/ads/banner_ad_widget.dart';

class GameScreenLandscapeLayout extends StatelessWidget {
  final Widget boardWidget;
  final Widget playerStatusIndicator;
  final Widget playAgainButton;
  final Widget aiThinkingIndicator;

  const GameScreenLandscapeLayout({super.key,
    required this.boardWidget,
    required this.playerStatusIndicator,
    required this.playAgainButton,
    required this.aiThinkingIndicator,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AspectRatio(aspectRatio: 1, child: boardWidget),
          const SizedBox(width: 32),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  playerStatusIndicator,
                  const SizedBox(height: 16),
                  playAgainButton,
                  aiThinkingIndicator,
                ],
              ),
              BannerAdWidget(),
            ],
          )
        ],
      ),
    );
  }
}