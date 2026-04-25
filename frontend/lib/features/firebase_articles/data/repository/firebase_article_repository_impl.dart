import 'dart:io';

import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/firestore_article_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/data_sources/storage_data_source.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/data/models/firebase_article_model.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/params/create_article_params.dart';
import 'package:news_app_clean_architecture/features/firebase_articles/domain/repository/firebase_article_repository.dart';
import 'package:news_app_clean_architecture/shared/article/domain/entities/article.dart';

import '../../domain/entities/generated_article.dart';
import '../data_sources/ai_article_data_source.dart';

class FirebaseArticleRepositoryImpl implements FirebaseArticleRepository {
  final FirestoreArticleDataSource _firestoreDataSource;
  final StorageDataSource _storageDataSource;
  final AiArticleDataSource _aiDataSource;

  FirebaseArticleRepositoryImpl(
    this._firestoreDataSource,
    this._storageDataSource,
    this._aiDataSource,
  );

  @override
  Future<List<ArticleEntity>> getArticles() async {
    final models = await _firestoreDataSource.getArticles();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<ArticleEntity> createArticle(CreateArticleParams params) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${timestamp}_${params.authorId}.jpg';

    final thumbnailURL = await _storageDataSource.uploadArticleThumbnail(
      fileName,
      File(params.thumbnailPath),
    );

    final now = DateTime.now().toIso8601String();

    final model = FirebaseArticleModel(
      documentId: '',
      author: params.author,
      authorId: params.authorId,
      title: params.title,
      description: params.description,
      urlToImage: thumbnailURL,
      publishedAt: now,
      content: params.content,
    );

    await _firestoreDataSource.createArticle(model.toFirestore());

    return model.toEntity();
  }

  @override
  Future<void> deleteArticle(String articleId) async {
    await _firestoreDataSource.deleteArticle(articleId);
  }

  @override
  Future<GeneratedArticle> generateArticleContent(String prompt) {
    return _aiDataSource.generateArticle(prompt);
  }

  @override
  Future<File> generateArticleImage(String articleTitle) {
    return _aiDataSource.generateArticleImage(articleTitle);
  }
}
