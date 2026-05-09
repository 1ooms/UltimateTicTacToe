import 'package:flutter/material.dart';

import '../../../../extensions/string_extension.dart';
import '../../../../models/enum/bot_difficulty.dart';

class DifficultySlider extends StatelessWidget {
  final BotDifficulty selectedDifficulty;
  final ValueChanged<BotDifficulty> onChanged;

  const DifficultySlider({
    super.key,
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Bot Difficulty', style: Theme.of(context).textTheme.titleSmall),
        Slider(
          value: selectedDifficulty.index.toDouble(),
          min: 0,
          max: BotDifficulty.values.length - 1.0,
          divisions: BotDifficulty.values.length - 1,
          onChanged: (value) {
            onChanged(BotDifficulty.values[value.round()]);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:
              BotDifficulty.values
                  .map(
                    (d) => Text(
                      d.name.capitalize(),
                      style: const TextStyle(fontSize: 12),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }
}
