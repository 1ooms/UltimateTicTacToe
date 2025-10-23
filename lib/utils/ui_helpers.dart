import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';

void showCustomSnackBar(BuildContext context, Text text) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
      .showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Center(child: text),
        ),
      )
      .closed
      .then((value) => messenger.clearSnackBars());
}

Icon buildIcon(PlayerShape shape, Color color, double size) {
  return Icon(shape.icon, color: color, size: size);
}
