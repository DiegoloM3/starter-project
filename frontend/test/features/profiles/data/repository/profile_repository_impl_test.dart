import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/profiles/data/data_sources/remote/follow_remote_data_source.dart';
import 'package:news_app_clean_architecture/features/profiles/data/repository/profile_repository_impl.dart';
import 'package:news_app_clean_architecture/features/profiles/domain/entities/follow_stats.dart';
import 'package:news_app_clean_architecture/shared/users/data/data_sources/remote/user_profile_remote_data_source.dart';
import 'package:news_app_clean_architecture/shared/users/data/models/user_model.dart';
import 'package:news_app_clean_architecture/shared/users/domain/entities/user.dart';

class MockUserProfileRemoteDataSource extends Mock implements UserProfileRemoteDataSource {}

class MockFollowRemoteDataSource extends Mock implements FollowRemoteDataSource {}

void main() {
  late MockUserProfileRemoteDataSource profileDataSource;
  late MockFollowRemoteDataSource followDataSource;
  late ProfileRepositoryImpl repository;

  setUp(() {
    profileDataSource = MockUserProfileRemoteDataSource();
    followDataSource = MockFollowRemoteDataSource();
    repository = ProfileRepositoryImpl(profileDataSource, followDataSource);
  });

  test('gets the profile as an entity', () async {
    const profile = UserModel(uid: 'user-1', firstName: 'Jane', lastName: 'Doe', bio: '', role: UserRole.journalist);
    when(() => profileDataSource.getProfile('user-1')).thenAnswer((_) async => profile);

    final result = await repository.getProfile('user-1');

    expect(result.data, profile.toEntity());
  });

  test('combines the counts of followers and following', () async {
    when(() => followDataSource.countFollowers('user-1')).thenAnswer((_) async => 3);
    when(() => followDataSource.countFollowing('user-1')).thenAnswer((_) async => 5);

    final result = await repository.getFollowStats('user-1');

    expect(result.data, const FollowStats(followers: 3, following: 5));
  });

  test('fails when a count fails', () async {
    when(() => followDataSource.countFollowers('user-1')).thenAnswer((_) async => throw Exception('offline'));
    when(() => followDataSource.countFollowing('user-1')).thenAnswer((_) async => 5);

    final result = await repository.getFollowStats('user-1');

    expect(result, isA<DataFailed>());
  });

  test('follows and unfollows', () async {
    when(() => followDataSource.follow('user-1')).thenAnswer((_) async {});
    when(() => followDataSource.unfollow('user-1')).thenAnswer((_) async {});

    expect(await repository.follow('user-1'), isA<DataSuccess>());
    expect(await repository.unfollow('user-1'), isA<DataSuccess>());
  });

  test('gets the ids of the followed users', () async {
    when(() => followDataSource.getFollowedUserIds()).thenAnswer((_) async => ['user-1']);

    final result = await repository.getFollowedUserIds();

    expect(result.data, ['user-1']);
  });
}
