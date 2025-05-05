import 'package:flutter/material.dart';

enum PlayerShape { cross, circle, square, triangle }

class PlayerConfig {
  PlayerShape shape;
  Color color;

  PlayerConfig({required this.shape, required this.color});
}
