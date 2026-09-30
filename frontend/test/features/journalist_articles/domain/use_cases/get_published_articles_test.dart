import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/entities/published_article.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/params/get_published_articles_params.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/repository/published_article_repository.dart';
import 'package:news_app_clean_architecture/features/journalist_articles/domain/use_cases/get_published_articles.dart';

class MockPublishedArticleRepository extends Mock implements PublishedArticleRepository {}

final article = PublishedArticleEntity(
  id: 'article-1',
  title: 'Title',
  content: 'Content',
  description: 'Content',
  author: 'Author',
  thumbnailUrl: 'https://example.com/1.jpg',
  publishedAt: DateTime.utc(2026, 9, 28),
);

void main() {
  late MockPublishedArticleRepository repository;
  late GetPublishedArticlesUseCase getPublishedArticles;

  setUpAll(() => registerFallbackValue(const GetPublishedArticlesParams()));

  setUp(() {
    repository = MockPublishedArticleRepository();
    getPublishedArticles = GetPublishedArticlesUseCase(repository);
    when(() => repository.getPublishedArticles(any())).thenAnswer((_) async => DataSuccess([article]));
  });

  test('returns the page the repository found', () async {
    final params = GetPublishedArticlesParams(pageSize: 5, startAfter: article);

    final page = await getPublishedArticles(params: params);

    expect(page.data, [article]);
    verify(() => repository.getPublishedArticles(params)).called(1);
  });

  test('asks for the first default page when no params are given', () async {
    await getPublishedArticles();

    final params = verify(() => repository.getPublishedArticles(captureAny())).captured.single
        as GetPublishedArticlesParams;
    expect(params.pageSize, GetPublishedArticlesParams.defaultPageSize);
    expect(params.startAfter, isNull);
  });
}
