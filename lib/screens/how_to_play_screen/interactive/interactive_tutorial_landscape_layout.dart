import 'package:flutter/material.dart';

class InteractiveTutorialLandscapeLayout extends StatelessWidget {
  final Widget boardWidget;
  final Widget scrimWidget;
  final Widget tooltipWidget;
  final Widget? skipButton;

  const InteractiveTutorialLandscapeLayout({
    super.key,
    required this.boardWidget,
    required this.scrimWidget,
    required this.tooltipWidget,
    this.skipButton,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Layer 1: Background content (Board on left, status indicator on right)
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                AspectRatio(aspectRatio: 1, child: boardWidget),
              ],
            ),
          ),
        ),

        // Layer 2: Full-screen dark scrim with clear cutout over target area
        Positioned.fill(child: scrimWidget),

        // Layer 3: Interactive controls un-dimmed above the scrim
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Invisible placeholder matching Layer 1 board width exactly
                const AspectRatio(aspectRatio: 1, child: SizedBox()),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      // Active tooltip card centered and scrollable if needed
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(child: tooltipWidget),
                        ),
                      ),
                      if (skipButton != null)
                        skipButton!
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
