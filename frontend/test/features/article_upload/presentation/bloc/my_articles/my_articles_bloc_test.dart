import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_category.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/article_status.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/draft_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/entities/journalist_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/delete_article_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/params/draft_id_params.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_article.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/delete_draft.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_drafts.dart';
import 'package:news_app_clean_architecture/features/article_upload/domain/use_cases/watch_my_articles.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_bloc.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_event.dart';
import 'package:news_app_clean_architecture/features/article_upload/presentation/bloc/my_articles/my_articles_state.dart';

class MockWatchMyArticlesUseCase extends Mock implements WatchMyArticlesUseCase {}

class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}

class MockWatchDraftsUseCase extends Mock implements WatchDraftsUseCase {}

class MockDeleteDraftUseCase extends Mock implements DeleteDraftUseCase {}

JournalistArticleEntity _makeArticle(String id, {String title = 'My Article'}) =>
    JournalistArticleEntity(
      id: id,
      title: title,
      description: 'Desc',
      content: 'Content',
      urlToImage: 'https://example.com/img.jpg',
      publishedAt: DateTime(2024),
      userId: 'uid-me',
      userDisplayName: 'Me',
      source: 'journalist',
      category: ArticleCategory.tech,
      tags: [],
      language: 'en',
      readingTimeMinutes: 1,
      status: ArticleStatus.published,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
      viewCount: 0,
      favoriteCount: 0,
    );

DraftArticleEntity _makeDraft(int id, {String title = 'Draft'}) =>
    DraftArticleEntity(
      id: id,
      title: title,
      description: 'Draft desc',
      content: 'Draft content',
      tags: const [],
      language: 'en',
      lastSavedAt: DateTime(2024),
    );

void main() {
  late MockWatchMyArticlesUseCase watchMyArticlesUseCase;
  late MockDeleteArticleUseCase deleteArticleUseCase;
  late MockWatchDraftsUseCase watchDraftsUseCase;
  late MockDeleteDraftUseCase deleteDraftUseCase;

  setUp(() {
    watchMyArticlesUseCase = MockWatchMyArticlesUseCase();
    deleteArticleUseCase = MockDeleteArticleUseCase();
    watchDraftsUseCase = MockWatchDraftsUseCase();
    deleteDraftUseCase = MockDeleteDraftUseCase();
    registerFallbackValue(const DeleteArticleParams(articleId: ''));
    registerFallbackValue(const DraftIdParams(draftId: 0));
  });

  MyArticlesBloc buildBloc() => MyArticlesBloc(
        watchMyArticlesUseCase,
        deleteArticleUseCase,
        watchDraftsUseCase,
        deleteDraftUseCase,
      );

  group('MyArticlesBloc', () {
    test('initial state is empty', () {
      final bloc = buildBloc();
      expect(bloc.state.articles, isEmpty);
      expect(bloc.state.isLoading, isFalse);
      bloc.close();
    });

    blocTest<MyArticlesBloc, MyArticlesState>(
      'LoadMyArticlesEvent subscribes to stream and emits articles',
      build: () {
        when(() => watchMyArticlesUseCase.call(params: any(named: 'params')))
            .thenAnswer(
                (_) => Stream.value([_makeArticle('a1'), _makeArticle('a2')]));
        return buildBloc();
      },
      act: (b) => b.add(const LoadMyArticlesEvent('uid-me')),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.articles.length, 2);
        expect(b.state.isLoading, isFalse);
      },
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'DeleteArticleRequestedEvent optimistically removes article and succeeds',
      build: () {
        when(() => deleteArticleUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      seed: () => MyArticlesState(
        articles: [_makeArticle('a1'), _makeArticle('a2')],
      ),
      act: (b) => b.add(const DeleteArticleRequestedEvent('a1')),
      expect: () => [
        isA<MyArticlesState>().having(
          (s) => s.pendingDeletes.contains('a1'),
          'a1 pending',
          true,
        ),
        isA<MyArticlesState>().having(
          (s) => s.articles.any((a) => a.id == 'a1'),
          'a1 removed',
          false,
        ),
      ],
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'DeleteArticleRequestedEvent rolls back on failure',
      build: () {
        when(() => deleteArticleUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataFailed(
                  const FirestoreException(message: 'delete failed'),
                ));
        return buildBloc();
      },
      seed: () => MyArticlesState(
        articles: [_makeArticle('a1'), _makeArticle('a2')],
      ),
      act: (b) => b.add(const DeleteArticleRequestedEvent('a1')),
      expect: () => [
        isA<MyArticlesState>().having(
          (s) => s.pendingDeletes.contains('a1'),
          'a1 pending',
          true,
        ),
        isA<MyArticlesState>()
            .having((s) => s.articles.any((a) => a.id == 'a1'), 'a1 restored', true)
            .having((s) => s.error, 'error', isA<FirestoreException>()),
      ],
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'LoadDraftsEvent subscribes to draft stream and emits updated drafts',
      build: () {
        when(() => watchDraftsUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) => Stream.value([_makeDraft(1), _makeDraft(2)]));
        return buildBloc();
      },
      act: (b) => b.add(const LoadDraftsEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.drafts.length, equals(2));
        expect(b.state.drafts.first.id, equals(1));
      },
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'LoadDraftsEvent on stream error emits DraftsFailedEvent',
      build: () {
        when(() => watchDraftsUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) => Stream.error(
                  const FirestoreException(message: 'db error'),
                ));
        return buildBloc();
      },
      act: (b) => b.add(const LoadDraftsEvent()),
      wait: const Duration(milliseconds: 50),
      verify: (b) {
        expect(b.state.error, isA<FirestoreException>());
      },
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'DeleteDraftRequestedEvent removes draft optimistically and succeeds',
      build: () {
        when(() => deleteDraftUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      seed: () => MyArticlesState(
        drafts: [_makeDraft(1), _makeDraft(2)],
      ),
      act: (b) => b.add(const DeleteDraftRequestedEvent(1)),
      expect: () => [
        isA<MyArticlesState>().having(
          (s) => s.drafts.any((d) => d.id == 1),
          'draft 1 removed',
          false,
        ),
      ],
    );

    blocTest<MyArticlesBloc, MyArticlesState>(
      'DeleteDraftRequestedEvent rolls back on failure',
      build: () {
        when(() => deleteDraftUseCase.call(params: any(named: 'params')))
            .thenAnswer((_) async => DataFailed(
                  const FirestoreException(message: 'delete failed'),
                ));
        return buildBloc();
      },
      seed: () => MyArticlesState(
        drafts: [_makeDraft(1), _makeDraft(2)],
      ),
      act: (b) => b.add(const DeleteDraftRequestedEvent(1)),
      expect: () => [
        isA<MyArticlesState>().having(
          (s) => s.drafts.any((d) => d.id == 1),
          'draft 1 removed optimistically',
          false,
        ),
        isA<MyArticlesState>()
            .having((s) => s.drafts.any((d) => d.id == 1), 'draft 1 restored', true)
            .having((s) => s.error, 'error set', isA<FirestoreException>()),
      ],
    );
  });
}
