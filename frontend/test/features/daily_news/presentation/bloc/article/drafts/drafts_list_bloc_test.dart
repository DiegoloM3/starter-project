import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_bloc.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_event.dart';
import 'package:news_app_clean_architecture/features/daily_news/presentation/bloc/article/drafts/drafts_list_state.dart';

import '../../../../../../helpers/mock_classes.dart';
import '../../../../../../helpers/test_fixtures.dart';

void main() {
  late DraftsListBloc bloc;
  late MockGetDraftArticlesUseCase mockGetDrafts;
  late MockDeleteArticleUseCase mockDelete;

  setUp(() {
    mockGetDrafts = MockGetDraftArticlesUseCase();
    mockDelete = MockDeleteArticleUseCase();
    bloc = DraftsListBloc(mockGetDrafts, mockDelete);
  });

  tearDown(() => bloc.close());

  group('initial state', () {
    test('is DraftsListLoading', () {
      expect(bloc.state, isA<DraftsListLoading>());
    });
  });

  group('DraftsSubscriptionRequested', () {
    test('emits [Loading, Done] with articles on DataSuccess', () async {
      final articles = testArticleList();
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetDrafts(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <DraftsListState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DraftsSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(DataSuccess(articles));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<DraftsListLoading>());
      expect(states[1], isA<DraftsListDone>());
      expect((states[1] as DraftsListDone).articles!.length, 3);

      verify(() => mockGetDrafts(params: tUserId)).called(1);

      await sub.cancel();
      await controller.close();
    });

    test('emits [Loading, Failure] on DataFailed', () async {
      const error = NetworkException(message: 'fail', code: 'err');
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetDrafts(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <DraftsListState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DraftsSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(const DataFailed(error));
      await Future.delayed(Duration.zero);

      expect(states.length, 2);
      expect(states[0], isA<DraftsListLoading>());
      expect(states[1], isA<DraftsListFailure>());
      expect((states[1] as DraftsListFailure).error, error);

      await sub.cancel();
      await controller.close();
    });

    test('emits Done with empty list when no drafts', () async {
      final controller =
          StreamController<DataState<List<ArticleEntity>>>();
      when(() => mockGetDrafts(params: any(named: 'params')))
          .thenAnswer((_) => controller.stream);

      final states = <DraftsListState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const DraftsSubscriptionRequested(tUserId));
      await Future.delayed(Duration.zero);
      controller.add(const DataSuccess([]));
      await Future.delayed(Duration.zero);

      final done = states.last as DraftsListDone;
      expect(done.articles, isEmpty);

      await sub.cancel();
      await controller.close();
    });
  });

  group('DraftDeleted', () {
    test('calls delete use case on success', () async {
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataSuccess(null));

      bloc.add(const DraftDeleted(tArticleId));
      await Future.delayed(const Duration(milliseconds: 50));

      verify(() => mockDelete(params: tArticleId)).called(1);
    });

    test('emits Failure when delete returns DataFailed', () async {
      const error = AppException(message: 'permission denied', code: 'auth');
      when(() => mockDelete(params: any(named: 'params')))
          .thenAnswer((_) async => const DataFailed(error));

      bloc.add(const DraftDeleted(tArticleId));
      await expectLater(
        bloc.stream,
        emits(isA<DraftsListFailure>()),
      );

      expect((bloc.state as DraftsListFailure).error, error);
    });
  });
}
