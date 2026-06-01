import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/articles/domain/params/publish_article_params.dart';
import 'package:tortutip/features/articles/domain/params/upload_article_image_params.dart';
import 'package:tortutip/features/articles/domain/params/update_article_params.dart';
import 'package:tortutip/features/articles/domain/use_cases/publish_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/update_article_use_case.dart';
import 'package:tortutip/features/articles/domain/use_cases/upload_article_image_use_case.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_cubit.dart';
import 'package:tortutip/features/articles/presentation/bloc/create_article/create_article_state.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';

class MockPublishArticleUseCase extends Mock implements PublishArticleUseCase {}

class MockUpdateArticleUseCase extends Mock implements UpdateArticleUseCase {}

class MockUploadArticleImageUseCase extends Mock
    implements UploadArticleImageUseCase {}

class MockGetAllCategoriesUseCase extends Mock
    implements GetAllCategoriesUseCase {}

void main() {
  late CreateArticleCubit cubit;
  late MockPublishArticleUseCase mockPublishArticle;
  late MockUpdateArticleUseCase mockUpdateArticle;
  late MockUploadArticleImageUseCase mockUploadImage;
  late MockGetAllCategoriesUseCase mockGetAllCategories;

  const publishParams = PublishArticleParams(
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Title',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    readTimeMinutes: 1,
  );

  final article = ArticleEntity(
    id: 'art_1',
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Title',
    body: 'Body',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    status: 'published',
    readTimeMinutes: 1,
    saveCount: 0,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockPublishArticle = MockPublishArticleUseCase();
    mockUpdateArticle = MockUpdateArticleUseCase();
    mockUploadImage = MockUploadArticleImageUseCase();
    mockGetAllCategories = MockGetAllCategoriesUseCase();
    cubit = CreateArticleCubit(
      mockPublishArticle,
      mockUpdateArticle,
      mockUploadImage,
      mockGetAllCategories,
    );
    registerFallbackValue(publishParams);
    registerFallbackValue(const UpdateArticleParams(
      articleId: 'art_1',
      categoryId: 'cat_1',
      title: 'Title',
      body: 'Body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      readTimeMinutes: 1,
    ));
    registerFallbackValue(
      UploadArticleImageParams(
        userId: 'user_1',
        imageFile: File('test.jpg'),
        isVertical: true,
      ),
    );
    registerFallbackValue(const NoParams());
  });

  tearDown(() => cubit.close());

  group('CreateArticleCubit.publish', () {
    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_Loading_then_Success_when_publish_succeeds',
      build: () {
        when(() => mockPublishArticle(any()))
            .thenAnswer((_) async => DataSuccess(article));
        return cubit;
      },
      act: (c) => c.publish(publishParams),
      expect: () => [
        isA<CreateArticleLoading>(),
        isA<CreateArticleSuccess>(),
      ],
    );

    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_Loading_then_Error_when_publish_fails',
      build: () {
        when(() => mockPublishArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.publish(publishParams),
      expect: () => [
        isA<CreateArticleLoading>(),
        isA<CreateArticleError>(),
      ],
    );
  });

  group('CreateArticleCubit.uploadCoverImage', () {
    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_ImageUploading_then_FormUpdated_when_upload_succeeds',
      build: () {
        when(() => mockUploadImage(any()))
            .thenAnswer((_) async => const DataSuccess('https://url/img.jpg'));
        return cubit;
      },
      act: (c) => c.uploadCoverImage(File('test.jpg'), true, 'test_user_id'),
      expect: () => [
        isA<CreateArticleImageUploading>(),
        isA<CreateArticleFormUpdated>(),
      ],
      verify: (c) {
        final formState =
            c.state as CreateArticleFormUpdated;
        expect(formState.coverVerticalUrl, equals('https://url/img.jpg'));
      },
    );

    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_ImageUploading_then_Error_when_upload_fails',
      build: () {
        when(() => mockUploadImage(any()))
            .thenAnswer(
                (_) async => DataFailed(Exception('upload error')));
        return cubit;
      },
      act: (c) => c.uploadCoverImage(File('test.jpg'), false, 'test_user_id'),
      expect: () => [
        isA<CreateArticleImageUploading>(),
        isA<CreateArticleError>(),
        isA<CreateArticleFormUpdated>(),
      ],
    );
  });

  group('CreateArticleCubit.publishFromForm', () {
    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_Publishing_then_Published_when_publish_succeeds',
      build: () {
        when(() => mockPublishArticle(any()))
            .thenAnswer((_) async => DataSuccess(article));
        return cubit;
      },
      act: (c) => c.publishFromForm('user_1'),
      expect: () => [
        isA<CreateArticlePublishing>(),
        isA<CreateArticlePublished>(),
      ],
    );

    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_Publishing_then_Error_when_publish_fails',
      build: () {
        when(() => mockPublishArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) => c.publishFromForm('user_1'),
      expect: () => [
        isA<CreateArticlePublishing>(),
        isA<CreateArticleError>(),
      ],
    );
  });

  group('CreateArticleCubit.updateTitle', () {
    test('should_emit_FormUpdated_with_new_title', () {
      cubit.updateTitle('New Title');
      expect(cubit.state, isA<CreateArticleFormUpdated>());
      expect((cubit.state as CreateArticleFormUpdated).title, 'New Title');
    });
  });

  group('CreateArticleCubit.selectCategory', () {
    test('should_emit_FormUpdated_with_selected_category', () {
      cubit.selectCategory('cat_abc');
      expect(cubit.state, isA<CreateArticleFormUpdated>());
      expect(
          (cubit.state as CreateArticleFormUpdated).categoryId, 'cat_abc');
    });
  });

  group('CreateArticleFormUpdated.isValid', () {
    test('should_return_false_when_form_is_empty', () {
      const state = CreateArticleFormUpdated(
        title: '',
        categoryId: '',
        bodyJson: '',
      );
      expect(state.isValid, isFalse);
    });

    test('should_return_true_when_all_fields_are_valid', () {
      final state = CreateArticleFormUpdated(
        coverVerticalUrl: 'https://v.jpg',
        coverHorizontalUrl: 'https://h.jpg',
        title: 'A valid title',
        categoryId: 'cat_1',
        bodyJson: 'x' * 50,
      );
      expect(state.isValid, isTrue);
    });

    test('should_return_false_when_title_is_too_short', () {
      final state = CreateArticleFormUpdated(
        coverVerticalUrl: 'https://v.jpg',
        coverHorizontalUrl: 'https://h.jpg',
        title: 'AB',
        categoryId: 'cat_1',
        bodyJson: 'x' * 50,
      );
      expect(state.isValid, isFalse);
    });
  });

  group('CreateArticleCubit.loadCategories', () {
    test('should_call_getAllCategories_without_error', () async {
      when(() => mockGetAllCategories(any())).thenAnswer(
        (_) async => const DataSuccess(<CategoryEntity>[]),
      );
      await cubit.loadCategories();
      verify(() => mockGetAllCategories(any())).called(1);
    });
  });

  group('CreateArticleCubit edit mode', () {
    final articleToEdit = ArticleEntity(
      id: 'art_edit',
      authorId: 'user_1',
      categoryId: 'cat_1',
      title: 'Original Title',
      body: 'Original body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 2,
      saveCount: 0,
      createdAt: DateTime(2024),
    );

    final updatedArticle = ArticleEntity(
      id: 'art_edit',
      authorId: 'user_1',
      categoryId: 'cat_1',
      title: 'Original Title',
      body: 'Original body',
      coverVerticalUrl: '',
      coverHorizontalUrl: '',
      status: 'published',
      readTimeMinutes: 2,
      saveCount: 0,
      createdAt: DateTime(2024),
    );

    test('should_set_editing_id_after_initForEdit', () {
      cubit.initForEdit(articleToEdit);
      expect(cubit.isEditing, isTrue);
    });

    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_publishing_then_published_when_update_succeeds',
      build: () {
        when(() => mockUpdateArticle(any()))
            .thenAnswer((_) async => DataSuccess(updatedArticle));
        return cubit;
      },
      act: (c) {
        c.initForEdit(articleToEdit);
        return c.publishFromForm('user_1');
      },
      expect: () => [
        isA<CreateArticleFormUpdated>(),
        isA<CreateArticlePublishing>(),
        isA<CreateArticlePublished>(),
      ],
    );

    blocTest<CreateArticleCubit, CreateArticleState>(
      'should_emit_error_when_update_fails',
      build: () {
        when(() => mockUpdateArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        return cubit;
      },
      act: (c) {
        c.initForEdit(articleToEdit);
        return c.publishFromForm('user_1');
      },
      expect: () => [
        isA<CreateArticleFormUpdated>(),
        isA<CreateArticlePublishing>(),
        isA<CreateArticleError>(),
      ],
    );
  });
}
