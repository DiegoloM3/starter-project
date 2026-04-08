import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/get_my_uploaded_articles.dart';

class _MockUploadArticleRepository extends Mock implements UploadArticleRepository {}

void main() {
  late _MockUploadArticleRepository repository;
  late GetMyUploadedArticlesUseCase useCase;

  setUp(() {
    repository = _MockUploadArticleRepository();
    useCase = GetMyUploadedArticlesUseCase(repository);
  });

  test('calls repository.getMyUploadedArticles', () async {
    const expected = DataSuccess<List<ArticleEntity>>(
      <ArticleEntity>[ArticleEntity(title: 'mine')],
    );
    when(() => repository.getMyUploadedArticles())
        .thenAnswer((_) async => expected);

    final result = await useCase();

    expect(result, expected);
    verify(() => repository.getMyUploadedArticles()).called(1);
  });
}
