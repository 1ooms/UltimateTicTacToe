import 'package:flutter/material.dart';

class PlayAgainButton extends StatelessWidget {
  final bool visible;
  final VoidCallback onPressed;

  const PlayAgainButton({
    super.key,
    required this.visible,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: ElevatedButton(onPressed: onPressed, child: const Text("Play again")),
    );
  }
}
