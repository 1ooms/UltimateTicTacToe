import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/player_config.dart';

Icon buildIcon(IconData shape, Color color, double size) {
  return(Icon(shape, color: color, size: size));
}

class PlayerCustomizer extends StatelessWidget {
  PlayerCustomizer({
    super.key,
    required this.config1,
    required this.config2,
    required this.onChanged,
  });

  final PlayerConfig config1;
  final PlayerConfig config2;

  final List<IconData> availableShapes = [
    Icons.circle_outlined,
    Icons.close,
    Icons.square_outlined,
    Icons.change_history,
    Icons.star_border,
    Icons.favorite_outline,
  ];

  final List<Color> availableColors = [
    Colors.red,
    Colors.orangeAccent,
    Colors.yellow,
    Colors.green,
    Colors.lightBlueAccent,
    Colors.blue,
    Colors.purple,
    Colors.pinkAccent,
  ];

  final Function(PlayerConfig) onChanged;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.surface,
              ),
              child: buildIcon(
                config1.shape,
                config1.color,
                32,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                IconData tempShape = config1.shape;
                Color tempColor = config1.color;

                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          title: Text('Customize player'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Shape'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    availableShapes.map((shape) {
                                      final isTaken = shape == config2.shape;
                                      final isSelected = shape == tempShape;

                                      return GestureDetector(
                                        onTap:
                                            isTaken
                                                ? null
                                                : () {
                                                  setDialogState(() {
                                                    tempShape = shape;
                                                  });
                                                },
                                        child: Container(
                                          width: 48,
                                          height: 48,
                                          padding: const EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            color:
                                                isTaken
                                                    ? colorScheme.onInverseSurface
                                                    : colorScheme.surface,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
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
                                                  : colorScheme.onSurface.withAlpha(125),
                                              32,
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                              const SizedBox(height: 12),
                              const Text('Color'),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children:
                                    availableColors.map((color) {
                                      final isTaken = color.toARGB32() == config2.color.toARGB32();
                                      final isSelected = color == tempColor;
                                      return GestureDetector(
                                        onTap:
                                            isTaken
                                                ? null
                                                : () {
                                                  setDialogState(() {
                                                    tempColor = color;
                                                  });
                                                },
                                        child: Stack(
                                          children: [
                                            Container(
                                              width: 48,
                                              height: 48,
                                              decoration: BoxDecoration(
                                                color: color,
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                                size: Size(48, 48),
                                                painter: DiagonalLinePainter(colorScheme),
                                              ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                              ),

                              const SizedBox(height: 16),
                              const Text('Preview'),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: colorScheme.surface,
                                ),
                                child: buildIcon(
                                  tempShape,
                                  tempColor,
                                  32,
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                onChanged(
                                  PlayerConfig(
                                    shape: tempShape,
                                    color: tempColor,
                                  ),
                                );
                                Navigator.pop(context);
                              },
                              child: const Text("Save"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class DiagonalLinePainter extends CustomPainter {
  late ColorScheme colorScheme;

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
          ..color = colorScheme.outline
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
