import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/theme.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_upload_entity.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/get_upload_articles_usecase.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/pages/community_article_detail_screen.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

class MyArticlesScreen extends StatefulWidget {
  const MyArticlesScreen({Key? key}) : super(key: key);

  @override
  State<MyArticlesScreen> createState() => _MyArticlesScreenState();
}

class _MyArticlesScreenState extends State<MyArticlesScreen> {
  late Future<List<ArticleUploadEntity>> _articlesFuture;

  @override
  void initState() {
    super.initState();
    _articlesFuture = _load();
  }

  Future<List<ArticleUploadEntity>> _load() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return sl<GetMyArticlesUseCase>()(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Articles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<List<ArticleUploadEntity>>(
        future: _articlesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Failed to load articles:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            );
          }
          final articles = snapshot.data ?? [];
          if (articles.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.article_outlined, size: 56, color: AppColors.textMuted),
                  SizedBox(height: 16),
                  Text(
                    'You haven\'t published any articles yet.',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 15),
                  ),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: articles.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) =>
                _ArticleRow(article: articles[index]),
          );
        },
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  final ArticleUploadEntity article;

  const _ArticleRow({required this.article});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          article.thumbnailUrl,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 64,
            height: 64,
            color: AppColors.accentLight,
            child: const Icon(Icons.image_outlined, color: AppColors.textMuted),
          ),
        ),
      ),
      title: Text(
        article.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            const Icon(Icons.access_time_outlined, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text(
              '${article.readTime} min',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.visibility_outlined, size: 12, color: AppColors.textMuted),
            const SizedBox(width: 3),
            Text(
              '${article.views}',
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CommunityArticleDetailScreen(article: article),
        ),
      ),
    );
  }
}
