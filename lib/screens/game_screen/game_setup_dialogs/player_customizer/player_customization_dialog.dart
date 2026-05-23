import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/screens/game_screen/game_setup_dialogs/player_customizer/shape_selector_grid.dart';

import '../../../../models/enum/player_shape.dart';
import '../../../../models/player_config.dart';
import '../../../../utils/ui_helpers.dart';
import 'color_selector_grid.dart';

class PlayerCustomizationDialog extends StatefulWidget {
  final PlayerConfig currentConfig;
  final PlayerConfig otherConfig;
  final Function(PlayerConfig) onConfirm;

  const PlayerCustomizationDialog({
    super.key,
    required this.currentConfig,
    required this.otherConfig,
    required this.onConfirm,
  });

  @override
  State<PlayerCustomizationDialog> createState() =>
      _PlayerCustomizationDialogState();
}

class _PlayerCustomizationDialogState extends State<PlayerCustomizationDialog> {
  late PlayerShape selectedShape;
  late Color selectedColor;

  @override
  void initState() {
    super.initState();
    selectedShape = widget.currentConfig.shape;
    selectedColor = widget.currentConfig.color;
  }

  Widget buildPreview(ColorScheme colorScheme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Preview'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
          ),
          child: buildIcon(selectedShape, selectedColor, 32),
        ),
      ],
    );
  }

  void confirmSelection() {
    final playerShape = PlayerShape.values.firstWhere(
      (e) => e.name == selectedShape.name,
    );

    widget.onConfirm(PlayerConfig(shape: playerShape, color: selectedColor));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    final shapeSelector = ShapeSelectorGrid(
      selectedShape: selectedShape,
      otherShape: widget.otherConfig.shape,
      onShapeSelected: (shape) => setState(() => selectedShape = shape),
    );

    final colorSelector = ColorSelectorGrid(
      selectedColor: selectedColor,
      otherColor: widget.otherConfig.color,
      onColorSelected: (color) => setState(() => selectedColor = color),
    );

    final preview = buildPreview(colorScheme);

    final layout =
        isLandscape
            ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 3 * 48 + 2 * 8, child: shapeSelector),
                const SizedBox(width: 24),
                SizedBox(width: 4 * 48 + 3 * 8, child: colorSelector),
                const SizedBox(width: 24),
                preview,
              ],
            )
            : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                shapeSelector,
                const SizedBox(height: 12),
                colorSelector,
                const SizedBox(height: 16),
                preview,
              ],
            );

    return AlertDialog(
      scrollable: true,
      title: const Text('Customize player'),
      content: layout,

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(onPressed: confirmSelection, child: const Text("Save")),
      ],
    );
  }
}
