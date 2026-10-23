enum TutorialPhase {
  /// Pure text introduction or overview. User taps "Next" to continue.
  info,

  /// User must tap the specified cell. Spotlight is on that cell.
  /// Advances only when the correct cell is tapped.
  userMove,

  /// Spotlights the board that was activated by the previous move.
  /// Explains the sending rule. User taps "Next".
  moveConsequence,

  /// Fires the opponent's move automatically after a short delay,
  /// then spotlights the cell they played in. User taps "Next".
  autoMove,

  /// Spotlights the board the user must play in next. User taps "Next".
  activeBoard,

  /// Spotlights a just-won sub-board. Explains the winning-a-board rule.
  /// User taps "Next".
  subBoardWon,

  /// Spotlights the won/full board the player was sent to,
  /// explaining that they may now play anywhere (free move rule).
  freeMove,

  /// Plays a sequence of moves in quick succession to skip ahead
  /// to the next teaching scenario.
  fastForward,

  /// Tutorial complete. Shows winner indicator. User taps "Finish".
  finished,
}

enum SpotlightKind {
  /// Spotlight highlights the entire game board.
  none,

  /// Spotlight highlights an entire 3x3 sub-board.
  subBoard,

  /// Spotlight highlights a single cell within a sub-board.
  cell,
}

class TutorialStep {
  /// What this step does.
  final TutorialPhase phase;

  /// Explanation text shown in the tooltip card.
  final String explanation;

  /// Board index targeted by this step (0-8), or null for info/finished.
  final int? boardIndex;

  /// Cell index targeted by this step (0-8), or null if subBoard or info.
  final int? cellIndex;

  /// What kind of area the spotlight should highlight.
  final SpotlightKind spotlightKind;

  /// Optional list of (boardIndex, cellIndex) moves to play in fast-forward.
  final List<(int, int)>? fastForwardMoves;

  const TutorialStep({
    required this.phase,
    required this.explanation,
    this.boardIndex,
    this.cellIndex,
    required this.spotlightKind,
    this.fastForwardMoves,
  });
}
