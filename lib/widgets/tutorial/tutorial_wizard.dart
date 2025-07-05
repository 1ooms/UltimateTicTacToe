import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/widgets/tutorial/static_board.dart';
import 'package:ultimate_tic_tac_toe/widgets/tutorial/tutorial_pages.dart';

import '../../main.dart';
import '../../models/player_config.dart';

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
    shape: Icons.close,
  );
  final PlayerConfig player2 = PlayerConfig(
    color: Colors.blue,
    shape: Icons.circle_outlined,
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

  void onNextPage(){
    if(_currentPage  < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.fastEaseInToSlowEaseOut,);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: StaticBoard(
                        moveHistory: page.moves,
                        player1: player1,
                        player2: player2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.explanation,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ],
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
              return GestureDetector(
                onTap: () => _goTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface.withAlpha(100),
                    shape: BoxShape.circle,
                  ),
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
