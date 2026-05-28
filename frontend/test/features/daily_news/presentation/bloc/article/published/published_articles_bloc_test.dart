import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/published/published_articles_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late PublishedArticlesBloc bloc;
  late MockGetPublishedArticlesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetPublishedArticlesUseCase();
    bloc = PublishedArticlesBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is PublishedArticlesLoading', () {
      expect(bloc.state, isA<PublishedArticlesLoading>());
    });
  });

  group('PublishedArticlesSubscriptionRequested', () {
    test('emits [Loading, Done] with articles when stream emits DataSuccess',
        () async {
      final articles = testArticleList();
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <PublishedArticlesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PublishedArticlesSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<PublishedArticlesLoading>());
      expect(states[1], isA<PublishedArticlesDone>());

      final done = states[1] as PublishedArticlesDone;
      expect(done.articles, articles);
      expect(done.articles!.length, 3);

      verify(() => mockUseCase()).called(1);

      await sub.cancel();
      await controller.close();
    });

    test('emits [Loading, Failure] with error when stream emits DataFailed',
        () async {
      const error = NetworkException(message: 'fail', code: 'net');
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <PublishedArticlesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PublishedArticlesSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(const DataFailed(error));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<PublishedArticlesLoading>());
      expect(states[1], isA<PublishedArticlesFailure>());
      expect((states[1] as PublishedArticlesFailure).error, error);

      await sub.cancel();
      await controller.close();
    });

    test('handles multiple emissions from stream', () async {
      final articles1 = testArticleList(count: 2);
      final articles2 = testArticleList(count: 5);
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <PublishedArticlesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const PublishedArticlesSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles1));
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles2));
      await Future.delayed(Duration.zero);

      expect(states.length, 3);
      expect((states[1] as PublishedArticlesDone).articles!.length, 2);
      expect((states[2] as PublishedArticlesDone).articles!.length, 5);

      await sub.cancel();
      await controller.close();
    });
  });

  group('close', () {
    test('cancels stream subscription on close', () async {
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      bloc.add(const PublishedArticlesSubscriptionRequested());
      await Future.delayed(Duration.zero);
      await bloc.close();

      controller.add(DataSuccess(testArticleList()));
      await controller.close();
    });
  });
}
