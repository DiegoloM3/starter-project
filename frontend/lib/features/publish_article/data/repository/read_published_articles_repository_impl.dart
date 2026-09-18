import '../../domain/entities/publishable_article.dart';
import '../../domain/repository/read_published_articles_repository.dart';
import '../data_sources/published_articles_firestore_data_source.dart';

class ReadPublishedArticlesRepositoryImpl
    implements ReadPublishedArticlesRepository {
  final PublishedArticlesFirestoreDataSource _dataSource;

  ReadPublishedArticlesRepositoryImpl(this._dataSource);

  @override
  Future<List<PublishableArticle>> getPublishedArticles() async {
    final models = await _dataSource.getPublishedArticles();
    return models.map((model) => model.toEntity()).toList(growable: false);
  }
}
