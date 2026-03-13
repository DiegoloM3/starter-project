import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_cubit.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/bloc/article_editor/article_editor_state.dart';

import '../../../../mocks/mocks.dart';
import '../../../../fixtures/test_fixtures.dart';

void main() {
  late ArticleEditorCubit cubit;
  late MockCreateArticleUseCase mockCreateArticleUseCase;
  late MockUpdateArticleUseCase mockUpdateArticleUseCase;
  late MockPublishArticleUseCase mockPublishArticleUseCase;
  late MockUploadImageUseCase mockUploadImageUseCase;

  setUp(() {
    mockCreateArticleUseCase = MockCreateArticleUseCase();
    mockUpdateArticleUseCase = MockUpdateArticleUseCase();
    mockPublishArticleUseCase = MockPublishArticleUseCase();
    mockUploadImageUseCase = MockUploadImageUseCase();

    cubit = ArticleEditorCubit(
      createArticleUseCase: mockCreateArticleUseCase,
      updateArticleUseCase: mockUpdateArticleUseCase,
      publishArticleUseCase: mockPublishArticleUseCase,
      uploadImageUseCase: mockUploadImageUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  final testArticle = TestFixtures.testArticle;

  group('ArticleEditorCubit', () {
    test('initial state has initial status', () {
      expect(cubit.state.status, ArticleEditorStatus.initial);
      expect(cubit.state.isDraft, true);
    });

    group('initNewArticle', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'sets status to editing and isDraft to true',
        build: () => cubit,
        act: (cubit) => cubit.initNewArticle(),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.editing &&
              state.isDraft == true),
        ],
      );
    });

    group('initWithArticle', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'populates state from existing article',
        build: () => cubit,
        act: (cubit) => cubit.initWithArticle(testArticle),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.id == testArticle.id &&
              state.title == testArticle.title &&
              state.content == testArticle.content &&
              state.status == ArticleEditorStatus.editing &&
              state.isEditing == true),
        ],
      );
    });

    group('updateTitle', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'updates title and sets status to editing',
        build: () => cubit,
        act: (cubit) => cubit.updateTitle('New Title'),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.title == 'New Title' &&
              state.status == ArticleEditorStatus.editing),
        ],
      );
    });

    group('updateContent', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'updates content and calculates word count',
        build: () => cubit,
        act: (cubit) => cubit.updateContent('Hello world three words'),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.content == 'Hello world three words' &&
              state.wordCount == 4 &&
              state.status == ArticleEditorStatus.editing),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'handles empty content correctly',
        build: () => cubit,
        act: (cubit) => cubit.updateContent(''),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.content == '' && state.wordCount == 0),
        ],
      );
    });

    group('setLocalImage', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'sets local image path',
        build: () => cubit,
        act: (cubit) => cubit.setLocalImage('/path/to/image.jpg'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.localImagePath == '/path/to/image.jpg'),
        ],
      );
    });

    group('addCategory', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'adds category to list',
        build: () => cubit,
        act: (cubit) => cubit.addCategory('tech'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.categories.contains('tech')),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'does not add duplicate category',
        build: () => cubit,
        seed: () => const ArticleEditorState(categories: ['tech']),
        act: (cubit) => cubit.addCategory('tech'),
        expect: () => [], // No state change
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'shows error when max categories reached',
        build: () => cubit,
        seed: () =>
            const ArticleEditorState(categories: ['a', 'b', 'c', 'd', 'e']),
        act: (cubit) => cubit.addCategory('sixth'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.errorMessage == 'Maximum 5 tags allowed'),
        ],
      );
    });

    group('removeCategory', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'removes category from list',
        build: () => cubit,
        seed: () => const ArticleEditorState(categories: ['tech', 'news']),
        act: (cubit) => cubit.removeCategory('tech'),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              !state.categories.contains('tech') &&
              state.categories.contains('news')),
        ],
      );
    });

    group('uploadCoverImage', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'does nothing when no local image path',
        build: () => cubit,
        act: (cubit) => cubit.uploadCoverImage(),
        expect: () => [], // No state change
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'emits uploading then editing with url on success',
        build: () {
          when(mockUploadImageUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => const DataSuccess('https://image.url'));
          return cubit;
        },
        seed: () =>
            const ArticleEditorState(localImagePath: '/path/to/image.jpg'),
        act: (cubit) => cubit.uploadCoverImage(),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.uploading),
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.editing &&
              state.coverImageUrl == 'https://image.url' &&
              state.localImagePath == null),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'emits uploading then error on failure',
        build: () {
          when(mockUploadImageUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataFailed(Exception('Upload failed')));
          return cubit;
        },
        seed: () =>
            const ArticleEditorState(localImagePath: '/path/to/image.jpg'),
        act: (cubit) => cubit.uploadCoverImage(),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.uploading),
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.error),
        ],
      );
    });

    group('saveDraft', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'shows error when title is empty',
        build: () => cubit,
        seed: () =>
            const ArticleEditorState(status: ArticleEditorStatus.editing),
        act: (cubit) =>
            cubit.saveDraft(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.error &&
              state.errorMessage?.contains('title') == true),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'creates new article when not editing',
        build: () {
          when(mockCreateArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticle));
          return cubit;
        },
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          title: 'Test Title',
          content: 'Test content',
        ),
        act: (cubit) =>
            cubit.saveDraft(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.saving),
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.success &&
              state.successMessage?.contains('saved') == true),
        ],
        verify: (_) {
          verify(mockCreateArticleUseCase.call(params: anyNamed('params')))
              .called(1);
        },
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'updates existing article when editing',
        build: () {
          when(mockUpdateArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticle));
          return cubit;
        },
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          id: 'existing-id',
          title: 'Test Title',
          content: 'Test content',
          isEditing: true,
        ),
        act: (cubit) =>
            cubit.saveDraft(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.saving),
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.success),
        ],
        verify: (_) {
          verify(mockUpdateArticleUseCase.call(params: anyNamed('params')))
              .called(1);
        },
      );
    });

    group('publishArticle', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'shows error when missing required fields',
        build: () => cubit,
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          title: 'Title only', // missing content and image
        ),
        act: (cubit) =>
            cubit.publishArticle(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.error &&
              state.errorMessage != null),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'creates and publishes new article',
        build: () {
          when(mockCreateArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticle));
          return cubit;
        },
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          title: 'Test Title',
          content: 'Test content',
          coverImageUrl: 'https://image.url',
        ),
        act: (cubit) =>
            cubit.publishArticle(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.publishing),
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.success &&
              state.successMessage?.contains('published') == true),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'updates and publishes existing article',
        build: () {
          when(mockUpdateArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async => DataSuccess(testArticle));
          when(mockPublishArticleUseCase.call(params: anyNamed('params')))
              .thenAnswer((_) async =>
                  DataSuccess(testArticle.copyWith(isDraft: false)));
          return cubit;
        },
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          id: 'existing-id',
          title: 'Test Title',
          content: 'Test content',
          coverImageUrl: 'https://image.url',
          isEditing: true,
        ),
        act: (cubit) =>
            cubit.publishArticle(authorId: 'user123', authorName: 'John'),
        expect: () => [
          predicate<ArticleEditorState>(
              (state) => state.status == ArticleEditorStatus.publishing),
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.success &&
              state.isDraft == false),
        ],
        verify: (_) {
          verify(mockUpdateArticleUseCase.call(params: anyNamed('params')))
              .called(1);
          verify(mockPublishArticleUseCase.call(params: 'existing-id'))
              .called(1);
        },
      );
    });

    group('utility methods', () {
      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'clearError clears error message',
        build: () => cubit,
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.error,
          errorMessage: 'Some error',
        ),
        act: (cubit) => cubit.clearError(),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.errorMessage == null &&
              state.status == ArticleEditorStatus.editing),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'clearSuccess clears success message',
        build: () => cubit,
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.success,
          successMessage: 'Success!',
        ),
        act: (cubit) => cubit.clearSuccess(),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.successMessage == null &&
              state.status == ArticleEditorStatus.editing),
        ],
      );

      blocTest<ArticleEditorCubit, ArticleEditorState>(
        'reset returns to initial state',
        build: () => cubit,
        seed: () => const ArticleEditorState(
          status: ArticleEditorStatus.editing,
          title: 'Some title',
          content: 'Some content',
        ),
        act: (cubit) => cubit.reset(),
        expect: () => [
          predicate<ArticleEditorState>((state) =>
              state.status == ArticleEditorStatus.initial &&
              state.title == '' &&
              state.content == ''),
        ],
      );
    });

    group('ArticleEditorState', () {
      test('isValidForPublish requires title and content (image optional)', () {
        const state = ArticleEditorState(
          title: 'Title',
          content: 'Content',
          coverImageUrl: 'https://image.url',
        );
        expect(state.isValidForPublish, true);

        // Image is optional - should still be valid without image
        const stateNoImage = ArticleEditorState(
          title: 'Title',
          content: 'Content',
        );
        expect(stateNoImage.isValidForPublish, true);

        // Missing title should be invalid
        const stateNoTitle = ArticleEditorState(
          content: 'Content',
        );
        expect(stateNoTitle.isValidForPublish, false);

        // Missing content should be invalid
        const stateNoContent = ArticleEditorState(
          title: 'Title',
        );
        expect(stateNoContent.isValidForPublish, false);
      });

      test('isValidForDraft only requires title', () {
        const state = ArticleEditorState(title: 'Title');
        expect(state.isValidForDraft, true);

        const stateEmpty = ArticleEditorState();
        expect(stateEmpty.isValidForDraft, false);
      });

      test('readingTimeMinutes calculates correctly', () {
        const state = ArticleEditorState(wordCount: 200);
        expect(state.readingTimeMinutes, 1);

        const stateMore = ArticleEditorState(wordCount: 450);
        expect(stateMore.readingTimeMinutes, 3); // ceil(450/200) = 3
      });
    });
  });
}
