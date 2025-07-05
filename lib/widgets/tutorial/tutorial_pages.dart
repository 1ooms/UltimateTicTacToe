import 'package:ultimate_tic_tac_toe/widgets/tutorial/tutorial_page_data.dart';

import '../../models/enum/player.dart';
import '../../models/move.dart';

final List<TutorialPageData> pages = [
  TutorialPageData(
    explanation:
    "Players take turns placing their marks on the smaller boards. The first player can choose any square to make their initial move.",
    moves: [],
  ),
  TutorialPageData(
    explanation:
    "The square that a player chooses determines which smaller board the other player must play on next.",
    moves: [Move(4, 0, Player.one, null)],
  ),
  TutorialPageData(
    explanation:
    "Choosing the bottom left square within a small board sends the other player to that square within the big board.",
    moves: [Move(4, 0, Player.one, null), Move(0, 6, Player.two, null)],
  ),
  TutorialPageData(
    explanation:
    "Win a small board by claiming three squares in a row. Winning a small board earns you that square on the larger board.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 7, Player.two, null),
    ],
  ),
  TutorialPageData(
    explanation:
    "If a player is sent to a smaller board that has already been won, they can play on any available square.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 7, Player.two, null),
      Move(7, 5, Player.one, null),
      Move(5, 0, Player.two, null),
    ],
  ),
  TutorialPageData(
    explanation:
    "The first player to win three of the smaller boards in a row on the larger grid wins the game.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 7, Player.two, null),
      Move(7, 5, Player.one, null),
      Move(5, 0, Player.two, null),
      Move(4, 2, Player.one, null),
      Move(2, 1, Player.one, null),
      Move(1, 4, Player.two, null),
      Move(4, 1, Player.one, null),
      Move(1, 6, Player.two, null),
      Move(6, 2, Player.one, null),
      Move(2, 6, Player.two, null),
      Move(6, 1, Player.one, null),
      Move(1, 2, Player.two, null),
      Move(2, 2, Player.one, null),
      Move(2, 8, Player.two, null),
      Move(8, 2, Player.one, null),
      Move(2, 7, Player.two, null),
    ],
  ),
];