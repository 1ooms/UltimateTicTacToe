import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';

class PlayerConfig {
  PlayerShape shape;
  Color color;

  PlayerConfig({required this.shape, required this.color});
}