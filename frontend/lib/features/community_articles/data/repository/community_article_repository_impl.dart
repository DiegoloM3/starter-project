import 'dart:io';

import 'package:news_app_clean_architecture/features/community_articles/data/data_sources/remote/community_article_remote_datasource.dart';
import 'package:news_app_clean_architecture/features/community_articles/domain/repository/community_article_repository.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';

class CommunityArticleRepositoryImpl implements CommunityArticleRepository {
  final CommunityArticleRemoteDataSource _remote;

  CommunityArticleRepositoryImpl(this._remote);

  @override
  Stream<List<ArticleEntity>> watchArticles() => _remote.watchArticles();

  @override
  Future<String> uploadArticleImage({
    required String uid,
    required File imageFile,
  }) =>
      _remote.uploadArticleImage(uid: uid, imageFile: imageFile);

  @override
  Future<String> publishArticle(ArticleEntity article) =>
      _remote.publishArticle(article);

  @override
  Future<void> deleteArticle({
    required String firestoreId,
    String? imageUrl,
  }) =>
      _remote.deleteArticle(firestoreId: firestoreId, imageUrl: imageUrl);

  @override
  Future<void> updateArticle({
    required String firestoreId,
    required String title,
    required String description,
    required String content,
    String? imageUrl,
    String? oldImageUrl,
  }) =>
      _remote.updateArticle(
        firestoreId: firestoreId,
        title: title,
        description: description,
        content: content,
        imageUrl: imageUrl,
        oldImageUrl: oldImageUrl,
      );
}
