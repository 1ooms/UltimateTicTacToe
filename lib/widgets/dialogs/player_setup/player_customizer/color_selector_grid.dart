import 'package:flutter/material.dart';

import '../../../../utils/ui_helpers.dart';

class ColorSelectorGrid extends StatelessWidget {
  final Color selectedColor;
  final Color otherColor;
  final void Function(Color) onColorSelected;
  final bool expand;
  final String label;

  const ColorSelectorGrid({
    super.key,
    required this.selectedColor,
    required this.otherColor,
    required this.onColorSelected,
    this.expand = false,
    this.label = 'Color',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colors = [
      Colors.red,
      Colors.orangeAccent,
      Colors.yellow,
      Colors.green,
      Colors.lightBlueAccent,
      Colors.blue,
      Colors.purple,
      Colors.pinkAccent,
    ];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              colors.map((color) {
                final isTaken = color.toARGB32() == otherColor.toARGB32();
                final isSelected = color.toARGB32() == selectedColor.toARGB32();

                return GestureDetector(
                  onTap:
                      isTaken
                          ? () => showCustomSnackBar(
                            context,
                            Text(
                              'The other player is using this color.',
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(
                                color: colorScheme.onInverseSurface,
                              ),
                            ),
                          )
                          : () => onColorSelected(color),
                  child: Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color:
                                isSelected
                                    ? colorScheme.onSurface
                                    : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      if (isTaken)
                        CustomPaint(
                          size: const Size(48, 48),
                          painter: DiagonalLinePainter(colorScheme),
                        ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );

    return expand ? Expanded(child: content) : content;
  }
}

class DiagonalLinePainter extends CustomPainter {
  final ColorScheme colorScheme;

  DiagonalLinePainter(this.colorScheme);

  @override
  void paint(Canvas canvas, Size size) {
    final path =
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, 0, size.width, size.height),
            const Radius.circular(8),
          ),
        );

    canvas.clipPath(path);

    final paint =
        Paint()
          ..color = Colors.grey.shade500
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
