import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultimate_tic_tac_toe/controllers/audio_controller.dart';
import 'package:ultimate_tic_tac_toe/data/tutorial_steps.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/models/tutorial_step.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/interactive_tutorial.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/interactive_tutorial_landscape_layout.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/interactive_tutorial_portrait_layout.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/tutorial_game_controller.dart';

void main() {
  setUp(() {
    AudioController().soundSetting = false;
  });

  group('TutorialGameController & tutorialSteps', () {
    test('Steps list starts with intro and ends with finished', () {
      expect(tutorialSteps.first.phase, equals(TutorialPhase.info));
      expect(tutorialSteps.last.phase, equals(TutorialPhase.finished));
    });

    test('Plays through entire tutorial sequence with fast-forwarding', () async {
      final controller = TutorialGameController(steps: tutorialSteps);

      while (!controller.isFinished) {
        final step = controller.currentStep;

        if (step.phase == TutorialPhase.userMove) {
          // Verify that tapping a wrong square returns false and does not advance
          final wrongTapHandled = controller.handleUserTap(
            (step.boardIndex! + 1) % 9,
            step.cellIndex!,
          );
          expect(wrongTapHandled, isFalse);

          // Tap the correct square
          final handled = controller.handleUserTap(
            step.boardIndex!,
            step.cellIndex!,
          );
          expect(handled, isTrue);
        } else if (step.phase == TutorialPhase.autoMove ||
            step.phase == TutorialPhase.fastForward) {
          // Wait for auto move or fast forward to complete
          while (controller.isInteractionLocked) {
            await Future.delayed(const Duration(milliseconds: 30));
          }
          controller.advance();
        } else {
          // Non-move steps: advance
          controller.advance();
        }
      }

      expect(controller.isFinished, isTrue);
      expect(controller.game.overallWinner, equals(Player.one));
      expect(controller.game.gameFinished, isTrue);

      controller.dispose();
    });
  });

  group('InteractiveTutorial Widget & Responsive Layouts', () {
    testWidgets('InteractiveTutorial renders in portrait orientation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MaterialApp(home: InteractiveTutorial()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(InteractiveTutorialPortraitLayout), findsOneWidget);
      expect(find.byType(InteractiveTutorialLandscapeLayout), findsNothing);
      expect(find.text('How to play'), findsOneWidget);
    });

    testWidgets('InteractiveTutorial renders in landscape orientation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MaterialApp(home: InteractiveTutorial()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(InteractiveTutorialLandscapeLayout), findsOneWidget);
      expect(find.byType(InteractiveTutorialPortraitLayout), findsNothing);
      expect(find.text('How to play'), findsOneWidget);
    });

    testWidgets('InteractiveTutorial updates layout smoothly on rotation', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(const MaterialApp(home: InteractiveTutorial()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(InteractiveTutorialPortraitLayout), findsOneWidget);
      expect(find.byType(InteractiveTutorialLandscapeLayout), findsNothing);

      // Rotate to landscape
      tester.view.physicalSize = const Size(800, 400);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.byType(InteractiveTutorialLandscapeLayout), findsOneWidget);
      expect(find.byType(InteractiveTutorialPortraitLayout), findsNothing);
    });
  });
}
