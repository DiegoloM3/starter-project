import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/app_database.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/local/saved_article_record.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/models/article.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';

import '../data_sources/remote/news_headlines_service.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsHeadlinesService _newsHeadlinesService;
  final AppDatabase _appDatabase;
  ArticleRepositoryImpl(this._newsHeadlinesService,this._appDatabase);

  @override
  Future<DataState<List<ArticleEntity>>> getNewsArticles() async {
    try {
      final articles = await _newsHeadlinesService.getTopHeadlines();
      return DataSuccess(articles.map((article) => article.toEntity()).toList());
    } on Exception catch (exception) {
      return DataFailed(exception);
    }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async {
    final records = await _appDatabase.articleDAO.getArticles();
    return records.map((record) => record.toModel().toEntity()).toList();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.deleteArticle(_buildRecord(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _appDatabase.articleDAO.insertArticle(_buildRecord(article));
  }

  SavedArticleRecord _buildRecord(ArticleEntity article) {
    return SavedArticleRecord.fromModel(ArticleModel.fromEntity(article));
  }

}
