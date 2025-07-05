import 'package:flutter/material.dart';

void showCustomSnackBar(BuildContext context, Text text) {
  final messenger = ScaffoldMessenger.of(context);

  messenger
      .showSnackBar(
        SnackBar(
          duration: Duration(milliseconds: 1000),
          content: Center(
            child: text,
          ),
        ),
      )
      .closed
      .then((value) => messenger.clearSnackBars());
}

Icon buildIcon(IconData shape, Color color, double size) {
  return Icon(shape, color: color, size: size);
}
