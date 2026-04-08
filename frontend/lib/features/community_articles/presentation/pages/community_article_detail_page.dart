import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/publish_article_page.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_body.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_deleting_indicator.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/widgets/community_article_detail_hero_image.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class CommunityArticleDetailPage extends StatefulWidget {
  final ArticleEntity article;

  const CommunityArticleDetailPage({Key? key, required this.article})
      : super(key: key);

  @override
  State<CommunityArticleDetailPage> createState() =>
      _CommunityArticleDetailPageState();
}

class _CommunityArticleDetailPageState
    extends State<CommunityArticleDetailPage> {
  late ArticleEntity _article;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _article = widget.article;
  }

  bool get _isOwner {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    return currentUid != null && currentUid == _article.uid;
  }

  Future<void> _openEdit() async {
    final cubit = context.read<CommunityFeedCubit>();
    final updated = await Navigator.of(context).push<ArticleEntity>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PublishArticlePage(initialArticle: _article),
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _article = updated);
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this article?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    final firestoreId = _article.firestoreId;
    if (firestoreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete: missing article id.')),
      );
      return;
    }

    setState(() => _deleting = true);

    try {
      await context.read<CommunityFeedCubit>().deleteArticle(
            firestoreId: firestoreId,
            imageUrl: _article.urlToImage,
          );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not delete. Check your connection and try again.',
          ),
        ),
      );
      setState(() => _deleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final article = _article;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Article'),
        actions: [
          if (_isOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: _deleting ? null : _openEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: _deleting ? null : _confirmDelete,
            ),
          ],
        ],
      ),
      body: AbsorbPointer(
        absorbing: _deleting,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (article.urlToImage != null && article.urlToImage!.isNotEmpty)
                CommunityArticleDetailHeroImage(imageUrl: article.urlToImage!),
              CommunityArticleDetailBody(
                title: article.title ?? '(untitled)',
                publishedAt: article.publishedAt,
                description: article.description ?? '',
                content: article.content ?? '',
              ),
              if (_deleting) const CommunityArticleDetailDeletingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}
