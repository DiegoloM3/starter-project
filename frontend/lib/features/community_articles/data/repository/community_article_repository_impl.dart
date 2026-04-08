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
}
