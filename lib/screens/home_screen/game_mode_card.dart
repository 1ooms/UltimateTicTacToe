import 'package:flutter/material.dart';
import 'package:ultimate_tic_tac_toe/models/enum/game_mode.dart';

class CardGradients {
  CardGradients._();

  /// Blue gradient
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

  /// Orange gradient
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

  /// Purple gradient
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

class GameModeCard extends StatelessWidget {
  const GameModeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.gradient,
    this.iconColor,
    this.textColor,
    this.shadowColor,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? iconColor;
  final Color? textColor;
  final Color? shadowColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasGradient = gradient != null;

    final firstColor =
        gradient is LinearGradient
            ? (gradient as LinearGradient).colors.first
            : theme.colorScheme.primary;

    final effectiveIconColor =
        iconColor ?? (hasGradient ? Colors.white : theme.colorScheme.primary);
    final effectiveTextColor =
        textColor ??
        (hasGradient ? Colors.white : theme.textTheme.titleLarge?.color);

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: hasGradient ? 4 : 1,
      shadowColor:
          hasGradient
              ? (shadowColor ?? firstColor.withValues(alpha: 0.4))
              : null,
      surfaceTintColor: hasGradient ? Colors.transparent : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: hasGradient ? Colors.white.withValues(alpha: 0.2) : null,
          highlightColor:
              hasGradient ? Colors.white.withValues(alpha: 0.1) : null,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Icon(icon, size: 32, color: effectiveIconColor),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: effectiveTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
