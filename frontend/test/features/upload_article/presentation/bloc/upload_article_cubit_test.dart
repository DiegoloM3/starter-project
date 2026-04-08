import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/entities/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/upload_article.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/upload_article_state.dart';

class _MockUploadArticleUseCase extends Mock implements UploadArticleUseCase {}

void main() {
  late _MockUploadArticleUseCase useCase;
  const uploadEntity = UploadArticleEntity(
    author: 'a',
    title: 'title',
    description: 'desc 123456789',
    content: 'content content content content',
    url: '',
    urlToImage: 'https://image.com/1.jpg',
  );

  setUp(() {
    useCase = _MockUploadArticleUseCase();
  });

  test('emits loading then success on successful upload', () async {
    when(() => useCase(params: uploadEntity)).thenAnswer(
      (_) async => const DataSuccess<ArticleEntity>(ArticleEntity(title: 'title')),
    );
    final cubit = UploadArticleCubit(useCase);

    expectLater(
      cubit.stream,
      emitsInOrder(
        <Object>[
          const UploadArticleLoading(),
          const UploadArticleSuccess(ArticleEntity(title: 'title')),
        ],
      ),
    );

    await cubit.upload(uploadEntity);
    await cubit.close();
  });
}
