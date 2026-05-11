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
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;
        final sidePanelWidth = (totalWidth - totalHeight) / 2;

        return Row(
          children: [
            SizedBox(
              width: sidePanelWidth,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    playerStatusIndicator,
                    const SizedBox(height: 16),
                    playAgainButton,
                    aiThinkingIndicator,
                  ],
                ),
              ),
            ),
            AspectRatio(aspectRatio: 1, child: boardWidget),
            SizedBox(
              width: sidePanelWidth,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BannerAdWidget(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}