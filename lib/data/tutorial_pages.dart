import 'package:ultimate_tic_tac_toe/models/tutorial_page_data.dart';

import '../models/enum/player.dart';
import '../models/move.dart';

final List<TutorialPageData> pages = [
  TutorialPageData(
    explanation:
        "Ultimate Tic Tac Toe is a more challenging and strategic version of the classic game. You play on a big 3x3 tic-tac-toe board that consists of 9 smaller tic-tac-toe boards. To win the game, you need to win three small boards in a row (vertically, horizontally, or diagonally).",
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
  TutorialPageData(
    explanation:
    "The squares a player is allowed to play depend on their opponent's last move.\n\nIn this example, the circle player has played the bottom right square within the top left board. The cross player must therefore play their next move on the bottom right board.",
    moves: [Move(4, 0, Player.one, null), Move(0, 8, Player.two, null)],
  ),
  TutorialPageData(
    explanation:
    "The current player's possible moves are indicated with that player's color.\n\nThe opponent's previous move is indicated with a thick border.",
    moves: [Move(4, 0, Player.one, null), Move(0, 8, Player.two, null)],
  ),
  TutorialPageData(
    explanation:
        "Win a small board by claiming three squares in a row on that board. Winning a small board earns you that square on the large board.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
      Move(0, 7, Player.two, null),
    ],
  ),
  TutorialPageData(
    explanation:
        "If a player is sent to a smaller board that has already been won, they can play on any available square.\n\nIn this case, the circle player has sent the cross player to the top left board. This board has already been won, so the cross player can play their next move anywhere.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
      Move(0, 7, Player.two, null),
      Move(7, 5, Player.one, null),
      Move(5, 0, Player.two, null),
    ],
  ),
  TutorialPageData(
    explanation:
        "The first player to win three squares in a row (vertically, horizontally or diagonally) on the large board wins the game.",
    moves: [
      Move(4, 0, Player.one, null),
      Move(0, 8, Player.two, null),
      Move(8, 0, Player.one, null),
      Move(0, 6, Player.two, null),
      Move(6, 0, Player.one, null),
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
