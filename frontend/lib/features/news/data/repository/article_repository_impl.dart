import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logging/logging.dart';
import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/local/article_local_mapper.dart';
import 'package:news_app_clean_architecture/features/news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/repository/article_repository.dart';

@LazySingleton(as: ArticleRepository)
/// [ArticleRepository] implementation over [NewsApiService] and [AppDatabase].
class ArticleRepositoryImpl implements ArticleRepository {
  static final _log = Logger('ArticleRepositoryImpl');

  final NewsApiService _newsApiService;
  final AppDatabase _appDatabase;

  ArticleRepositoryImpl(this._newsApiService, this._appDatabase);

  @override
  /// Fetches remote headlines and maps models to entities.
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    _log.info('getNewsArticles → calling API '
        '[key=${newsAPIKey.substring(0, 6)}… country=$countryQuery category=$categoryQuery]');
    try {
      final httpResponse = await _newsApiService.getNewsArticles(
        apiKey: newsAPIKey,
        country: countryQuery,
        category: categoryQuery,
      );

      final statusCode = httpResponse.response.statusCode;
      _log.info('getNewsArticles → HTTP $statusCode');

      if (statusCode == HttpStatus.ok) {
        final articles = httpResponse.data.articles ?? [];
        _log.info('getNewsArticles → success, ${articles.length} articles received');
        return DataSuccess(
          _withLocalIds(articles).map((m) => m.toEntity()).toList(),
        );
      } else {
        _log.warning('getNewsArticles → non-200 response: '
            '$statusCode ${httpResponse.response.statusMessage}');
        return DataDioFailed(
          DioException(
            error: httpResponse.response.statusMessage,
            response: httpResponse.response,
            type: DioExceptionType.badResponse,
            requestOptions: httpResponse.response.requestOptions,
          ),
        );
      }
    } on DioException catch (e) {
      _log.severe('getNewsArticles → DioException '
          '[type=${e.type} status=${e.response?.statusCode}]', e);
      return DataDioFailed(e);
    } catch (e, st) {
      _log.severe('getNewsArticles → unexpected error', e, st);
      return DataGenericFailed(e.toString());
    }
  }

  /// Public-API articles carry no id, which leaves offline rows
  /// unidentifiable (delete matched the first NULL-id row, or crashed).
  /// Assign a random local id to every model missing one.
  List<ArticleModel> _withLocalIds(List<ArticleModel> models) {
    var index = 0;
    return models.map((m) {
      if (m.id?.isNotEmpty == true) return m;
      return m.copyWith(id: _newLocalId(index++));
    }).toList();
  }

  String _newLocalId(int index) =>
      'local-${DateTime.now().microsecondsSinceEpoch}-$index-${Random().nextInt(1 << 32)}';

  @override
  /// Returns locally saved articles mapped to entities.
  Future<List<ArticleEntity>> getSavedArticles() async {
    _log.fine('getSavedArticles → querying local DB');
    final rows = await _appDatabase.articleDao.getArticles();
    _log.fine('getSavedArticles → ${rows.length} rows returned');
    return rows
        .map((row) => ArticleLocalMapper.fromRow(row).toEntity())
        .toList();
  }

  @override
  /// Removes [article] from local storage by identity match.
  Future<void> removeArticle(ArticleEntity article) async {
    _log.fine('removeArticle → id=${article.id} title="${article.title}"');
    final rows = await _appDatabase.articleDao.getArticles();
    final match = rows.firstWhere(
      (r) => _isSameArticle(r, article),
      orElse: () => throw Exception(
          'Article not found: id=${article.id} title="${article.title}"'),
    );
    return _appDatabase.articleDao.deleteArticle(match);
  }

  /// Identity for offline rows, shared with [ArticleEntity.isSameArticle]:
  /// stable `id` match, otherwise the title+date natural key (covers
  /// legacy NULL-id rows and re-fetched API articles with fresh `local-`
  /// ids).
  bool _isSameArticle(ArticlesTableData row, ArticleEntity article) {
    return ArticleLocalMapper.fromRow(row).toEntity().isSameArticle(article);
  }

  @override
  /// Saves [article] locally, skipping duplicates by identity.
  Future<void> saveArticle(ArticleEntity article) async {
    _log.fine('saveArticle → id=${article.id} title="${article.title}"');
    final rows = await _appDatabase.articleDao.getArticles();
    if (rows.any((row) => _isSameArticle(row, article))) {
      _log.fine('saveArticle → duplicate, skipping insert');
      return;
    }
    return _appDatabase.articleDao.insertArticle(
        ArticleLocalMapper.toCompanion(ArticleModel.fromEntity(article)));
  }
}
