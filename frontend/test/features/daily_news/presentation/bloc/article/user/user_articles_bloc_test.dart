import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/user/user_articles_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late UserArticlesBloc bloc;
  late MockGetUserArticlesUseCase mockGetUser;
  late MockDeleteArticleUseCase mockDelete;

  setUp(() {
    mockGetUser = MockGetUserArticlesUseCase();
    mockDelete = MockDeleteArticleUseCase();
    bloc = UserArticlesBloc(mockGetUser, mockDelete);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is UserArticlesLoading with all filter', () {
      expect(bloc.state, isA<UserArticlesLoading>());
      expect(bloc.state.filter, UserArticlesFilter.all);
    });
  });

  group('UserArticlesSubscriptionRequested', () {
    test('emits [Loading, Done] with articles on DataSuccess', () async {
      final articles = testArticleList();
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetUser(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <UserArticlesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UserArticlesSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<UserArticlesLoading>());
      expect(states[1], isA<UserArticlesDone>());
      expect((states[1] as UserArticlesDone).articles!.length, 3);

      verify(() => mockGetUser(params: tUserId)).called(1);

      await sub.cancel();
      await controller.close();
    });

    test('emits [Loading, Failure] on DataFailed', () async {
      const error = NetworkException(message: 'fail', code: 'err');
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetUser(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <UserArticlesState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const UserArticlesSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(const DataFailed(error));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<UserArticlesLoading>());
      expect(states[1], isA<UserArticlesFailure>());
      expect((states[1] as UserArticlesFailure).error, error);

      await sub.cancel();
      await controller.close();
    });
  });

  group('UserArticlesFilterChanged', () {
    late StreamController<DataState<List<ArticleEntity>>> controller;

    setUp(() {
      controller = StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetUser(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);
    });

    tearDown(() => controller.close());

    Future<void> seedArticlesWithMixedStatuses() async {
      final articles = [
        testArticle(id: '1', status: ArticleStatus.draft),
        testArticle(id: '2', status: ArticleStatus.published),
        testArticle(id: '3', status: ArticleStatus.archived),
        testArticle(id: '4', status: ArticleStatus.draft),
      ];

      bloc.add(const UserArticlesSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles));
      await Future.delayed(const Duration(milliseconds: 50));
    }

    test('filters to drafts only', () async {
      await seedArticlesWithMixedStatuses();

      bloc.add(const UserArticlesFilterChanged(UserArticlesFilter.drafts));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as UserArticlesDone;
      expect(state.filter, UserArticlesFilter.drafts);
      expect(state.articles!.length, 2);
      expect(
        state.articles!.every((a) => a.status == ArticleStatus.draft),
        isTrue,
      );
    });

    test('filters to published only', () async {
      await seedArticlesWithMixedStatuses();

      bloc.add(const UserArticlesFilterChanged(UserArticlesFilter.published));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as UserArticlesDone;
      expect(state.filter, UserArticlesFilter.published);
      expect(state.articles!.length, 1);
      expect(state.articles!.first.status, ArticleStatus.published);
    });

    test('filters to archived only', () async {
      await seedArticlesWithMixedStatuses();

      bloc.add(const UserArticlesFilterChanged(UserArticlesFilter.archived));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as UserArticlesDone;
      expect(state.filter, UserArticlesFilter.archived);
      expect(state.articles!.length, 1);
      expect(state.articles!.first.status, ArticleStatus.archived);
    });

    test('shows all articles with all filter', () async {
      await seedArticlesWithMixedStatuses();

      // Switch to drafts first, then back to all
      bloc.add(const UserArticlesFilterChanged(UserArticlesFilter.drafts));
      await Future.delayed(const Duration(milliseconds: 50));
      bloc.add(const UserArticlesFilterChanged(UserArticlesFilter.all));
      await Future.delayed(const Duration(milliseconds: 50));

      final state = bloc.state as UserArticlesDone;
      expect(state.filter, UserArticlesFilter.all);
      expect(state.articles!.length, 4);
    });
  });

  group('UserArticleDeleteRequested', () {
    test('calls delete use case', () async {
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));

      bloc.add(const UserArticleDeleteRequested(tArticleId));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockDelete(params: tArticleId)).called(1);
    });

    test('emits Failure when delete returns DataFailed', () async {
      const error = AppException(message: 'fail', code: 'err');
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const UserArticleDeleteRequested(tArticleId));
      await expectLater(
        bloc.stream,
        emits(isA<UserArticlesFailure>()),
      );

      expect((bloc.state as UserArticlesFailure).error, error);
    });
  });

  group('close', () {
    test('cancels stream subscription', () async {
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetUser(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      bloc.add(const UserArticlesSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      await bloc.close();

      controller.add(DataSuccess(testArticleList()));
      await controller.close();
    });
  });
}
