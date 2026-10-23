import 'package:flutter/material.dart';
import '../models/enum/game_mode.dart';

/// Provides consistent color gradients for each [GameMode].
class GameModeGradients {
  GameModeGradients._();

  /// Blue gradient for local game mode.
  static LinearGradient local(bool isDarkMode) =>
      isDarkMode
          ? const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
          : const LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

  /// Orange gradient for online game mode.
  static LinearGradient online(bool isDarkMode) =>
      isDarkMode
          ? const LinearGradient(
            colors: [Color(0xFFE65100), Color(0xFFBF360C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
          : const LinearGradient(
            colors: [Color(0xFFFB8C00), Color(0xFFD84315)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

  /// Purple gradient for bot game mode.
  static LinearGradient bot(bool isDarkMode) =>
      isDarkMode
          ? const LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF311B92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
          : const LinearGradient(
            colors: [Color(0xFF8E24AA), Color(0xFF512DA8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

  /// Returns the appropriate gradient for the given [mode] and theme brightness.
  static LinearGradient forMode(GameMode mode, bool isDarkMode) {
    switch (mode) {
      case GameMode.local:
        return local(isDarkMode);
      case GameMode.online:
        return online(isDarkMode);
      case GameMode.bot:
        return bot(isDarkMode);
    }
  }
}

/// Type alias for backwards compatibility with existing [CardGradients] usage.
typedef CardGradients = GameModeGradients;
