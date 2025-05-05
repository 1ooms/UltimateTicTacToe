import 'package:flutter/material.dart';

import '../../main.dart';
import '../../models/player_config.dart';

Icon buildIcon(PlayerShape shape, Color color, double size) {
  switch (shape) {
    case PlayerShape.cross:
      return Icon(Icons.close, color: color, size: size);
    case PlayerShape.circle:
      return Icon(Icons.circle_outlined, color: color, size: size);
    case PlayerShape.square:
      return Icon(Icons.square_outlined, color: color, size: size);
    case PlayerShape.triangle:
      return Icon(Icons.change_history, color: color, size: size); // triangle
  }
}

class PlayerCustomizer extends StatelessWidget {
  PlayerCustomizer({
    super.key,
    required this.label,
    required this.config1,
    required this.config2,
    required this.onChanged,
  });

  String label;
  PlayerConfig config1;
  PlayerConfig config2;

  List<PlayerShape> availableShapes = PlayerShape.values;
  List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
  ];

  Function(PlayerConfig) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            buildIcon(config1.shape, config1.color, 32),
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                PlayerShape tempShape = config1.shape;
                Color tempColor = config1.color;

                showDialog(
                  context: navigatorKey.currentContext!,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          title: Text('Customize $label'),
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
                                                    ? Colors.grey.shade300
                                                    : Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color:
                                                  isSelected
                                                      ? Colors.black
                                                      : Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: Opacity(
                                            opacity: isTaken ? 0.4 : 1.0,
                                            child: buildIcon(
                                              shape,
                                              isSelected
                                                  ? Colors.black
                                                  : Colors.grey,
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
                                      final isTaken = color == config2.color;
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
                                                          ? Colors.black
                                                          : Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                            if (isTaken)
                                              CustomPaint(
                                                size: Size(48, 48),
                                                painter: DiagonalLinePainter(),
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
                                  color: Colors.grey.shade100,
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
