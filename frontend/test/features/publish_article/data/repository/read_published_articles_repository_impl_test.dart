import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/published_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/models/publishable_article_model.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/repository/read_published_articles_repository_impl.dart';

class FakePublishedArticlesDataSource
    implements PublishedArticlesFirestoreDataSource {
  List<PublishableArticleModel> models = const [];
  Object? error;

  @override
  Future<List<PublishableArticleModel>> getPublishedArticles() async {
    if (error != null) throw error!;
    return models;
  }
}

PublishableArticleModel model(String id) => PublishableArticleModel(
      id: id,
      author: 'Jane Doe',
      title: 'Title $id',
      description: 'Description',
      content: 'Content',
      thumbnailUrl: 'https://example.com/$id.jpg',
      publishedAt: DateTime.utc(2026, 9, 18),
      createdAt: DateTime.utc(2026, 9, 18),
      updatedAt: DateTime.utc(2026, 9, 18),
    );

void main() {
  test('returns independent domain entities in datasource order', () async {
    final dataSource = FakePublishedArticlesDataSource()
      ..models = [model('newest'), model('oldest')];
    final repository = ReadPublishedArticlesRepositoryImpl(dataSource);

    final result = await repository.getPublishedArticles();

    expect(result.map((article) => article.id), ['newest', 'oldest']);
    expect(identical(result.first, dataSource.models.first), isFalse);
  });

  test('propagates datasource failures', () async {
    final dataSource = FakePublishedArticlesDataSource()
      ..error = StateError('unavailable');
    final repository = ReadPublishedArticlesRepositoryImpl(dataSource);

    await expectLater(
      repository.getPublishedArticles(),
      throwsA(isA<StateError>()),
    );
  });
}
