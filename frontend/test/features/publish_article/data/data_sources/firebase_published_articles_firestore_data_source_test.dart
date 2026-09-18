import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/firebase_published_articles_firestore_data_source.dart';
import 'package:news_app_clean_architecture/features/publish_article/data/data_sources/publication_data_source_exception.dart';

class FakePublishedArticlesClient implements PublishedArticlesFirestoreClient {
  List<PublishedArticleDocument> documents = const [];
  Object? error;
  int calls = 0;

  @override
  Future<List<PublishedArticleDocument>>
      getArticlesByPublishedAtDescending() async {
    calls += 1;
    if (error != null) throw error!;
    return documents;
  }
}

Map<String, dynamic> rawArticle({required DateTime publishedAt}) => {
      'author': 'Jane Doe',
      'title': 'Published title',
      'description': 'Description',
      'content': 'Content',
      'thumbnailURL': 'https://example.com/image.jpg',
      'publishedAt': Timestamp.fromDate(publishedAt),
      'createdAt': Timestamp.fromDate(DateTime.utc(2026, 9, 18)),
      'updatedAt': Timestamp.fromDate(DateTime.utc(2026, 9, 18)),
    };

void main() {
  test('maps ordered Firestore documents and timestamps', () async {
    final client = FakePublishedArticlesClient()
      ..documents = [
        PublishedArticleDocument(
          id: 'newest',
          data: rawArticle(publishedAt: DateTime.utc(2026, 9, 19)),
        ),
        PublishedArticleDocument(
          id: 'oldest',
          data: rawArticle(publishedAt: DateTime.utc(2026, 9, 18)),
        ),
      ];
    final dataSource =
        FirebasePublishedArticlesFirestoreDataSource.withClient(client);

    final result = await dataSource.getPublishedArticles();

    expect(result.map((article) => article.id), ['newest', 'oldest']);
    expect(result.first.publishedAt.toUtc(), DateTime.utc(2026, 9, 19));
    expect(client.calls, 1);
  });

  test('wraps malformed documents as invalid-data', () async {
    final malformed = rawArticle(publishedAt: DateTime.utc(2026, 9, 18))
      ..['publishedAt'] = 'not-a-timestamp';
    final client = FakePublishedArticlesClient()
      ..documents = [PublishedArticleDocument(id: 'bad', data: malformed)];
    final dataSource =
        FirebasePublishedArticlesFirestoreDataSource.withClient(client);

    await expectLater(
      dataSource.getPublishedArticles(),
      throwsA(isA<PublicationDataSourceException>().having(
        (error) => error.code,
        'code',
        'invalid-data',
      )),
    );
  });

  test('wraps Firebase failures with the list operation', () async {
    final client = FakePublishedArticlesClient()
      ..error = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
      );
    final dataSource =
        FirebasePublishedArticlesFirestoreDataSource.withClient(client);

    await expectLater(
      dataSource.getPublishedArticles(),
      throwsA(isA<PublicationDataSourceException>()
          .having((error) => error.code, 'code', 'unavailable')
          .having(
            (error) => error.operation,
            'operation',
            PublicationDataSourceOperation.listArticles,
          )),
    );
  });
}
