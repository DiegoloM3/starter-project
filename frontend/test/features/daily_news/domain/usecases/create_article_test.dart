import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/create_article.dart';

import '../../fakes/fake_firestore_article_repository.dart';

void main() {
  late FakeFirestoreArticleRepository repository;
  late CreateArticleUseCase useCase;

  setUp(() {
    repository = FakeFirestoreArticleRepository();
    useCase = CreateArticleUseCase(repository);
  });

  const article = ArticleEntity(
    title: 'Test',
    content: 'Content',
    section: NewsSection.sports,
    author: 'Author',
  );

  test('returns DataSuccess when repository succeeds', () async {
    final result = await useCase(
      params: const CreateArticleParams(
        article: article,
        imagePaths: ['/path/image.jpg'],
      ),
    );

    expect(result, isA<DataSuccess<ArticleEntity>>());
    expect(result.data?.title, 'Test');
  });

  test('returns DataFailed when repository fails', () async {
    repository.createResult = const DataFailed(ServerFailure());

    final result = await useCase(
      params: const CreateArticleParams(
        article: article,
        imagePaths: [],
      ),
    );

    expect(result, isA<DataFailed<ArticleEntity>>());
    expect(result.failure, isA<ServerFailure>());
  });
}
