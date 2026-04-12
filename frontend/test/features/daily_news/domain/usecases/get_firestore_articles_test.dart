import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_firestore_articles.dart';

import '../../fakes/fake_firestore_article_repository.dart';

void main() {
  late FakeFirestoreArticleRepository repository;
  late GetFirestoreArticlesUseCase useCase;

  setUp(() {
    repository = FakeFirestoreArticleRepository();
    useCase = GetFirestoreArticlesUseCase(repository);
  });

  test('returns empty list when no articles exist', () async {
    final result = await useCase();

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data, isEmpty);
  });

  test('returns articles from repository', () async {
    const articles = [
      ArticleEntity(
        documentId: 'doc-1',
        title: 'Article 1',
        section: NewsSection.sports,
      ),
      ArticleEntity(
        documentId: 'doc-2',
        title: 'Article 2',
        section: NewsSection.arts,
      ),
    ];
    repository.getResult = const DataSuccess(articles);

    final result = await useCase();

    expect(result, isA<DataSuccess<List<ArticleEntity>>>());
    expect(result.data?.length, 2);
    expect(result.data?.first.title, 'Article 1');
  });

  test('returns DataFailed when repository fails', () async {
    repository.getResult = const DataFailed(NetworkFailure());

    final result = await useCase();

    expect(result, isA<DataFailed<List<ArticleEntity>>>());
  });
}
