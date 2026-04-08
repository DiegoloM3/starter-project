import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/repository/upload_article_repository.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';

class _MockUploadArticleRepository extends Mock implements UploadArticleRepository {}

void main() {
  late _MockUploadArticleRepository repository;
  late UploadArticleUseCase useCase;

  setUp(() {
    repository = _MockUploadArticleRepository();
    useCase = UploadArticleUseCase(repository);
  });

  test('calls repository.uploadArticle and returns DataState', () async {
    const params = UploadArticleEntity(
      author: 'author',
      title: 'title',
      description: 'description text',
      content: 'long content long content long content',
      url: '',
      urlToImage: 'https://image.com/1.jpg',
    );
    const expected = DataSuccess<ArticleEntity>(ArticleEntity(title: 'title'));
    when(() => repository.uploadArticle(params)).thenAnswer((_) async => expected);

    final result = await useCase(params: params);

    expect(result, expected);
    verify(() => repository.uploadArticle(params)).called(1);
  });
}
