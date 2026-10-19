import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/data/tutorial_steps.dart';
import 'package:ultimate_tic_tac_toe/models/tutorial_step.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/exit_tutorial_dialog.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/interactive_tutorial_landscape_layout.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/interactive_tutorial_portrait_layout.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/spotlight_overlay.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/tutorial_board_wrapper.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/tutorial_game_controller.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/interactive/tutorial_tooltip.dart';

class InteractiveTutorial extends StatefulWidget {
  const InteractiveTutorial({super.key});

  @override
  State<InteractiveTutorial> createState() => _InteractiveTutorialState();
}

class _InteractiveTutorialState extends State<InteractiveTutorial>
    with TickerProviderStateMixin {
  late final TutorialGameController _controller;
  late final AnimationController _pulseController;
  late final AnimationController _spotlightController;

  final GlobalKey _stackKey = GlobalKey();
  final GlobalKey _boardKey = GlobalKey();
  final List<GlobalKey> _subBoardKeys = List.generate(9, (_) => GlobalKey());
  final List<GlobalKey> _cellKeys = List.generate(81, (_) => GlobalKey());

  Rect? _previousRect;
  Rect? _targetRect;

  @override
  void initState() {
    super.initState();

    _controller = TutorialGameController(steps: tutorialSteps);
    _controller.addListener(_onControllerChanged);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _spotlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSpotlight();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateSpotlight();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _pulseController.dispose();
    _spotlightController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _updateSpotlight();
    setState(() {});
  }

  void _updateSpotlight() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final newRect = _calculateCurrentTargetRect();
      if (newRect != _targetRect) {
        setState(() {
          _previousRect = _currentInterpolatedRect ?? _targetRect;
          _targetRect = newRect;
        });
        _spotlightController.forward(from: 0.0);
      }
    });
  }

  Rect? _calculateCurrentTargetRect() {
    final step = _controller.currentStep;

    GlobalKey? key;
    if (step.spotlightKind == SpotlightKind.none) {
      key = _boardKey;
    } else if (step.spotlightKind == SpotlightKind.subBoard &&
        step.boardIndex != null) {
      key = _subBoardKeys[step.boardIndex!];
    } else if (step.spotlightKind == SpotlightKind.cell &&
        step.boardIndex != null &&
        step.cellIndex != null) {
      final index = step.boardIndex! * 9 + step.cellIndex!;
      key = _cellKeys[index];
    }

    if (key == null) return null;

    final targetContext = key.currentContext;
    final stackContext = _stackKey.currentContext;
    if (targetContext == null || stackContext == null) return null;

    final targetBox = targetContext.findRenderObject() as RenderBox?;
    final stackBox = stackContext.findRenderObject() as RenderBox?;
    if (targetBox == null ||
        stackBox == null ||
        !targetBox.hasSize ||
        !stackBox.hasSize) {
      return null;
    }

    final localOffset = stackBox.globalToLocal(
      targetBox.localToGlobal(Offset.zero),
    );
    return localOffset & targetBox.size;
  }

  Rect? get _currentInterpolatedRect {
    if (_previousRect == null && _targetRect == null) return null;
    if (_previousRect == null) return _targetRect;
    if (_targetRect == null) return _previousRect;

    final t =
        CurvedAnimation(
          parent: _spotlightController,
          curve: Curves.easeInOut,
        ).value;
    return Rect.lerp(_previousRect, _targetRect, t);
  }

  void _showFeedbackSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(milliseconds: 1400),
          content: Text(message),
        ),
      );
  }

  void _onCellTap(int boardIndex, int cellIndex) {
    if (_controller.isInteractionLocked) return;

    final step = _controller.currentStep;
    if (step.phase == TutorialPhase.userMove) {
      final handled = _controller.handleUserTap(boardIndex, cellIndex);
      if (!handled) {
        _showFeedbackSnackBar('Tap the highlighted square.');
      }
    } else if (step.phase == TutorialPhase.finished) {
      _showFeedbackSnackBar("Tap 'Finish' to exit.");
    } else {
      _showFeedbackSnackBar("Tap 'Next' to continue.");
    }
  }

  void _onScrimTap(TapDownDetails details) {
    if (_controller.isInteractionLocked) return;

    final tapPos = details.localPosition;
    final step = _controller.currentStep;

    if (step.phase == TutorialPhase.userMove) {
      if (_targetRect != null && _targetRect!.inflate(8.0).contains(tapPos)) {
        // Tapped inside the spotlighted cell
        _controller.handleUserTap(step.boardIndex!, step.cellIndex!);
      } else {
        _showFeedbackSnackBar('Tap the highlighted square.');
      }
    } else if (step.phase == TutorialPhase.finished) {
      _showFeedbackSnackBar("Tap 'Finish' to exit.");
    } else {
      _showFeedbackSnackBar("Tap 'Next' to continue.");
    }
  }

  Future<void> _handleExit() async {
    if (_controller.isFinished) {
      Navigator.of(context).pop();
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ExitTutorialDialog(),
    );

    if (shouldExit == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final boardWidget = TutorialBoardWrapper(
      key: _boardKey,
      gameController: _controller.game,
      player1: _controller.player1,
      player2: _controller.player2,
      subBoardKeys: _subBoardKeys,
      cellKeys: _cellKeys,
      onCellTap: _onCellTap,
    );

    final scrimWidget = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _onScrimTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spotlightController, _pulseController]),
        builder: (context, _) {
          return SpotlightOverlay(
            targetRect: _currentInterpolatedRect,
            pulseValue: _pulseController.value,
          );
        },
      ),
    );

    final tooltipWidget = TutorialTooltip(
      step: _controller.currentStep,
      stepIndex: _controller.currentStepIndex,
      totalSteps: _controller.totalSteps,
      isInteractionLocked: _controller.isInteractionLocked,
      onNext: _controller.advance,
      onFinish: () => Navigator.of(context).pop(),
    );

    final skipButton =
        !_controller.isFinished
            ? TextButton(
              onPressed: _handleExit,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Skip tutorial'),
            )
            : null;

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await _handleExit();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('How to play'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleExit,
          ),
        ),
        body: SizedBox.expand(
          key: _stackKey,
          child:
              isLandscape
                  ? InteractiveTutorialLandscapeLayout(
                    boardWidget: boardWidget,
                    scrimWidget: scrimWidget,
                    tooltipWidget: tooltipWidget,
                    skipButton: skipButton,
                  )
                  : InteractiveTutorialPortraitLayout(
                    boardWidget: boardWidget,
                    scrimWidget: scrimWidget,
                    tooltipWidget: tooltipWidget,
                    skipButton: skipButton,
                  ),
        ),
      ),
    );
  }
}
