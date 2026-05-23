import 'package:flutter/material.dart';

import '../../../../models/player_config.dart';
import '../../../../utils/ui_helpers.dart';
import '../player_customizer/player_customization_dialog.dart';

class PlayerCustomizer extends StatelessWidget {
  final PlayerConfig config1;
  final PlayerConfig config2;
  final Function(PlayerConfig) onChanged;

  const PlayerCustomizer({
    super.key,
    required this.config1,
    required this.config2,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: colorScheme.surface,
          ),
          child: buildIcon(config1.shape, config1.color, 32),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(shape: CircleBorder()),
          child: const Icon(Icons.edit),
          onPressed: () {
            showDialog(
              barrierColor: Colors.transparent,
              context: context,
              builder:
                  (context) => ScaffoldMessenger(
                    child: Builder(
                      builder:
                          (context) => Scaffold(
                            backgroundColor: Colors.transparent,
                            body: PlayerCustomizationDialog(
                              currentConfig: config1,
                              otherConfig: config2,
                              onConfirm: onChanged,
                            ),
                          ),
                    ),
                  ),
            );
          },
        ),
      ],
    );
  }
}
