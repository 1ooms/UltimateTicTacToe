import 'package:flutter/material.dart';

import '../../../../models/enum/player_shape.dart';
import '../../../../utils/ui_helpers.dart';

class ShapeSelectorGrid extends StatelessWidget {
  final PlayerShape selectedShape;
  final PlayerShape otherShape;
  final void Function(PlayerShape) onShapeSelected;
  final String label;

  const ShapeSelectorGrid({
    super.key,
    required this.selectedShape,
    required this.otherShape,
    required this.onShapeSelected,
    this.label = 'Shape',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shapes = PlayerShape.values.map((e) => e).toList();

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              shapes.map((shape) {
                final isTaken = shape == otherShape;
                final isSelected = shape == selectedShape;

                return GestureDetector(
                  onTap:
                      isTaken
                          ? () => showCustomSnackBar(
                            context,
                            Text(
                              'The other player is using this shape.',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onInverseSurface,
                              ),
                            ),
                          )
                          : () => onShapeSelected(shape),
                  child: Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color:
                          isTaken
                              ? colorScheme.onInverseSurface
                              : colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            isSelected
                                ? colorScheme.onSurface
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Opacity(
                      opacity: isTaken ? 0.4 : 1.0,
                      child: buildIcon(
                        shape,
                        isSelected
                            ? colorScheme.onSurface
                            : Colors.grey.shade500,
                        32,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );

    return content;
  }
}
