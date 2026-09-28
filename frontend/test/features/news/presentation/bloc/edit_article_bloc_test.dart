import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/entities/article.entity.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/delete_user_article.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/update_user_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/edit/edit_article_bloc.dart';

import 'edit_article_bloc_test.mocks.dart';

@GenerateMocks([UpdateUserArticle, DeleteUserArticle, GetCurrentUserUseCase])
void main() {
  late MockUpdateUserArticle mockUpdateUserArticle;
  late MockDeleteUserArticle mockDeleteUserArticle;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  const tOwnArticle = ArticleEntity(
    id: 'art-1',
    authorDisplayName: 'Jane',
    title: 'Old title',
    urlToImage: 'https://example.com/old.jpg',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Old content',
    authorId: 'user-123',
  );

  const tForeignArticle = ArticleEntity(
    id: 'art-2',
    authorDisplayName: 'John',
    title: 'Someone else',
    publishedAt: '2026-09-27T00:00:00Z',
    content: 'Not mine',
    authorId: 'user-999',
  );

  const tOwner = UserEntity(
    id: 'user-123',
    email: 'jane@example.com',
    displayName: 'Jane',
  );

  EditArticleBloc buildBloc() => EditArticleBloc(
        mockUpdateUserArticle,
        mockDeleteUserArticle,
        mockGetCurrentUserUseCase,
      );

  setUp(() {
    mockUpdateUserArticle = MockUpdateUserArticle();
    mockDeleteUserArticle = MockDeleteUserArticle();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    when(mockGetCurrentUserUseCase.call())
        .thenAnswer((_) async => const DataSuccess(tOwner));
  });

  test('initial state is EditArticleIdle', () {
    final bloc = buildBloc();
    expect(bloc.state, isA<EditArticleIdle>());
    bloc.close();
  });

  group('SaveArticleEdits', () {
    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when title is empty',
      build: buildBloc,
      act: (bloc) => bloc.add(const SaveArticleEdits(
        original: tOwnArticle,
        title: '  ',
        content: 'New content',
      )),
      expect: () => [
        const EditArticleError('Title cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockUpdateUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when content is empty',
      build: buildBloc,
      act: (bloc) => bloc.add(const SaveArticleEdits(
        original: tOwnArticle,
        title: 'New title',
        content: '',
      )),
      expect: () => [
        const EditArticleError('Content cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockUpdateUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when the user is logged out',
      build: () {
        when(mockGetCurrentUserUseCase.call())
            .thenAnswer((_) async => DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SaveArticleEdits(
        original: tOwnArticle,
        title: 'New title',
        content: 'New content',
      )),
      expect: () => [
        const EditArticleError('Please log in to edit your article.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockUpdateUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when the article belongs to another user',
      build: buildBloc,
      act: (bloc) => bloc.add(const SaveArticleEdits(
        original: tForeignArticle,
        title: 'New title',
        content: 'New content',
      )),
      expect: () => [
        const EditArticleError('You can only edit your own articles.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockUpdateUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleLoading, EditArticleSaved] and preserves identity when update succeeds',
      build: () {
        when(mockUpdateUserArticle(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(SaveArticleEdits(
        original: tOwnArticle,
        title: '  New title  ',
        content: '  New content.  ',
        imageFile: File('path/to/img.png'),
      )),
      expect: () => [
        const EditArticleLoading(),
        const EditArticleSaved(),
      ],
      verify: (_) {
        final captured = verify(mockUpdateUserArticle(
          params: captureAnyNamed('params'),
        )).captured.single as UpdateUserArticleParams;

        expect(captured.article.id, 'art-1');
        expect(captured.article.authorId, 'user-123');
        expect(captured.article.authorDisplayName, 'Jane');
        expect(captured.article.publishedAt, '2026-09-27T00:00:00Z');
        expect(captured.article.title, 'New title');
        expect(captured.article.content, 'New content.');
        expect(captured.imageFile?.path, 'path/to/img.png');
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleLoading, EditArticleError] when usecase fails',
      build: () {
        when(mockUpdateUserArticle(params: anyNamed('params'))).thenAnswer(
            (_) async => const DataGenericFailed('Update failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const SaveArticleEdits(
        original: tOwnArticle,
        title: 'New title',
        content: 'New content',
      )),
      expect: () => [
        const EditArticleLoading(),
        const EditArticleError('Update failed'),
      ],
    );
  });

  group('DeleteArticleRequested', () {
    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when the article has no id',
      build: buildBloc,
      act: (bloc) => bloc.add(const DeleteArticleRequested(
        ArticleEntity(
          authorDisplayName: 'Jane',
          title: 'No id',
          publishedAt: '2026-09-27T00:00:00Z',
          content: 'No id',
          authorId: 'user-123',
        ),
      )),
      expect: () => [
        const EditArticleError('Cannot delete an article without an id.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockDeleteUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when the user is logged out',
      build: () {
        when(mockGetCurrentUserUseCase.call())
            .thenAnswer((_) async => DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteArticleRequested(tOwnArticle)),
      expect: () => [
        const EditArticleError('Please log in to delete your article.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockDeleteUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleError] when the article belongs to another user',
      build: buildBloc,
      act: (bloc) => bloc.add(const DeleteArticleRequested(tForeignArticle)),
      expect: () => [
        const EditArticleError('You can only delete your own articles.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockDeleteUserArticle);
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleLoading, EditArticleDeleted] when delete succeeds',
      build: () {
        when(mockDeleteUserArticle(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteArticleRequested(tOwnArticle)),
      expect: () => [
        const EditArticleLoading(),
        const EditArticleDeleted(),
      ],
      verify: (_) {
        final captured = verify(mockDeleteUserArticle(
          params: captureAnyNamed('params'),
        )).captured.single as DeleteUserArticleParams;

        expect(captured.articleId, 'art-1');
      },
    );

    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleLoading, EditArticleError] when usecase fails',
      build: () {
        when(mockDeleteUserArticle(params: anyNamed('params'))).thenAnswer(
            (_) async => const DataGenericFailed('Delete failed'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const DeleteArticleRequested(tOwnArticle)),
      expect: () => [
        const EditArticleLoading(),
        const EditArticleError('Delete failed'),
      ],
    );
  });

  group('ResetEditArticle', () {
    blocTest<EditArticleBloc, EditArticleState>(
      'emits [EditArticleIdle] when ResetEditArticle is added',
      build: buildBloc,
      seed: () => const EditArticleError('Some previous error'),
      act: (bloc) => bloc.add(const ResetEditArticle()),
      expect: () => [
        const EditArticleIdle(),
      ],
    );
  });
}
