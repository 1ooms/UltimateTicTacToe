import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/data/tutorial_pages.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/tutorial/static_board.dart';
import 'package:ultimate_tic_tac_toe/screens/how_to_play_screen/tutorial/static_board_state.dart';

import '../../../main.dart';
import '../../../models/enum/player_shape.dart';
import '../../../models/player_config.dart';
import '../../game_screen/current_player_indicator.dart';
import '../../game_screen/winner_indicator.dart';

class TutorialWizard extends StatefulWidget {
  const TutorialWizard({super.key});

  @override
  State<TutorialWizard> createState() => _TutorialWizardState();
}

class _TutorialWizardState extends State<TutorialWizard> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final PlayerConfig player1 = PlayerConfig(
    color: Colors.red,
    shape: PlayerShape.cross,
  );
  final PlayerConfig player2 = PlayerConfig(
    color: Colors.blue,
    shape: PlayerShape.circle,
  );

  @override
  void initState() {
    super.initState();
  }

  void _goTo(int index) {
    if (index >= 0 && index < pages.length) {
      _controller.animateToPage(
        index,
        duration: const Duration(milliseconds: 500),
        curve: Curves.linear,
      );
    }
  }

  void onNextPage() {
    if (_currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            scrollBehavior: AppScrollBehavior(),
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (ctx, index) {
              final page = pages[index];
              final boardState = buildStaticBoardState(page.moves);
              final gameFinished = _currentPage == pages.length - 1;

              Widget playerStatusIndicator =
                  gameFinished
                      ? WinnerIndicator(
                        overallWinner: Player.two,
                        player1: player1,
                        player2: player2,
                        playingAgainstBot: false,
                      )
                      : CurrentPlayerIndicator(
                        currentPlayer: boardState.currentPlayer,
                        player1: player1,
                        player2: player2,
                        playingAgainstBot: false,
                      );

              return Padding(
                padding: const EdgeInsets.all(16),
                child:
                    !isLandscape
                        ? Column(
                          children: [
                            playerStatusIndicator,
                            const SizedBox(height: 16),
                            Expanded(
                              child: StaticBoard(
                                moveHistory: page.moves,
                                player1: player1,
                                player2: player2,
                                gameFinished:
                                    (_currentPage == pages.length - 1),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              page.explanation,
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                        : LayoutBuilder(
                          builder: (context, constraints) {
                            final totalWidth = constraints.maxWidth;
                            final totalHeight = constraints.maxHeight;

                            final boardSize = totalHeight;
                            final leftPanelWidth = totalWidth * 0.5;
                            final rightPanelWidth =
                                totalWidth - boardSize - leftPanelWidth;

                            return Row(
                              children: [
                                SizedBox(
                                  width: leftPanelWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32.0,
                                    ),
                                    child: Center(
                                      child: Text(
                                        page.explanation,
                                        style:
                                            Theme.of(
                                              context,
                                            ).textTheme.bodyLarge,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: boardSize,
                                  height: boardSize,
                                  child: StaticBoard(
                                    moveHistory: page.moves,
                                    player1: player1,
                                    player2: player2,
                                    gameFinished:
                                        (_currentPage == pages.length - 1),
                                  ),
                                ),
                                SizedBox(
                                  width: rightPanelWidth,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [playerStatusIndicator],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
              );
            },
          ),
        ),
        _buildNavigationBar(),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0 ? () => _goTo(_currentPage - 1) : null,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(pages.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 12 : 8,
                height: isActive ? 12 : 8,
                decoration: BoxDecoration(
                  color:
                      isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(100),
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                _currentPage < pages.length - 1
                    ? () => _goTo(_currentPage + 1)
                    : null,
          ),
        ],
      ),
    );
  }
}
