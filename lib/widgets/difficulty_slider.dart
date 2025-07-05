import 'package:flutter/material.dart';
import '../extensions/string_extension.dart';

import '../models/ai/ai_difficulty.dart';

class DifficultySlider extends StatelessWidget {
  final AIDifficulty selectedDifficulty;
  final ValueChanged<AIDifficulty> onChanged;

  const DifficultySlider({
    super.key,
    required this.selectedDifficulty,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AI Difficulty',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Slider(
          value: selectedDifficulty.index.toDouble(),
          min: 0,
          max: AIDifficulty.values.length - 1.0,
          divisions: AIDifficulty.values.length - 1,
          onChanged: (value) {
            onChanged(AIDifficulty.values[value.round()]);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AIDifficulty.values
              .map((d) => Text(d.name.capitalize(), style: const TextStyle(fontSize: 12)))
              .toList(),
        )
      ],
    );
  }
}
