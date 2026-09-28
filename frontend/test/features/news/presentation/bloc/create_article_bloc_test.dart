import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:news_app_clean_architecture/features/news/domain/usecases/create_user_article.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/create/create_article_bloc.dart';

import 'create_article_bloc_test.mocks.dart';

class _UnknownDataFailed extends DataState<void> {
  const _UnknownDataFailed();
}

@GenerateMocks([CreateUserArticle, GetCurrentUserUseCase])
void main() {
  late MockCreateUserArticle mockCreateUserArticle;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;

  setUp(() {
    mockCreateUserArticle = MockCreateUserArticle();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();

    when(mockGetCurrentUserUseCase.call())
        .thenAnswer((_) async => DataSuccess(null));
  });

  test('initial state is CreateArticleIdle', () {
    final bloc =
        CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase);
    expect(bloc.state, isA<CreateArticleIdle>());
    bloc.close();
  });

  group('PublishArticle', () {
    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleError] when title is empty',
      build: () =>
          CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase),
      act: (bloc) => bloc.add(const PublishArticle(
        title: '',
        content: 'Some content',
      )),
      expect: () => [
        const CreateArticleError('Title cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockCreateUserArticle);
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleError] when title contains only whitespace',
      build: () =>
          CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase),
      act: (bloc) => bloc.add(const PublishArticle(
        title: '   \n  \t ',
        content: 'Some content',
      )),
      expect: () => [
        const CreateArticleError('Title cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockCreateUserArticle);
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleError] when content is empty',
      build: () =>
          CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase),
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'Valid Title',
        content: '',
      )),
      expect: () => [
        const CreateArticleError('Content cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockCreateUserArticle);
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleError] when content contains only whitespace',
      build: () =>
          CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase),
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'Valid Title',
        content: '   \n\t  ',
      )),
      expect: () => [
        const CreateArticleError('Content cannot be empty.'),
      ],
      verify: (_) {
        verifyZeroInteractions(mockCreateUserArticle);
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleLoading, CreateArticleSuccess] when publish succeeds',
      build: () {
        when(mockCreateUserArticle(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return CreateArticleBloc(
            mockCreateUserArticle, mockGetCurrentUserUseCase);
      },
      act: (bloc) => bloc.add(PublishArticle(
        title: '  My New Article  ',
        content: '  This is the article content.  ',
        imageFile: File('path/to/img.png'),
      )),
      expect: () => [
        const CreateArticleLoading(),
        const CreateArticleSuccess(),
      ],
      verify: (_) {
        final captured = verify(mockCreateUserArticle(
          params: captureAnyNamed('params'),
        )).captured.single as CreateUserArticleParams;

        expect(captured.article.title, 'My New Article');
        expect(captured.article.content, 'This is the article content.');
        expect(captured.article.authorDisplayName, 'Anonymous');
        expect(captured.article.publishedAt, isNotEmpty);
        expect(captured.imageFile?.path, 'path/to/img.png');
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'falls back to Anonymous when the user has no display name',
      build: () {
        when(mockGetCurrentUserUseCase.call()).thenAnswer(
          (_) async => const DataSuccess(
            UserEntity(
              id: 'user-123',
              email: 'jane@example.com',
            ),
          ),
        );
        when(mockCreateUserArticle(params: anyNamed('params')))
            .thenAnswer((_) async => const DataSuccess(null));
        return CreateArticleBloc(
            mockCreateUserArticle, mockGetCurrentUserUseCase);
      },
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'My Title',
        content: 'My Content',
      )),
      expect: () => [
        const CreateArticleLoading(),
        const CreateArticleSuccess(),
      ],
      verify: (_) {
        final captured = verify(mockCreateUserArticle(
          params: captureAnyNamed('params'),
        )).captured.single as CreateUserArticleParams;

        expect(captured.article.authorDisplayName, 'Anonymous');
      },
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleLoading, CreateArticleError] when usecase returns DataGenericFailed',
      build: () {
        when(mockCreateUserArticle(params: anyNamed('params'))).thenAnswer(
            (_) async => const DataGenericFailed('Network error occurred'));
        return CreateArticleBloc(
            mockCreateUserArticle, mockGetCurrentUserUseCase);
      },
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'My Title',
        content: 'My Content',
      )),
      expect: () => [
        const CreateArticleLoading(),
        const CreateArticleError('Network error occurred'),
      ],
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleLoading, CreateArticleError] when usecase returns DataDioFailed',
      build: () {
        when(mockCreateUserArticle(params: anyNamed('params'))).thenAnswer(
          (_) async => DataDioFailed(DioException(
            requestOptions: RequestOptions(path: '/'),
            error: 'Connection timeout',
          )),
        );
        return CreateArticleBloc(
            mockCreateUserArticle, mockGetCurrentUserUseCase);
      },
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'My Title',
        content: 'My Content',
      )),
      expect: () => [
        const CreateArticleLoading(),
        isA<CreateArticleError>().having(
          (e) => e.message,
          'message',
          contains('Connection timeout'),
        ),
      ],
    );

    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleLoading, CreateArticleError] with default error when failure has no message or error',
      build: () {
        when(mockCreateUserArticle(params: anyNamed('params')))
            .thenAnswer((_) async => const _UnknownDataFailed());
        return CreateArticleBloc(
            mockCreateUserArticle, mockGetCurrentUserUseCase);
      },
      act: (bloc) => bloc.add(const PublishArticle(
        title: 'My Title',
        content: 'My Content',
      )),
      expect: () => [
        const CreateArticleLoading(),
        const CreateArticleError('Unknown error.'),
      ],
    );
  });

  group('ResetCreateArticle', () {
    blocTest<CreateArticleBloc, CreateArticleState>(
      'emits [CreateArticleIdle] when ResetCreateArticle is added',
      build: () =>
          CreateArticleBloc(mockCreateUserArticle, mockGetCurrentUserUseCase),
      seed: () => const CreateArticleError('Some previous error'),
      act: (bloc) => bloc.add(const ResetCreateArticle()),
      expect: () => [
        const CreateArticleIdle(),
      ],
    );
  });
}
