import '../models/tutorial_step.dart';

final List<TutorialStep> tutorialSteps = [
  const TutorialStep(
    phase: TutorialPhase.info,
    explanation:
        'Ultimate Tic Tac Toe is a bigger and more challenging version of the classic tic-tac-toe game.\n\n'
        'The game is played on a 3×3 grid that is made up by 9 tic-tac-toe boards.',
    spotlightKind: SpotlightKind.none,
  ),

  const TutorialStep(
    phase: TutorialPhase.info,
    explanation:
        'You play as X (red), and your opponent plays as O (blue).\n\n'
        'To win the game, you need to win three tic-tac-toe boards in a row '
        '(horizontally, vertically, or diagonally).',
    spotlightKind: SpotlightKind.none,
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'On the very first turn, you can play anywhere. '
        'Tap on the highlighted square to place your mark there.',
    boardIndex: 4,
    cellIndex: 0,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.moveConsequence,
    explanation:
        'The square you pick determines which board your opponent must play in next.\n\n'
        'Notice where you placed your mark: the top-left square (within the center board). '
        'This sends your opponent to the top-left board.',
    boardIndex: 0,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.autoMove,
    explanation:
        'Your opponent played in the center square of the top-left board.',
    boardIndex: 0,
    cellIndex: 4,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.activeBoard,
    explanation:
        'Because your opponent picked the center square, you are sent to the center board.',
    boardIndex: 4,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'Now it’s your turn. Tap highlighted square.',
    boardIndex: 4,
    cellIndex: 4,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.moveConsequence,
    explanation:
        'You chose the center square again, so your opponent is forced to play in the center board too.',
    boardIndex: 4,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.autoMove,
    explanation:
        'Your opponent played in the top-right square of the center board.',
    boardIndex: 4,
    cellIndex: 2,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.activeBoard,
    explanation: 'Your opponent\'s move sends you to the top-right board.',
    boardIndex: 2,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation: 'Tap the highlighted square to claim it.',
    boardIndex: 2,
    cellIndex: 0,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.moveConsequence,
    explanation:
        'Since you picked the top-left square, your opponent must play in the top-left board.',
    boardIndex: 0,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.fastForward,
    explanation:
        'You’ve got the hang of it!\n\n'
        'Now let’s fast-forward a few moves to see how to win a small board...',
    spotlightKind: SpotlightKind.none,
    fastForwardMoves: [
      (0, 6),
      (6, 0),
      (0, 3),
      (3, 4),
      (4, 6),
      (6, 4),
      (4, 1),
      (1, 8),
      (8, 4),
    ],
  ),

  const TutorialStep(
    phase: TutorialPhase.activeBoard,
    explanation:
        'You already hold a couple squares in the center board. ',
    boardIndex: 4,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'Tap bottom-right to complete three in a row!',
    boardIndex: 4,
    cellIndex: 8,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.subBoardWon,
    explanation:
        'Three in a row! You won the center board!\n\n'
        'Winning a small board claims that entire square on the big board.',
    boardIndex: 4,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.fastForward,
    explanation:
        'Let’s fast-forward to see what happens when a player is sent to a board that is already won...',
    spotlightKind: SpotlightKind.none,
    fastForwardMoves: [(8, 0), (0, 8), (8, 7)],
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'Tap the center square. '
        'Watch what happens when you send your opponent to the center board.',
    boardIndex: 7,
    cellIndex: 4,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.freeMove,
    explanation:
        'The center board has already been claimed!\n\n'
        'When a move sends a player to a board that is already won (or full), '
        'they get a free move, and can play on any available square on the entire board.',
    boardIndex: 4,
    spotlightKind: SpotlightKind.none,
  ),

  const TutorialStep(
    phase: TutorialPhase.autoMove,
    explanation:
        'Using their free move, your opponent chose to play on the center square of the center-right board.',
    boardIndex: 5,
    cellIndex: 4,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.freeMove,
    explanation:
        'Your opponent sent you to the center board, which you\'ve already won.\n\n'
        'Now you get a free move. You can play on any open square on the board.',
    boardIndex: 4,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'Let’s use your free move to win another board. '
        'Tap the highlighted square to complete three in a row in the bottom-left board.',
    boardIndex: 6,
    cellIndex: 8,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.subBoardWon,
    explanation:
        'You won the bottom-left board!',
    boardIndex: 6,
    spotlightKind: SpotlightKind.subBoard,
  ),

  const TutorialStep(
    phase: TutorialPhase.fastForward,
    explanation: 'Let\'s fast-forward...',
    spotlightKind: SpotlightKind.none,
    fastForwardMoves: [(8, 2), (2, 4), (3, 8), (8, 5), (5, 6)],
  ),

  const TutorialStep(
    phase: TutorialPhase.userMove,
    explanation:
        'You hold the center and bottom-left boards. Win the top-right board to complete three in a row and win the game!\n\n'
        'Tap the highlighted cell.',
    boardIndex: 2,
    cellIndex: 8,
    spotlightKind: SpotlightKind.cell,
  ),

  const TutorialStep(
    phase: TutorialPhase.finished,
    explanation:
        'You won three boards in a diagonal line to win the match!\n\n'
        'You’ve learned all the rules. You’re ready to play!',
    spotlightKind: SpotlightKind.none,
  ),
];
