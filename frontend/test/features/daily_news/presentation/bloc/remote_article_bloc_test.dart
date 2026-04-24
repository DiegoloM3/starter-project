import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/usecases/get_article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

class _MockGetArticleUseCase extends Mock implements GetArticleUseCase {}

void main() {
  late _MockGetArticleUseCase useCase;

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    useCase = _MockGetArticleUseCase();
  });

  group('RemoteArticlesBloc', () {
    const articles = [ArticleEntity(id: 1, title: 'a')];

    blocTest<RemoteArticlesBloc, RemoteArticlesState>(
      'emits done(articles) on a Right result',
      build: () {
        when(() => useCase(any()))
            .thenAnswer((_) async => const Right(articles));
        return RemoteArticlesBloc(useCase);
      },
      act: (bloc) => bloc.add(const GetArticles()),
      expect: () => const [RemoteArticlesDone(articles)],
    );

    blocTest<RemoteArticlesBloc, RemoteArticlesState>(
      'emits error(failure) on a Left result',
      build: () {
        when(() => useCase(any())).thenAnswer(
          (_) async => const Left(AppFailure.network(message: 'boom')),
        );
        return RemoteArticlesBloc(useCase);
      },
      act: (bloc) => bloc.add(const GetArticles()),
      expect: () => const [
        RemoteArticlesError(AppFailure.network(message: 'boom')),
      ],
    );
  });
}
