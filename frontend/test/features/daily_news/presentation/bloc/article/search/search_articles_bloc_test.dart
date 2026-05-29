import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/search/search_articles_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

/// Slightly longer than the bloc's 300ms SearchQueryChanged debounce so a
/// debounced query has resolved before assertions read the state.
const _pastDebounce = Duration(milliseconds: 350);

void main() {
  late MockGetFeedArticlesUseCase mockUseCase;
  late StreamController<DataState<List<ArticleEntity>>> controller;

  setUp(() {
    mockUseCase = MockGetFeedArticlesUseCase();
    controller = StreamController<DataState<List<ArticleEntity>>>();
    when(() => mockUseCase(params: any(named: 'params')))
        .thenAnswer((_) => controller.stream);
    when(() => mockUseCase())
        .thenAnswer((_) => controller.stream);
  });

  tearDown(() => controller.close());

  group('initial state', () {
    test('is SearchArticlesLoading', () {
      final bloc = SearchArticlesBloc(mockUseCase);
      expect(bloc.state, isA<SearchArticlesLoading>());
      bloc.close();
    });
  });

  group('feed loaded', () {
    test('emits Done with all articles when feed loads', () async {
      final bloc = SearchArticlesBloc(mockUseCase);
      final articles = [
        testArticle(id: '1', title: 'Flutter news'),
        testArticle(id: '2', title: 'Dart update'),
      ];

      controller.add(DataSuccess(articles));
      await expectLater(
        bloc.stream,
        emits(isA<SearchArticlesDone>()),
      );
      expect((bloc.state as SearchArticlesDone).articles!.length, 2);
      await bloc.close();
    });
  });

  group('feed error', () {
    test('emits Failure when feed stream yields DataFailed', () async {
      final bloc = SearchArticlesBloc(mockUseCase);

      controller.add(const DataFailed(
        AppException(message: 'boom', code: 'firestore_error'),
      ));

      await expectLater(
        bloc.stream,
        emits(isA<SearchArticlesFailure>()),
      );
      expect((bloc.state as SearchArticlesFailure).error?.message, 'boom');
      await bloc.close();
    });

    test('emits Failure when feed stream emits a raw error', () async {
      final bloc = SearchArticlesBloc(mockUseCase);

      controller.addError(Exception('stream blew up'));

      await expectLater(
        bloc.stream,
        emits(isA<SearchArticlesFailure>()),
      );
      await bloc.close();
    });
  });

  group('SearchQueryChanged', () {
    test('filters articles by title', () async {
      final bloc = SearchArticlesBloc(mockUseCase);
      final articles = [
        testArticle(id: '1', title: 'Flutter news'),
        testArticle(id: '2', title: 'Dart update'),
        testArticle(id: '3', title: 'Flutter widgets'),
      ];

      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      bloc.add(const SearchQueryChanged('flutter'));
      await expectLater(
        bloc.stream,
        emits(isA<SearchArticlesDone>()),
      );
      final state = bloc.state as SearchArticlesDone;
      expect(state.articles!.length, 2);
      await bloc.close();
    });

    test('returns all articles when query is empty', () async {
      final bloc = SearchArticlesBloc(mockUseCase);
      final articles = testArticleList();

      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      bloc.add(const SearchQueryChanged('something'));
      bloc.add(const SearchQueryChanged(''));
      await Future.delayed(_pastDebounce);

      final state = bloc.state as SearchArticlesDone;
      expect(state.articles!.length, 3);
      await bloc.close();
    });

    test('returns empty list when no match', () async {
      final bloc = SearchArticlesBloc(mockUseCase);
      final articles = testArticleList();

      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      bloc.add(const SearchQueryChanged('nonexistent'));
      await Future.delayed(_pastDebounce);

      final state = bloc.state as SearchArticlesDone;
      expect(state.articles, isEmpty);
      await bloc.close();
    });
  });

  group('close', () {
    test('cancels feed subscription', () async {
      final bloc = SearchArticlesBloc(mockUseCase);
      await bloc.close();
      expect(controller.hasListener, isFalse);
    });
  });
}
