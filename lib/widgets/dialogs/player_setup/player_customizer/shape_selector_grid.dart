import 'package:flutter/material.dart';

import '../../../../utils/ui_helpers.dart';

class ShapeSelectorGrid extends StatelessWidget {
  final IconData selectedShape;
  final IconData otherShape;
  final void Function(IconData) onShapeSelected;
  final bool expand;
  final String label;

  const ShapeSelectorGrid({
    super.key,
    required this.selectedShape,
    required this.otherShape,
    required this.onShapeSelected,
    this.expand = false,
    this.label = 'Shape',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shapes = [
      Icons.circle_outlined,
      Icons.close,
      Icons.square_outlined,
      Icons.change_history,
      Icons.star_border,
      Icons.favorite_outline,
    ];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: shapes.map((shape) {
            final isTaken = shape == otherShape;
            final isSelected = shape == selectedShape;

            return GestureDetector(
              onTap: isTaken
                  ? () => showSnackbar(
                context,
                Text(
                  'The other player is using this shape.',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: colorScheme.onInverseSurface),
                ),
              )
                  : () => onShapeSelected(shape),
              child: Container(
                width: 48,
                height: 48,
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isTaken ? colorScheme.onInverseSurface : colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? colorScheme.onSurface : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Opacity(
                  opacity: isTaken ? 0.4 : 1.0,
                  child: buildIcon(
                    shape,
                    isSelected ? colorScheme.onSurface : colorScheme.onSurface.withAlpha(125),
                    32,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );

    return expand ? Expanded(child: content) : content;
  }
}

