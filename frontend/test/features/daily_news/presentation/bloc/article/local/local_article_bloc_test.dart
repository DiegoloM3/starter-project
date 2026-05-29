import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/local/local_article_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/register_fallback_values.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late LocalArticleBloc bloc;
  late MockGetSavedArticleUseCase mockGetSaved;
  late MockSaveArticleUseCase mockSave;
  late MockRemoveArticleUseCase mockRemove;

  setUpAll(() => registerTestFallbackValues());

  setUp(() {
    mockGetSaved = MockGetSavedArticleUseCase();
    mockSave = MockSaveArticleUseCase();
    mockRemove = MockRemoveArticleUseCase();
    bloc = LocalArticleBloc(mockGetSaved, mockSave, mockRemove);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is LocalArticlesLoading', () {
      expect(bloc.state, isA<LocalArticlesLoading>());
    });
  });

  group('SavedArticlesRequested', () {
    test('emits Done with articles on success', () async {
      final articles = testArticleList();
      when(() => mockGetSaved()).thenAnswer((_) async => DataSuccess(articles));

      bloc.add(const SavedArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles!.length, 3);
      verify(() => mockGetSaved()).called(1);
    });

    test('emits Done with empty list when no saved articles', () async {
      when(() => mockGetSaved())
          .thenAnswer((_) async => const DataSuccess([]));

      bloc.add(const SavedArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles, isEmpty);
    });

    test('emits Failure when the use case returns DataFailed', () async {
      const error = AppException(message: 'db error', code: 'db');
      when(() => mockGetSaved())
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const SavedArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesFailure>()),
      );

      final state = bloc.state as LocalArticlesFailure;
      expect(state.error, error);
      verify(() => mockGetSaved()).called(1);
    });
  });

  group('ArticleSaved', () {
    test('saves article then refreshes list', () async {
      final article = testArticle();
      when(() => mockSave(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      when(() => mockGetSaved())
          .thenAnswer((_) async => DataSuccess([article]));

      bloc.add(ArticleSaved(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      verify(() => mockSave(params: any(named: 'params'))).called(1);
      verify(() => mockGetSaved()).called(1);
    });

    test('emits Failure when save returns DataFailed', () async {
      final article = testArticle();
      const error = AppException(message: 'save failed', code: 'db');
      when(() => mockSave(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(ArticleSaved(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesFailure>()),
      );

      final state = bloc.state as LocalArticlesFailure;
      expect(state.error, error);
      verify(() => mockSave(params: any(named: 'params'))).called(1);
      verifyNever(() => mockGetSaved());
    });
  });

  group('ArticleRemoved', () {
    test('removes article then refreshes list', () async {
      final article = testArticle();
      when(() => mockRemove(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));
      when(() => mockGetSaved())
          .thenAnswer((_) async => const DataSuccess([]));

      bloc.add(ArticleRemoved(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesDone>()),
      );

      final state = bloc.state as LocalArticlesDone;
      expect(state.articles, isEmpty);
      verify(() => mockRemove(params: any(named: 'params'))).called(1);
      verify(() => mockGetSaved()).called(1);
    });

    test('emits Failure when remove returns DataFailed', () async {
      final article = testArticle();
      const error = AppException(message: 'remove failed', code: 'db');
      when(() => mockRemove(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(ArticleRemoved(article));
      await expectLater(
        bloc.stream,
        emits(isA<LocalArticlesFailure>()),
      );

      final state = bloc.state as LocalArticlesFailure;
      expect(state.error, error);
      verify(() => mockRemove(params: any(named: 'params'))).called(1);
      verifyNever(() => mockGetSaved());
    });
  });
}
