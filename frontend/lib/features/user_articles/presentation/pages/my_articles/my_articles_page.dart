import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/session/auth_session.dart';
import 'package:news_app_clean_architecture/features/user_articles/domain/entities/user_article_entity.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/my_articles/my_articles_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/article_card.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/primary_button.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MyArticlesPage extends StatefulWidget {
  const MyArticlesPage({super.key});

  @override
  State<MyArticlesPage> createState() => _MyArticlesPageState();
}

class _MyArticlesPageState extends State<MyArticlesPage> {
  late final MyArticlesCubit _cubit;
  late final String _authorId;

  @override
  void initState() {
    super.initState();
    _cubit = sl<MyArticlesCubit>();
    _authorId = sl<AuthSession>().currentUser?.id ?? '';
    _cubit.load(_authorId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Articles'),
          elevation: 0,
        ),
        body: BlocBuilder<MyArticlesCubit, MyArticlesState>(
          builder: (context, state) {
            return state.when(
              initial: () => const _LoadingView(),
              loading: () => const _LoadingView(),
              success: (articles) => _ListView(
                articles: articles,
                onRefresh: () => _cubit.load(_authorId),
                onDelete: (id) => _cubit.delete(authorId: _authorId, id: id),
              ),
              failure: (failure) => _ErrorView(
                failure: failure,
                onRetry: () => _cubit.load(_authorId),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push(AppRoutes.articleEditorNew());
            if (!mounted) return;
            await _cubit.load(_authorId);
          },
          icon: const Icon(Icons.add),
          label: const Text('New'),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ListView extends StatelessWidget {
  const _ListView({
    required this.articles,
    required this.onRefresh,
    required this.onDelete,
  });

  final List<UserArticleEntity> articles;
  final Future<void> Function() onRefresh;
  final void Function(String id) onDelete;

  @override
  Widget build(BuildContext context) {
    if (articles.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [_EmptyView()],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: articles.length,
        itemBuilder: (context, index) {
          final article = articles[index];
          return ArticleCard(
            article: article,
            onTap: () => context.push(
              AppRoutes.userArticleDetail(article.id),
              extra: article,
            ),
            onEdit: () async {
              await context.push(
                AppRoutes.articleEditorEdit(article.id),
                extra: article,
              );
              await onRefresh();
            },
            onDelete: () => _confirmDelete(context, article),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserArticleEntity article,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete article?'),
          content: Text('"${article.title}" will be permanently removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
    if (confirmed ?? false) {
      onDelete(article.id);
    }
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: theme.spacing.lg,
        vertical: 80,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.edit_note_outlined,
            size: 72,
            color: theme.onSurfaceMuted,
          ),
          SizedBox(height: theme.spacing.md),
          Text(
            'No articles yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.onSurface,
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          Text(
            'Tap "New" to publish your first story.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.onSurfaceMuted),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure, required this.onRetry});

  final AppFailure failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    final message = failure.when(
      network: (m, _) => m ?? 'Network error',
      cache: (m) => m ?? 'Cache error',
      validation: (f, r) => '$f: $r',
      auth: (m) => m ?? 'Please sign in',
      unknown: (_, __) => 'Something went wrong',
    );
    return Padding(
      padding: EdgeInsets.all(theme.spacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 56, color: theme.danger),
          SizedBox(height: theme.spacing.md),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: theme.onSurface),
          ),
          SizedBox(height: theme.spacing.lg),
          PrimaryButton(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}
