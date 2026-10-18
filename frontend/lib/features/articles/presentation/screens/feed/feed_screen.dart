import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../bloc/articles/articles_cubit.dart';
import '../../bloc/articles/articles_state.dart';
import '../../widgets/article_list.dart';
import '../../widgets/status_message.dart';

/// News tab: the latest articles, newest first.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SYMMETRY', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 4))),
      body: BlocBuilder<ArticlesCubit, ArticlesState>(
        builder:
            (context, state) =>
                RefreshIndicator(onRefresh: context.read<ArticlesCubit>().load, child: _buildContent(context, state)),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ArticlesState state) {
    if (state.articles.isNotEmpty) {
      return ArticleList(
        articles: state.articles,
        onArticleTap: (article) => Navigator.of(context).pushNamed(AppRoutes.articleDetail, arguments: article),
      );
    }
    return switch (state.status) {
      ArticlesStatus.initial || ArticlesStatus.loading => const Center(child: CircularProgressIndicator()),
      ArticlesStatus.failure => StatusMessage(
        icon: Icons.wifi_off,
        message: 'No se pudieron cargar las noticias.',
        actionLabel: 'Reintentar',
        onAction: context.read<ArticlesCubit>().load,
      ),
      ArticlesStatus.success => const _ScrollableMessage(
        child: StatusMessage(icon: Icons.newspaper, message: 'Todavía no hay noticias publicadas.'),
      ),
    };
  }
}

/// Lets the pull to refresh gesture work when there is no list.
class _ScrollableMessage extends StatelessWidget {
  final Widget child;

  const _ScrollableMessage({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(height: constraints.maxHeight, child: child),
          ),
    );
  }
}
