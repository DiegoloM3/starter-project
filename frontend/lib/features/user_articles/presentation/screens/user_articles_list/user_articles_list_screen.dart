import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/routes.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';
import 'package:news_app_clean_architecture/di/service_locator.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/utils/format_date_util.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_item_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/article/article_skeleton_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/feedback/status_message_widget.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/confirm_action_sheet.dart';
import 'package:news_app_clean_architecture/shared/widgets/interaction/swipe_confirm_widget.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/user_articles_list/user_articles_bloc.dart';

class UserArticlesListScreen extends StatelessWidget {
  const UserArticlesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<UserArticlesBloc>()..add(const GetUserArticles()),
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
      title: Text('Mis Artículos', style: GlobalTheme.masthead(colorScheme, fontSize: 20)),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: GlobalTheme.kRule),
      ),
    );
  }

  Widget _buildBody() {
    return BlocConsumer<UserArticlesBloc, UserArticlesState>(
      listenWhen: (previous, current) => current is UserArticlesError && current.showSnackbar,
      listener: _handleStateChange,
      buildWhen: (previous, current) => !(current is UserArticlesError && current.showSnackbar),
      builder: (context, state) {
        if (state is UserArticlesLoading) return _buildSkeletonList();
        if (state is UserArticlesDone) {
          return state.articles.isEmpty ? _buildEmptyState() : _buildArticlesList(context, state.articles);
        }
        if (state is UserArticlesError) return _buildErrorState(context, state.message);
        return const SizedBox.shrink();
      },
    );
  }

  void _handleStateChange(BuildContext context, UserArticlesState state) {
    if (state is UserArticlesError) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
    }
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => const ArticleSkeletonWidget(),
    );
  }

  Widget _buildEmptyState() {
    return const StatusMessageWidget(
      icon: Icons.edit_note_outlined,
      title: 'Nada publicado aún',
      message: 'Los artículos que escribas\naparecerán aquí.',
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return StatusMessageWidget(
      icon: Icons.error_outline,
      title: 'No se pudo cargar',
      message: message,
      actionLabel: 'Reintentar',
      onAction: () => context.read<UserArticlesBloc>().add(const GetUserArticles()),
    );
  }

  Widget _buildArticlesList(BuildContext context, List<UserArticleEntity> articles) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: articles.length,
      itemBuilder: (context, index) => _buildArticleCard(context, articles[index], index), 
    );
  }

  Widget _buildArticleCard(BuildContext context, UserArticleEntity article, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    return SwipeConfirmWidget(
      showHint: 0 == index,
      backgroundColor: colorScheme.secondary,
      foregroundColor: colorScheme.onSecondary,
      icon: Icons.delete_outline,
      label: 'BORRAR',
      onConfirm: () => _confirmDelete(context, article),
      child: ArticleItemWidget(
        title: article.title,
        imageUrl: article.thumbnailUrl,
        description: article.content,
        dateText: formatDateUtil(article.publishedAt),
        onTap: () => context.push(AppRouter.userArticleDetails, extra: article),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, UserArticleEntity article) async {
    final colorScheme = Theme.of(context).colorScheme;
    ConfirmActionSheet.show(
      context,
      title: '¿Borrar artículo?',
      message: 'Esta acción no se puede deshacer.',
      confirmLabel: 'Borrar',
      confirmColor: colorScheme.secondary,
      onConfirm: () => context.read<UserArticlesBloc>().add(DeleteUserArticle(article: article)),
    );
    return true;
  }
}