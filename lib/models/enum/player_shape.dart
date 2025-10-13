import 'package:flutter/material.dart';

enum PlayerShape {
  cross(Icons.close),
  circle(Icons.circle_outlined),
  square(Icons.square_outlined),
  triangle(Icons.change_history),
  star(Icons.star_border),
  heart(Icons.favorite_outline);

  final IconData icon;
  const PlayerShape(this.icon);
}