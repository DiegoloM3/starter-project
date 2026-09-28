import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_entity.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_item_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_skeleton_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/status_message_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/confirm_action_sheet.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/swipe_confirm_widget.dart';

class SavedArticlesListScreen extends HookWidget {
  const SavedArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<LocalArticleBloc>()..add(const GetSavedArticles()),
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AppBar(
      leading: IconButton(
        onPressed: () => context.pop(),
        icon: Icon(Icons.arrow_back, color: colorScheme.primary),
      ),
      title: Text('Guardados',
          style: GlobalTheme.masthead(colorScheme, fontSize: 20)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<LocalArticleBloc, LocalArticlesState>(
      builder: (context, state) {
        if (state is LocalArticlesLoading) {
          return _buildSkeletonList(context);
        }
        if (state is LocalArticlesDone) {
          return state.articles.isEmpty
              ? _buildEmptyState(context)
              : _buildArticlesList(context, state.articles);
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildSkeletonList(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: 6,
            itemBuilder: (_, __) => const ArticleSkeletonWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const StatusMessageWidget(
      icon: Icons.archive_outlined,
      title: 'Archivo vacío',
      message: 'Los artículos que guardes de Daily News\naparecerán aquí.',
    );
  }

  Widget _buildArticlesList(
      BuildContext context, List<ArticleEntity> articles) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemCount: articles.length,
            itemBuilder: (context, index) => _buildDismissibleCard(context, articles[index], colorScheme, index), 
          ),
        ),
      ],
    );
  }


  Widget _buildDismissibleCard(BuildContext context, ArticleEntity article, ColorScheme colorScheme, int index) {
  return SwipeConfirmWidget(
    showHint: 0 == index,
    backgroundColor: colorScheme.secondary,
    foregroundColor: colorScheme.onSecondary,
    icon: Icons.bookmark_remove_outlined ,
    label: 'QUITAR',
    onConfirm: () => _confirmRemove(context, article),
    child: ArticleItemWidget(
      title: article.title ?? '',
      imageUrl: article.urlToImage ?? '',
      description: article.description ?? '',
      dateText: article.publishedAt ?? '',
      onTap: () => _onArticlePressed(context, article),
    ),
  );
}

  Future<bool> _confirmRemove(BuildContext context, ArticleEntity article) async {
    ConfirmActionSheet.show(
      context,
      title: '¿Sacar de guardados?',
      message: 'Podrás volver a guardarlo después si cambias de opinión.',
      confirmLabel: 'Sacar',
      confirmColor: Theme.of(context).colorScheme.secondary,
      onConfirm: () => _onRemoveArticle(context, article),
    );
    return true;   
  }
  

  void _onRemoveArticle(BuildContext context, ArticleEntity article) {
    context.read<LocalArticleBloc>().add(RemoveArticle(article: article));
  }

  void _onArticlePressed(BuildContext context, ArticleEntity article) {
    context.push(AppRouter.dailyNewsArticleDetail, extra: article);
  }
}







