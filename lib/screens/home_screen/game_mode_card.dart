import 'package:flutter/material.dart';

export '../../utils/game_mode_gradients.dart';

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
