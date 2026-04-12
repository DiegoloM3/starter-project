import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/news_section.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/update_article.dart';

import '../../fakes/fake_firestore_article_repository.dart';

void main() {
  late FakeFirestoreArticleRepository repository;
  late UpdateArticleUseCase useCase;

  setUp(() {
    repository = FakeFirestoreArticleRepository();
    useCase = UpdateArticleUseCase(repository);
  });

  const article = ArticleEntity(
    documentId: 'doc-1',
    title: 'Updated',
    content: 'Updated content',
    section: NewsSection.arts,
    author: 'Author',
  );

  test('returns DataSuccess when repository succeeds', () async {
    final result = await useCase(
      params: const UpdateArticleParams(
        article: article,
        newImagePaths: ['/new/image.jpg'],
        existingImageUrls: ['https://existing.url/img.jpg'],
      ),
    );

    expect(result, isA<DataSuccess<ArticleEntity>>());
    expect(result.data?.title, 'Updated');
  });

  test('returns DataFailed when repository fails', () async {
    repository.updateResult = const DataFailed(ServerFailure());

    final result = await useCase(
      params: const UpdateArticleParams(
        article: article,
        newImagePaths: [],
        existingImageUrls: [],
      ),
    );

    expect(result, isA<DataFailed<ArticleEntity>>());
  });
}
