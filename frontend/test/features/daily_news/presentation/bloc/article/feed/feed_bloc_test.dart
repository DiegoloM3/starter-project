import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/feed/feed_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late FeedBloc bloc;
  late MockGetFeedArticlesUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockGetFeedArticlesUseCase();
    bloc = FeedBloc(mockUseCase);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is FeedLoading', () {
      expect(bloc.state, isA<FeedLoading>());
    });
  });

  group('FeedSubscriptionRequested', () {
    test('emits [Loading, Done] when stream emits DataSuccess', () async {
      final articles = testArticleList();
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <FeedState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<FeedLoading>());
      expect(states[1], isA<FeedDone>());
      expect((states[1] as FeedDone).articles, articles);

      verify(() => mockUseCase()).called(1);

      await sub.cancel();
      await controller.close();
    });

    test('emits [Loading, Failure] when stream emits DataFailed', () async {
      const error = NetworkException(message: 'no internet', code: 'net');
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <FeedState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(const DataFailed(error));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<FeedLoading>());
      expect(states[1], isA<FeedFailure>());
      expect((states[1] as FeedFailure).error, error);

      await sub.cancel();
      await controller.close();
    });

    test('emits Done with empty list when DataSuccess has no articles',
        () async {
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      final states = <FeedState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);
      controller.add(const DataSuccess([]));
      await Future.delayed(Duration.zero);

      final done = states.last;
      expect(done, isA<FeedDone>());
      expect((done as FeedDone).articles, isEmpty);

      await sub.cancel();
      await controller.close();
    });

    test('cancels previous subscription on re-subscribe', () async {
      final controller1 =
          StreamController<DataState<List<ArticleEntity>>>();
      final controller2 =
          StreamController<DataState<List<ArticleEntity>>>();

      var callCount = 0;
      when(() => mockUseCase()).thenAnswer((_) {
        callCount++;
        return callCount == 1 ? controller1.stream : controller2.stream;
      });

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);

      // First controller events should be ignored after re-subscribe
      final articles2 = testArticleList(count: 2);
      controller2.add(DataSuccess(articles2));
      await Future.delayed(Duration.zero);

      final state = bloc.state;
      expect(state, isA<FeedDone>());
      expect((state as FeedDone).articles!.length, 2);

      await controller1.close();
      await controller2.close();
    });
  });

  group('close', () {
    test('cancels stream subscription', () async {
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockUseCase()).thenAnswer((_) => controller.stream);

      bloc.add(const FeedSubscriptionRequested());
      await Future.delayed(Duration.zero);
      await bloc.close();

      // Controller should not cause errors after bloc is closed
      controller.add(DataSuccess(testArticleList()));
      await controller.close();
    });
  });
}
