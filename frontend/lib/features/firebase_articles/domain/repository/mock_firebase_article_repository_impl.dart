import 'dart:io';

import 'package:news_app_clean_architecture/features/firebase_articles/domain/entities/generated_article.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';

/// Temporary mock implementation for development.
/// Will be replaced by FirebaseArticleRepositoryImpl in the data layer step.
class MockFirebaseArticleRepositoryImpl implements FirebaseArticleRepository {
  final List<ArticleEntity> _articles = [
    const ArticleEntity(
      id: 1,
      author: 'Mock Journalist',
      authorId: 'mock-uid-123',
      title: 'Flutter Clean Architecture: A Deep Dive',
      description:
          'Exploring the benefits of clean architecture in Flutter apps.',
      urlToImage: 'https://picsum.photos/800/400?random=1',
      publishedAt: '2024-01-15T10:30:00Z',
      content: 'Clean Architecture separates the software into layers with '
          'defined responsibilities. This approach makes the codebase more '
          'maintainable, testable, and scalable.',
    ),
    const ArticleEntity(
      id: 2,
      author: 'Mock Journalist',
      authorId: 'mock-uid-123',
      title: 'Firebase vs Supabase: Which One to Choose?',
      description:
          'A comparison between two popular backend-as-a-service platforms.',
      urlToImage: 'https://picsum.photos/800/400?random=2',
      publishedAt: '2024-01-14T08:00:00Z',
      content: 'Both Firebase and Supabase offer authentication, database, '
          'and storage solutions. However, they differ significantly in their '
          'approach to data modeling and querying.',
    ),
  ];

  @override
  Future<List<ArticleEntity>> getArticles() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_articles);
  }

  @override
  Future<ArticleEntity> createArticle(CreateArticleParams params) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newArticle = ArticleEntity(
      id: _articles.length + 1,
      author: params.author,
      authorId: params.authorId,
      title: params.title,
      urlToImage:
          'https://picsum.photos/800/400?random=${_articles.length + 1}',
      publishedAt: DateTime.now().toIso8601String(),
      content: params.content,
    );
    _articles.add(newArticle);
    return newArticle;
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _articles.removeWhere((article) => article.id.toString() == articleId);
  }

  @override
  Future<GeneratedArticle> generateArticleContent(String prompt) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const GeneratedArticle(
      title: 'Mock Generated Title',
      description: 'Mock generated description',
      content: 'Mock generated content paragraph.',
    );
  }

  @override
  Future<File> generateArticleImage(String articleTitle) async {
    throw UnimplementedError('Image generation not available in mock');
  }
}
