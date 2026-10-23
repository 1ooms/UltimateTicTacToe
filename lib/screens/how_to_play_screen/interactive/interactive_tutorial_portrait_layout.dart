import 'package:flutter/material.dart';

class InteractiveTutorialPortraitLayout extends StatelessWidget {
  final Widget boardWidget;
  final Widget scrimWidget;
  final Widget tooltipWidget;
  final Widget? skipButton;

  const InteractiveTutorialPortraitLayout({
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
        // Layer 1: Content with fixed-position board at top
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                boardWidget,
              ],
            ),
          ),
        ),

        // Layer 2: Full-page dark scrim with clear cutout over target area
        Positioned.fill(child: scrimWidget),

        // Layer 3: Tooltip and Skip Button rendered above scrim
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Column(
              children: [
                // Invisible placeholders matching Layer 1 exactly so lower controls align
                const Visibility(
                  visible: false,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  child: AspectRatio(aspectRatio: 1, child: SizedBox()),
                ),
                const SizedBox(height: 12),

                // Active tooltip and action controls
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
        ),
      ],
    );
  }
}
