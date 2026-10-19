import 'package:flutter/material.dart';
import '../../controllers/stats_controller.dart';
import '../../extensions/string_extension.dart';
import '../../models/enum/bot_difficulty.dart';
import '../../models/game_stats.dart';
import '../../utils/game_mode_gradients.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final statsController = StatsController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: ListenableBuilder(
        listenable: statsController,
        builder: (context, _) {
          return _StatisticsBody(stats: statsController.stats);
        },
      ),
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      return _LandscapeLayout(stats: stats);
    }

    return _PortraitLayout(stats: stats);
  }
}

class _PortraitLayout extends StatelessWidget {
  const _PortraitLayout({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      children: [
        _OverviewSection(stats: stats),
        const SizedBox(height: 20),
        _ModeSection(stats: stats),
        const SizedBox(height: 20),
        _BotDifficultySection(stats: stats),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _LandscapeLayout extends StatelessWidget {
  const _LandscapeLayout({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  _OverviewSection(stats: stats),
                  const SizedBox(height: 16),
                  _ModeSection(stats: stats),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _BotDifficultySection(stats: stats),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatMetricCard(
            title: 'Total Played',
            value: '${stats.totalGamesPlayed}',
            icon: Icons.sports_esports_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatMetricCard(
            title: 'Bot Games Won',
            value: '${stats.totalBotWins}',
            icon: Icons.emoji_events_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatMetricCard extends StatelessWidget {
  const _StatMetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSection extends StatelessWidget {
  const _ModeSection({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Games played per mode',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _ModeGradientCard(
          title: 'Local Games',
          count: stats.localGamesPlayed,
          icon: Icons.group,
          gradient: CardGradients.local(isDarkMode),
        ),
        _ModeGradientCard(
          title: 'Online Games',
          count: stats.onlineGamesPlayed,
          icon: Icons.public,
          gradient: CardGradients.online(isDarkMode),
        ),
        _ModeGradientCard(
          title: 'Bot Games',
          count: stats.botGamesPlayed,
          icon: Icons.smart_toy,
          gradient: CardGradients.bot(isDarkMode),
        ),
      ],
    );
  }
}

class _ModeGradientCard extends StatelessWidget {
  const _ModeGradientCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.gradient,
  });

  final String title;
  final int count;
  final IconData icon;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(gradient: gradient),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 28, color: Colors.white),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '$count',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotDifficultySection extends StatelessWidget {
  const _BotDifficultySection({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Bot Games By Difficulty',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _DifficultyTile(
          difficulty: BotDifficulty.easy,
          wins: stats.botWinsFor(BotDifficulty.easy),
          played: stats.botGamesFor(BotDifficulty.easy),
          accentColor: Colors.teal,
        ),
        _DifficultyTile(
          difficulty: BotDifficulty.medium,
          wins: stats.botWinsFor(BotDifficulty.medium),
          played: stats.botGamesFor(BotDifficulty.medium),
          accentColor: Colors.amber.shade700,
        ),
        _DifficultyTile(
          difficulty: BotDifficulty.hard,
          wins: stats.botWinsFor(BotDifficulty.hard),
          played: stats.botGamesFor(BotDifficulty.hard),
          accentColor: Colors.deepOrange,
        ),
        _DifficultyTile(
          difficulty: BotDifficulty.expert,
          wins: stats.botWinsFor(BotDifficulty.expert),
          played: stats.botGamesFor(BotDifficulty.expert),
          accentColor: Colors.purple.shade600,
        ),
      ],
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({
    required this.difficulty,
    required this.wins,
    required this.played,
    required this.accentColor,
  });

  final BotDifficulty difficulty;
  final int wins;
  final int played;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final winRateText = played > 0
        ? '${((wins / played) * 100).toStringAsFixed(0)}%'
        : '0%';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 22,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  difficulty.name.capitalize(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _DifficultyMetricRow(
              icon: Icons.sports_esports_outlined,
              label: 'Games Played',
              value: '$played',
              iconColor: colorScheme.primary,
            ),
            const SizedBox(height: 6),
            _DifficultyMetricRow(
              icon: Icons.emoji_events_outlined,
              label: 'Games Won',
              value: '$wins',
              iconColor: colorScheme.primary,
            ),
            const SizedBox(height: 6),
            _DifficultyMetricRow(
              icon: Icons.trending_up,
              label: 'Win Rate',
              value: winRateText,
              iconColor: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyMetricRow extends StatelessWidget {
  const _DifficultyMetricRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
