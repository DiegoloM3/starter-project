import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/bloc/community_feed_cubit.dart';
import 'package:news_app_clean_architecture/features/community_articles/presentation/pages/publish_article_page.dart';
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
                CachedNetworkImage(
                  imageUrl: article.urlToImage!,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 240,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 240,
                    color: const Color(0xFFEEEEEE),
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined,
                        size: 40, color: Color(0xFF9E9E9E)),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title ?? '(untitled)',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (article.publishedAt != null)
                      Text(
                        article.publishedAt!.substring(0, 10),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF999999),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if ((article.description ?? '').isNotEmpty) ...[
                      Text(
                        article.description!,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF444444),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      article.content ?? '',
                      style: const TextStyle(fontSize: 15, height: 1.5),
                    ),
                  ],
                ),
              ),
              if (_deleting)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
