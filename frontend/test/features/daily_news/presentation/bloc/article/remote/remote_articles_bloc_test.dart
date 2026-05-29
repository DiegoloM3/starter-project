import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/remote/remote_article_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late RemoteArticlesBloc bloc;
  late MockGetArticleUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetArticleUseCase();
    bloc = RemoteArticlesBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is RemoteArticlesLoading', () {
      expect(bloc.state, isA<RemoteArticlesLoading>());
    });
  });

  group('RemoteArticlesRequested', () {
    test('emits [Done] with articles when use case returns DataSuccess',
        () async {
      final articles = testArticleList();
      when(() => mockUseCase()).thenAnswer((_) async => DataSuccess(articles));

      bloc.add(const RemoteArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<RemoteArticlesDone>()),
      );

      final state = bloc.state as RemoteArticlesDone;
      expect(state.articles, articles);
      expect(state.articles!.length, 3);
      verify(() => mockUseCase()).called(1);
    });

    test('emits [Error] with exception when use case returns DataFailed',
        () async {
      const error = NetworkException(message: 'No internet', code: 'timeout');
      when(() => mockUseCase())
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const RemoteArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<RemoteArticlesFailure>()),
      );

      final state = bloc.state as RemoteArticlesFailure;
      expect(state.error, error);
      expect(state.error!.message, 'No internet');
      verify(() => mockUseCase()).called(1);
    });

    test('emits [Done] with an empty list on empty DataSuccess', () async {
      when(() => mockUseCase())
          .thenAnswer((_) async => const DataSuccess([]));

      bloc.add(const RemoteArticlesRequested());
      await expectLater(
        bloc.stream,
        emits(isA<RemoteArticlesDone>()),
      );

      final state = bloc.state as RemoteArticlesDone;
      expect(state.articles, isEmpty);
      verify(() => mockUseCase()).called(1);
    });
  });
}
