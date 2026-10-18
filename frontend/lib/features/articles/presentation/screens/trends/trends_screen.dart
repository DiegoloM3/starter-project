import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../domain/entities/topic_trend.dart';
import '../../bloc/trends/trends_cubit.dart';
import '../../bloc/trends/trends_state.dart';
import '../../widgets/status_message.dart';
import '../../widgets/topic_names.dart';

/// Trends tab: topics ranked by the articles published in the last week.
class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tendencias')),
      body: BlocBuilder<TrendsCubit, TrendsState>(
        builder:
            (context, state) =>
                RefreshIndicator(onRefresh: context.read<TrendsCubit>().load, child: _buildContent(context, state)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TrendsState state) {
    if (state.trends.isNotEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const _PeriodNote(),
          const Divider(),
          for (final (index, trend) in state.trends.indexed) ...[
            _TrendTile(
              position: index + 1,
              trend: trend,
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.topicArticles, arguments: trend),
            ),
            const Divider(indent: 16, endIndent: 16),
          ],
        ],
      );
    }
    return switch (state.status) {
      TrendsStatus.initial || TrendsStatus.loading => const Center(child: CircularProgressIndicator()),
      TrendsStatus.failure => StatusMessage(
        icon: Icons.wifi_off,
        message: 'No se pudieron cargar las tendencias.',
        actionLabel: 'Reintentar',
        onAction: context.read<TrendsCubit>().load,
      ),
      TrendsStatus.success => ListView(
        children: const [
          SizedBox(height: 120),
          StatusMessage(icon: Icons.trending_up, message: 'No se publicaron artículos en los últimos 7 días.'),
        ],
      ),
    };
  }
}

class _PeriodNote extends StatelessWidget {
  const _PeriodNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        'Temas con más artículos publicados en los últimos 7 días.',
        style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final int position;
  final TopicTrend trend;
  final VoidCallback onTap;

  const _TrendTile({required this.position, required this.trend, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = trend.articleCount;
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        child: Text('$position', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
      ),
      title: Text(
        trend.topic.displayName.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 1.2),
      ),
      subtitle: Text(
        '$count ${count == 1 ? 'artículo' : 'artículos'} · ${trend.articles.first.title}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
