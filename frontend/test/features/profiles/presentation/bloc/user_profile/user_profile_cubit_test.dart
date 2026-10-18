import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_content.dart';
import 'package:news_app_clean_architecture/features/articles/domain/entities/article_topic.dart';
import 'package:news_app_clean_architecture/features/articles/domain/usecases/get_articles_by_authors.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/entities/follow_stats.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/follow_user.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_follow_stats.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/get_user_profile.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/is_following.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/usecases/unfollow_user.dart';
import 'package:news_app_clean_architecture/features/profiles/presentation/bloc/user_profile/user_profile_cubit.dart';
import 'package:news_app_clean_architecture/features/profiles/presentation/bloc/user_profile/user_profile_state.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

class MockGetUserProfileUseCase extends Mock implements GetUserProfileUseCase {}

class MockGetFollowStatsUseCase extends Mock implements GetFollowStatsUseCase {}

class MockIsFollowingUseCase extends Mock implements IsFollowingUseCase {}

class MockFollowUserUseCase extends Mock implements FollowUserUseCase {}

class MockUnfollowUserUseCase extends Mock implements UnfollowUserUseCase {}

class MockGetArticlesByAuthorsUseCase extends Mock implements GetArticlesByAuthorsUseCase {}

const user = UserEntity(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.journalist);
const stats = FollowStats(followers: 3, following: 5);
final article = ArticleEntity(
  id: 'article-1',
  title: 'Title',
  description: 'Description',
  content: ArticleContent.fromPlainText('Content'),
  thumbnailURL: 'https://example.com/image.jpg',
  topics: const [ArticleTopic.sports],
  publishedAt: DateTime(2026, 10, 16),
  authorId: 'user-1',
  authorName: 'Jane Doe',
);

void main() {
  late MockGetUserProfileUseCase getUserProfile;
  late MockGetFollowStatsUseCase getFollowStats;
  late MockIsFollowingUseCase isFollowing;
  late MockFollowUserUseCase followUser;
  late MockUnfollowUserUseCase unfollowUser;
  late MockGetArticlesByAuthorsUseCase getArticlesByAuthors;

  final loadedState = UserProfileState(
    status: UserProfileStatus.success,
    user: user,
    stats: stats,
    articles: [article],
  );

  setUp(() {
    getUserProfile = MockGetUserProfileUseCase();
    getFollowStats = MockGetFollowStatsUseCase();
    isFollowing = MockIsFollowingUseCase();
    followUser = MockFollowUserUseCase();
    unfollowUser = MockUnfollowUserUseCase();
    getArticlesByAuthors = MockGetArticlesByAuthorsUseCase();
  });

  UserProfileCubit buildCubit() => UserProfileCubit(
    'user-1',
    getUserProfile,
    getFollowStats,
    isFollowing,
    followUser,
    unfollowUser,
    getArticlesByAuthors,
  );

  void stubLoad({DataState<UserEntity> profile = const DataSuccess(user)}) {
    when(() => getUserProfile('user-1')).thenAnswer((_) async => profile);
    when(() => getFollowStats('user-1')).thenAnswer((_) async => const DataSuccess(stats));
    when(() => isFollowing('user-1')).thenAnswer((_) async => const DataSuccess(false));
    when(() => getArticlesByAuthors(['user-1'])).thenAnswer((_) async => DataSuccess([article]));
  }

  blocTest<UserProfileCubit, UserProfileState>(
    'loads the profile, the stats, whether it is followed and the articles',
    setUp: stubLoad,
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [const UserProfileState(status: UserProfileStatus.loading), loadedState],
  );

  blocTest<UserProfileCubit, UserProfileState>(
    'fails when the profile cannot be loaded',
    setUp: () => stubLoad(profile: DataFailed(Exception('offline'))),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect:
        () => [
          const UserProfileState(status: UserProfileStatus.loading),
          const UserProfileState(status: UserProfileStatus.failure),
        ],
  );

  blocTest<UserProfileCubit, UserProfileState>(
    'follows at once and counts the new follower',
    setUp: () => when(() => followUser('user-1')).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.toggleFollow(),
    expect: () => [loadedState.copyWith(isFollowing: true, stats: const FollowStats(followers: 4, following: 5))],
  );

  blocTest<UserProfileCubit, UserProfileState>(
    'unfollows a followed user',
    setUp: () => when(() => unfollowUser('user-1')).thenAnswer((_) async => const DataSuccess(null)),
    build: buildCubit,
    seed: () => loadedState.copyWith(isFollowing: true),
    act: (cubit) => cubit.toggleFollow(),
    expect: () => [loadedState.copyWith(isFollowing: false, stats: const FollowStats(followers: 2, following: 5))],
  );

  blocTest<UserProfileCubit, UserProfileState>(
    'restores the previous state when following fails',
    setUp: () => when(() => followUser('user-1')).thenAnswer((_) async => DataFailed(Exception('offline'))),
    build: buildCubit,
    seed: () => loadedState,
    act: (cubit) => cubit.toggleFollow(),
    expect:
        () => [
          loadedState.copyWith(isFollowing: true, stats: const FollowStats(followers: 4, following: 5)),
          loadedState.copyWith(followFailed: true),
        ],
  );
}
