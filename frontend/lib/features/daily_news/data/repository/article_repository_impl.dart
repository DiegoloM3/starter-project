import 'dart:io';

import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/errors/exception_mapper.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/DAO/article_dao.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_api_service.dart';
import '../data_sources/remote/article_images_storage_data_source.dart';
import '../data_sources/remote/articles_firestore_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final ArticleDao _articleDao;
  final ArticlesFirestoreDataSource _articlesFirestoreDataSource;
  final ArticleImagesStorageDataSource _articleImagesStorageDataSource;

  ArticleRepositoryImpl(
    this._newsApiService,
    this._articleDao,
    this._articlesFirestoreDataSource,
    this._articleImagesStorageDataSource,
  );
  
  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
   try {
    final httpResponse = await _newsApiService.getNewsArticles(
      apiKey:newsAPIKey,
      country:countryQuery,
      category:categoryQuery,
    );

    if (httpResponse.response.statusCode == HttpStatus.ok) {
      final apiArticles = httpResponse.data;
      final communityArticles = await _articlesFirestoreDataSource.getAllArticles();
      final merged = <ArticleEntity>[
        ...apiArticles,
        ...communityArticles,
      ];
      merged.sort((a, b) => _parseArticleDate(b).compareTo(_parseArticleDate(a)));
      return DataSuccess(merged);
    } else {
      return DataFailed(
        ApiException(
          httpResponse.response.statusMessage ?? 'API request failed',
        ),
      );
    }
   } on SocketException {
    return const DataFailed(NetworkException());
   } catch (e) {
    return DataFailed(mapException(e));
   }
  }

  @override
  Future<List<ArticleModel>> getSavedArticles() async {
    return _articleDao.getArticles();
  }

  @override
  Future<DataState<List<ArticleEntity>>> getArticlesByAuthor(String authorId) async {
    try {
      final models = await _articlesFirestoreDataSource.getArticlesByAuthor(authorId);
      final entities = models
          .map<ArticleEntity>(
            (m) => ArticleEntity(
              id: m.id,
              authorId: m.authorId,
              author: m.author,
              title: m.title,
              description: m.description,
              url: m.url,
              urlToImage: m.urlToImage,
              publishedAt: m.publishedAt,
              content: m.content,
            ),
          )
          .toList();
      return DataSuccess(entities);
    } catch (e) {
      return DataFailed(mapException(e));
    }
  }

  @override
  Future<DataState<List<ArticleEntity>>> getCommunityArticles() async {
    try {
      final models = await _articlesFirestoreDataSource.getAllArticles();
      return DataSuccess(models);
    } catch (e) {
      return DataFailed(mapException(e));
    }
  }

  @override
  Future<void> deleteMyArticle(ArticleEntity article) async {
    final documentId = article.documentId;
    if (documentId != null && documentId.isNotEmpty) {
      await _articlesFirestoreDataSource.deleteArticleById(documentId);
      return;
    }

    final authorId = article.authorId;
    final title = article.title;
    if (authorId == null || authorId.isEmpty || title == null || title.isEmpty) {
      return;
    }

    await _articlesFirestoreDataSource.deleteArticleByAuthorAndContent(
      authorId: authorId,
      title: title,
      description: article.description,
      content: article.content,
    );
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _articleDao.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<String> uploadArticleImage({
    required String authorId,
    required String localPath,
  }) {
    return _articleImagesStorageDataSource.uploadArticleImage(
      authorId: authorId,
      localPath: localPath,
    );
  }

  @override
  Future<void> saveArticle(ArticleEntity article) async {
    String? imageUrl = article.urlToImage;
    final authorId = article.authorId;

    if (_isLocalPath(imageUrl) && authorId != null && authorId.isNotEmpty) {
      final file = File(imageUrl!);
      if (await file.exists()) {
        imageUrl = await _articleImagesStorageDataSource.uploadArticleImage(
          authorId: authorId,
          localPath: imageUrl,
        );
      }
    }

    final remoteArticle = ArticleModel(
      id: article.id,
      documentId: article.documentId,
      authorId: article.authorId,
      author: article.author,
      title: article.title,
      description: article.description,
      url: article.url,
      urlToImage: imageUrl,
      publishedAt: article.publishedAt,
      content: article.content,
    );

    await _articlesFirestoreDataSource.createArticle(remoteArticle);
  }

  @override
  Future<void> saveArticleLocally(ArticleEntity article) {
    return _articleDao.insertArticle(ArticleModel.fromEntity(article));
  }

  DateTime _parseArticleDate(ArticleEntity article) {
    final value = article.publishedAt;
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    return DateTime.tryParse(value) ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  bool _isLocalPath(String? path) {
    if (path == null || path.isEmpty) return false;
    return !path.startsWith('http://') && !path.startsWith('https://');
  }

}
