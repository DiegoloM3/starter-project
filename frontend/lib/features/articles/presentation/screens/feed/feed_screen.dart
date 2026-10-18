import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/articles/articles_cubit.dart';
import '../../bloc/articles/articles_state.dart';
import '../../widgets/article_list.dart';
import '../../widgets/status_message.dart';

/// News tab with two sections: articles to discover ("Para ti") and those of the followed users.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SYMMETRY NEWS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 3)),
          bottom: const TabBar(tabs: [Tab(text: 'Para ti'), Tab(text: 'Siguiendo')]),
        ),
        body: BlocBuilder<ArticlesCubit, ArticlesState>(
          builder:
              (context, state) => TabBarView(
                children: [
                  _ArticlesSection(
                    state: state,
                    articles: state.forYouArticles,
                    emptyMessage: const StatusMessage(
                      icon: Icons.newspaper,
                      message: 'No hay noticias por descubrir en este momento.',
                    ),
                  ),
                  _ArticlesSection(
                    state: state,
                    articles: state.followingArticles,
                    emptyMessage: const StatusMessage(
                      icon: Icons.person_add_alt,
                      message: 'Sigue a periodistas desde sus perfiles para ver aquí sus artículos.',
                    ),
                  ),
                ],
              ),
        ),
      ),
    );
  }
}

class _ArticlesSection extends StatelessWidget {
  final ArticlesState state;
  final List<ArticleEntity> articles;
  final Widget emptyMessage;

  const _ArticlesSection({required this.state, required this.articles, required this.emptyMessage});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(onRefresh: context.read<ArticlesCubit>().load, child: _buildContent(context));
  }

  Widget _buildContent(BuildContext context) {
    if (articles.isNotEmpty) {
      return ArticleList(
        articles: articles,
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
      ArticlesStatus.success => _ScrollableMessage(child: emptyMessage),
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
