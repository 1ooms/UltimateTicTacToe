import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/tutorial_step.dart';

class TutorialTooltip extends StatelessWidget {
  final TutorialStep step;
  final int stepIndex;
  final int totalSteps;
  final bool isInteractionLocked;
  final VoidCallback onNext;
  final VoidCallback onFinish;

  const TutorialTooltip({
    super.key,
    required this.step,
    required this.stepIndex,
    required this.totalSteps,
    required this.isInteractionLocked,
    required this.onNext,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.08),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                step.explanation,
                key: ValueKey(stepIndex),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [_buildActionButton(context)],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    // if (isInteractionLocked) {
    //   final label =
    //       step.phase == TutorialPhase.fastForward
    //           ? 'Fast-forwarding...'
    //           : 'Opponent moving...';
    //
    //   return Row(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //       SizedBox(
    //         width: 16,
    //         height: 16,
    //         child: CircularProgressIndicator(
    //           strokeWidth: 2,
    //           color: theme.colorScheme.primary,
    //         ),
    //       ),
    //       const SizedBox(width: 8),
    //       Text(
    //         label,
    //         style: theme.textTheme.labelSmall?.copyWith(
    //           color: theme.colorScheme.onSurfaceVariant,
    //         ),
    //       ),
    //     ],
    //   );
    // }

    if (step.phase == TutorialPhase.finished) {
      return FilledButton.icon(
        onPressed: onFinish,
        icon: const Icon(Icons.check, size: 18),
        label: const Text('Finish'),
      );
    }

    if (step.phase != TutorialPhase.userMove || isInteractionLocked) {
      return FilledButton(onPressed: onNext, child: const Text('Next'));
    }

    return const SizedBox();
  }
}
