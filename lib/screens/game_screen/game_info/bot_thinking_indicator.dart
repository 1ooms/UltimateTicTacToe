import 'package:flutter/material.dart';

class BotThinkingIndicator extends StatelessWidget {
  final bool visible;

  const BotThinkingIndicator({super.key, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Bot is thinking",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 25.0,
            width: 25.0,
            child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.onSurface,
              strokeWidth: 2,
            ),
          ),
        ],
      ),
    );
  }
}
