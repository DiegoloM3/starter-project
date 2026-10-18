import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../../../auth/presentation/bloc/auth/auth_cubit.dart';
import '../../../../auth/presentation/bloc/auth/auth_state.dart';
import '../../../domain/entities/article.dart';
import '../../bloc/article_detail/article_detail_cubit.dart';
import '../../bloc/article_detail/article_detail_state.dart';
import '../../bloc/articles/articles_cubit.dart';
import '../../bloc/saved_articles/saved_articles_cubit.dart';
import '../../bloc/saved_articles/saved_articles_state.dart';
import '../../widgets/article_texts.dart';
import '../../widgets/article_thumbnail.dart';
import '../../widgets/rich_content/article_content_viewer.dart';

class ArticleDetailScreen extends StatelessWidget {
  const ArticleDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ArticleDetailCubit, ArticleDetailState>(
      listener: _onStateChanged,
      builder:
          (context, state) => Scaffold(
            appBar: AppBar(
              actions: [
                _SaveButton(article: state.article),
                if (_isAuthor(context, state.article))
                  _AuthorMenu(isDeleting: state.status == ArticleDetailStatus.deleting),
              ],
            ),
            body: _ArticleBody(article: state.article),
          ),
    );
  }

  bool _isAuthor(BuildContext context, ArticleEntity article) {
    final authState = context.watch<AuthCubit>().state;
    return authState is AuthAuthenticated && article.isAuthoredBy(authState.user.uid);
  }

  void _onStateChanged(BuildContext context, ArticleDetailState state) {
    final messenger = ScaffoldMessenger.of(context);
    if (state.status == ArticleDetailStatus.deleted) {
      context.read<ArticlesCubit>().load();
      context.read<SavedArticlesCubit>().load();
      messenger.showSnackBar(const SnackBar(content: Text('Artículo eliminado.')));
      Navigator.of(context).pop();
    } else if (state.status == ArticleDetailStatus.deleteFailure) {
      messenger.showSnackBar(const SnackBar(content: Text('No se pudo eliminar el artículo. Inténtalo de nuevo.')));
    }
  }
}

class _ArticleBody extends StatelessWidget {
  final ArticleEntity article;

  const _ArticleBody({required this.article});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      children: [
        ArticleTopicsText(article: article),
        const SizedBox(height: 12),
        Text(article.title, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.15)),
        const SizedBox(height: 12),
        Text(article.description, style: textTheme.titleMedium?.copyWith(height: 1.4)),
        const SizedBox(height: 16),
        ArticleMetaText(article: article),
        const SizedBox(height: 16),
        ArticleThumbnail(imageURL: article.thumbnailURL),
        const SizedBox(height: 24),
        ArticleContentViewer(content: article.content),
      ],
    );
  }
}

class _SaveButton extends StatelessWidget {
  final ArticleEntity article;

  const _SaveButton({required this.article});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SavedArticlesCubit, SavedArticlesState>(
      builder: (context, state) {
        final isSaved = state.isSaved(article.id);
        return IconButton(
          tooltip: isSaved ? 'Quitar de guardados' : 'Guardar',
          icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_border),
          onPressed: () => context.read<SavedArticlesCubit>().toggle(article),
        );
      },
    );
  }
}

enum _AuthorAction { edit, delete }

class _AuthorMenu extends StatelessWidget {
  final bool isDeleting;

  const _AuthorMenu({required this.isDeleting});

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return PopupMenuButton<_AuthorAction>(
      onSelected: (action) => action == _AuthorAction.edit ? _edit(context) : _confirmDelete(context),
      itemBuilder:
          (_) => const [
            PopupMenuItem(value: _AuthorAction.edit, child: Text('Editar')),
            PopupMenuItem(value: _AuthorAction.delete, child: Text('Eliminar')),
          ],
    );
  }

  Future<void> _edit(BuildContext context) async {
    final detailCubit = context.read<ArticleDetailCubit>();
    final updated = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.articleEditor, arguments: detailCubit.state.article);
    if (updated != null) detailCubit.refresh();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final detailCubit = context.read<ArticleDetailCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('¿Eliminar artículo?'),
            content: const Text('Esta acción no se puede deshacer.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.of(dialogContext).pop(true), child: const Text('Eliminar')),
            ],
          ),
    );
    if (confirmed == true) detailCubit.delete();
  }
}
