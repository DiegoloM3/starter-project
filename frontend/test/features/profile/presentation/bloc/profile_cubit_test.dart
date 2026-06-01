import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tortutip/core/resources/data_state.dart';
import 'package:tortutip/core/usecase/usecase.dart';
import 'package:tortutip/features/articles/domain/entities/article_entity.dart';
import 'package:tortutip/features/profile/domain/use_cases/delete_article_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_published_articles_use_case.dart';
import 'package:tortutip/features/profile/domain/use_cases/get_saved_articles_use_case.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_cubit.dart';
import 'package:tortutip/features/profile/presentation/bloc/profile_state.dart';
import 'package:tortutip/shared/user/domain/entities/user_entity.dart';
import 'package:tortutip/features/categories/domain/entities/category_entity.dart';
import 'package:tortutip/features/categories/domain/use_cases/get_all_categories_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/get_current_user_use_case.dart';
import 'package:tortutip/shared/user/domain/use_cases/update_user_role_use_case.dart';

class MockGetCurrentUserUseCase extends Mock implements GetCurrentUserUseCase {}
class MockGetSavedArticlesUseCase extends Mock implements GetSavedArticlesUseCase {}
class MockGetPublishedArticlesUseCase extends Mock implements GetPublishedArticlesUseCase {}
class MockDeleteArticleUseCase extends Mock implements DeleteArticleUseCase {}
class MockGetAllCategoriesUseCase extends Mock implements GetAllCategoriesUseCase {}
class MockUpdateUserRoleUseCase extends Mock implements UpdateUserRoleUseCase {}

class FakeNoParams extends Fake implements NoParams {}
class FakeGetSavedArticlesParams extends Fake implements GetSavedArticlesParams {}
class FakeGetPublishedArticlesParams extends Fake implements GetPublishedArticlesParams {}
class FakeDeleteArticleParams extends Fake implements DeleteArticleParams {}

void main() {
  late MockGetCurrentUserUseCase mockGetCurrentUser;
  late MockGetSavedArticlesUseCase mockGetSavedArticles;
  late MockGetPublishedArticlesUseCase mockGetPublishedArticles;
  late MockDeleteArticleUseCase mockDeleteArticle;
  late MockGetAllCategoriesUseCase mockGetAllCategories;
  late MockUpdateUserRoleUseCase mockUpdateUserRole;

  setUpAll(() {
    registerFallbackValue(FakeNoParams());
    registerFallbackValue(FakeGetSavedArticlesParams());
    registerFallbackValue(FakeGetPublishedArticlesParams());
    registerFallbackValue(FakeDeleteArticleParams());
  });

  final testUser = UserEntity(
    id: 'user_1',
    name: 'Test User',
    email: 'test@test.com',
    avatarUrl: '',
    bio: '',
    role: 'reader',
    gender: '',
    ageRange: '',
    createdAt: DateTime(2024),
  );

  final testArticle = ArticleEntity(
    id: 'article_1',
    authorId: 'user_1',
    categoryId: 'cat_1',
    title: 'Test Article',
    body: '',
    coverVerticalUrl: '',
    coverHorizontalUrl: '',
    status: 'published',
    readTimeMinutes: 2,
    saveCount: 0,
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockGetCurrentUser = MockGetCurrentUserUseCase();
    mockGetSavedArticles = MockGetSavedArticlesUseCase();
    mockGetPublishedArticles = MockGetPublishedArticlesUseCase();
    mockDeleteArticle = MockDeleteArticleUseCase();
    mockGetAllCategories = MockGetAllCategoriesUseCase();
    mockUpdateUserRole = MockUpdateUserRoleUseCase();
    when(() => mockGetAllCategories(any()))
        .thenAnswer((_) async => const DataSuccess(<CategoryEntity>[]));
  });

  ProfileCubit buildCubit() => ProfileCubit(
        mockGetCurrentUser,
        mockGetSavedArticles,
        mockGetPublishedArticles,
        mockDeleteArticle,
        mockGetAllCategories,
        mockUpdateUserRole,
      );

  group('ProfileCubit', () {
    blocTest<ProfileCubit, ProfileState>(
      'should_emit_Loading_then_Loaded_when_loadProfile_succeeds',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => DataSuccess(testUser));
        when(() => mockGetSavedArticles(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        when(() => mockGetPublishedArticles(any()))
            .thenAnswer((_) async => DataSuccess([testArticle]));
        return buildCubit();
      },
      act: (c) => c.loadProfile('user_1'),
      expect: () => [isA<ProfileLoading>(), isA<ProfileLoaded>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'should_emit_Loading_then_Error_when_getCurrentUser_fails',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        when(() => mockGetSavedArticles(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        when(() => mockGetPublishedArticles(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return buildCubit();
      },
      act: (c) => c.loadProfile('user_1'),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'should_emit_Loading_then_Error_when_getSavedArticles_fails',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => DataSuccess(testUser));
        when(() => mockGetSavedArticles(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        when(() => mockGetPublishedArticles(any()))
            .thenAnswer((_) async => const DataSuccess([]));
        return buildCubit();
      },
      act: (c) => c.loadProfile('user_1'),
      expect: () => [isA<ProfileLoading>(), isA<ProfileError>()],
    );

    blocTest<ProfileCubit, ProfileState>(
      'should_emit_ArticleDeleted_then_Loaded_without_deleted_article_when_deleteArticle_succeeds',
      build: () {
        when(() => mockDeleteArticle(any()))
            .thenAnswer((_) async => const DataSuccess(true));
        final cubit = buildCubit();
        cubit.emit(ProfileLoaded(
          user: testUser,
          savedArticles: const [],
          publishedArticles: [testArticle],
          totalPublishedCount: 1,
        ));
        return cubit;
      },
      act: (c) => c.deleteArticle('article_1', 'user_1'),
      expect: () => [isA<ProfileArticleDeleted>(), isA<ProfileLoaded>()],
      verify: (c) {
        final loaded = c.state as ProfileLoaded;
        expect(loaded.publishedArticles, isEmpty);
        expect(loaded.totalPublishedCount, 0);
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'should_emit_Error_when_deleteArticle_fails',
      build: () {
        when(() => mockDeleteArticle(any()))
            .thenAnswer((_) async => DataFailed(Exception('error')));
        final cubit = buildCubit();
        cubit.emit(ProfileLoaded(
          user: testUser,
          savedArticles: const [],
          publishedArticles: [testArticle],
          totalPublishedCount: 1,
        ));
        return cubit;
      },
      act: (c) => c.deleteArticle('article_1', 'user_1'),
      expect: () => [isA<ProfileError>()],
    );
  });
}
