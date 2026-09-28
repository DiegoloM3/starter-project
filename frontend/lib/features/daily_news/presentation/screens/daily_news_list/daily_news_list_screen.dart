import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/carousel/article_carousel_skeleton_widget.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/widgets/carousel/article_carousel_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_item_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_skeleton_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/status_message_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/swipe_confirm_widget.dart';

class DailyNewsListScreen extends StatelessWidget {
  const DailyNewsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<RemoteArticlesBloc>()..add(const GetArticlesEvent())),
        BlocProvider.value(value: getIt<LocalArticleBloc>()..add(const GetSavedArticles())),
      ],
      child: Builder(
        builder: (context) => BlocBuilder<RemoteArticlesBloc, RemoteArticlesState>(
          builder: (context, state) => Scaffold(
            appBar: _buildAppBar(context, state),
            body: _buildBody(context, state),
            floatingActionButton: _buildFab(context),
          ),
        ),
      ),
    );
  }



  PreferredSizeWidget _buildAppBar(BuildContext context, RemoteArticlesState state) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      title: Text('Daily News', style: GlobalTheme.masthead(colorScheme)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
      actions: _buildAppBarActions(context, state),
    );
  }

  List<Widget> _buildAppBarActions(BuildContext context, RemoteArticlesState state) {
    return [
      _buildSearchAction(context, state),
      IconButton(onPressed: () => _seeMyArticles(context), icon: const Icon(Icons.article_outlined), tooltip: 'Mis artículos'),
      IconButton(onPressed: () => _onShowSavedArticles(context), icon: const Icon(Icons.bookmark_outline), tooltip: 'Guardados'),
      const SizedBox(width: 8),
    ];
  }

  Widget _buildSearchAction(BuildContext context, RemoteArticlesState state) {
    final articles = state is RemoteArticlesDone ? state.articles : null;
    return IconButton(
      onPressed: articles != null ? () => _openSearch(context, articles) : null,
      icon: const Icon(Icons.search),
      tooltip: 'Buscar',
    );
  }

 

  Widget _buildFab(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kInk, width: 1.5)),
      child: FloatingActionButton.extended(
        heroTag: 'write',
        onPressed: () => _addAnArticle(context),
        icon: const Icon(Icons.edit_outlined, size: 18),
        label: const Text('PUBLICAR'),
      ),
    );
  }



  Widget _buildBody(BuildContext context, RemoteArticlesState state) {
    if (state is RemoteArticlesLoading) return _buildSkeletonList();
    if (state is RemoteArticlesError) return _buildErrorState(context);
    if (state is RemoteArticlesDone) {
      return state.articles.isEmpty ? _buildEmptyState() : _buildArticlesList(context, state.articles);
    }
    return const SizedBox();
  }

  Widget _buildSkeletonList() {
    return Column(
      children: [
        const ArticleCarouselSkeletonWidget(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: 6,
            itemBuilder: (_, __) => const ArticleSkeletonWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const StatusMessageWidget(
      icon: Icons.newspaper_outlined,
      title: 'Sin noticias por ahora',
      message: 'Vuelve más tarde para ver las últimas publicaciones.',
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return StatusMessageWidget(
      icon: Icons.wifi_off,
      title: 'No se pudieron cargar',
      message: 'Revisa tu conexión e intenta de nuevo.',
      actionLabel: 'Reintentar',
      onAction: () => _refreshArticles(context),
    );
  }


  Widget _buildArticlesList(BuildContext context, List<ArticleEntity> articles) {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, localState) {
        final savedArticles = localState is LocalArticlesDone ? localState.articles : <ArticleEntity>[];
        return Column(
          children: [
            ArticleCarouselWidget(
              articles: articles,
              onArticleTap: (article) => _onArticlePressed(context, article),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  final isSaved = savedArticles.any((saved) => saved.url == article.url);
                  return _buildArticleCard(context, article, isSaved, index);   // 👈 agregar index aquí
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildArticleCard(BuildContext context, ArticleEntity article, bool isSaved, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwipeConfirmWidget(
      showHint: index == 0,  
      backgroundColor: isSaved ? colorScheme.secondary : GlobalTheme.kInk,
      foregroundColor: isSaved ? colorScheme.onSecondary : GlobalTheme.kPaper,
      icon: isSaved ? Icons.bookmark_remove_outlined : Icons.bookmark_outline,
      label: isSaved ? 'SACAR' : 'ARCHIVAR',
      onConfirm: () => isSaved ? _onSwipeUnsave(context, article) : _onSwipeSave(context, article),
      child: ArticleItemWidget(
        title: article.title ?? '',
        imageUrl: article.urlToImage ?? '',
        description: article.description ?? '',
        dateText: article.publishedAt ?? '',
        onTap: () => _onArticlePressed(context, article),
      ),
    );
  }


  Future<bool> _onSwipeSave(BuildContext context, ArticleEntity article) async {
    context.read<LocalArticleBloc>().add(SaveArticle(article: article));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(backgroundColor: Colors.black, content: Text('Guardado exitosamente.')),
    );
    return true;
  }

  Future<bool> _onSwipeUnsave(BuildContext context, ArticleEntity article) async {
    context.read<LocalArticleBloc>().add(RemoveArticle(article: article));
    return true;
  }

  void _refreshArticles(BuildContext context) {
    context.read<RemoteArticlesBloc>().add(const GetArticlesEvent());
  }

  void _addAnArticle(BuildContext context) {
    context.push(AppRouter.uploadUserArticle);
  }

  void _seeMyArticles(BuildContext context) {
    context.push(AppRouter.userArticles);
  }

  void _onShowSavedArticles(BuildContext context) {
    context.push(AppRouter.savedArticles);
  }

  void _openSearch(BuildContext context, List<ArticleEntity> articles) {
    context.push(AppRouter.articleSearch, extra: articles);
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    context.push(AppRouter.dailyNewsArticleDetail, extra: article);
  }
}