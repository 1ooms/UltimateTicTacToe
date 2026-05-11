import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/player_shape.dart';

class PlayerConfig {
  PlayerShape shape;
  Color color;

  PlayerConfig({required this.shape, required this.color});

  Map<String, dynamic> toJson() {
    return {
      'shape': shape.name,
      'color': color.toARGB32(),
    };
  }

  factory PlayerConfig.fromJson(Map<String, dynamic> json) {
    return PlayerConfig(
      shape: PlayerShape.values.byName(json['shape']),
      color: Color(json['color']),
    );
  }
}
