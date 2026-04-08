import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/upload_article/domain/usecases/get_my_uploaded_articles.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_cubit.dart';
import 'package:news_app_clean_architecture/features/upload_article/presentation/bloc/my_uploaded_articles_state.dart';

class _MockGetMyUploadedArticlesUseCase extends Mock
    implements GetMyUploadedArticlesUseCase {}

void main() {
  late _MockGetMyUploadedArticlesUseCase useCase;

  setUp(() {
    useCase = _MockGetMyUploadedArticlesUseCase();
  });

  test('emits loading then done when data is fetched', () async {
    when(() => useCase()).thenAnswer(
      (_) async =>
          const DataSuccess<List<ArticleEntity>>(<ArticleEntity>[ArticleEntity(title: 'mine')]),
    );
    final cubit = MyUploadedArticlesCubit(useCase);

    expectLater(
      cubit.stream,
      emitsInOrder(
        <Object>[
          const MyUploadedArticlesLoading(),
          const MyUploadedArticlesDone(<ArticleEntity>[ArticleEntity(title: 'mine')]),
        ],
      ),
    );

    await cubit.load();
    await cubit.close();
  });
}
