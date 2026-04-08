import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/data_sources/upload_article_firebase_data_source.dart';
import 'package:news_app_clean_architecture/features/upload_article/data/repository/upload_article_repository_impl.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';

class _MockUploadArticleFirebaseDataSource extends Mock
    implements UploadArticleFirebaseDataSource {}

void main() {
  late _MockUploadArticleFirebaseDataSource dataSource;
  late UploadArticleRepositoryImpl repository;

  const uploadEntity = UploadArticleEntity(
    author: 'author',
    title: 'title',
    description: 'description description',
    content: 'content content content content',
    url: '',
    urlToImage: 'https://image.com/1.jpg',
  );

  setUp(() {
    dataSource = _MockUploadArticleFirebaseDataSource();
    repository = UploadArticleRepositoryImpl(dataSource);
  });

  test('returns DataSuccess when data source upload succeeds', () async {
    const article = ArticleEntity(title: 'title');
    when(() => dataSource.uploadArticle(uploadEntity)).thenAnswer((_) async => article);

    final result = await repository.uploadArticle(uploadEntity);

    expect(result, isA<DataSuccess<ArticleEntity>>());
    verify(() => dataSource.uploadArticle(uploadEntity)).called(1);
  });

  test('returns DataFailed when data source upload throws', () async {
    when(() => dataSource.uploadArticle(uploadEntity)).thenThrow(Exception('boom'));

    final result = await repository.uploadArticle(uploadEntity);

    expect(result, isA<DataFailed<ArticleEntity>>());
  });
}
