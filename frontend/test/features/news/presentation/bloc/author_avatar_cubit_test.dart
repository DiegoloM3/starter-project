import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';

import 'author_avatar_cubit_test.mocks.dart';

@GenerateMocks([GetAuthorProfile])
void main() {
  late MockGetAuthorProfile mockGetAuthorProfile;

  const tProfile = UserProfileEntity(
    id: 'user-123',
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/avatar.jpg',
  );

  setUp(() {
    mockGetAuthorProfile = MockGetAuthorProfile();
  });

  AuthorAvatarCubit buildCubit() =>
      AuthorAvatarCubit(mockGetAuthorProfile);

  test('initial state is AuthorAvatarLoading', () {
    expect(buildCubit().state, isA<AuthorAvatarLoading>());
  });

  blocTest<AuthorAvatarCubit, AuthorAvatarState>(
    'emits [Loading, Done] when the author has a photo',
    build: () {
      when(mockGetAuthorProfile.call(params: anyNamed('params')))
          .thenAnswer((_) async => const DataSuccess(tProfile));
      return buildCubit();
    },
    act: (cubit) => cubit.load('user-123'),
    expect: () => [
      const AuthorAvatarLoading(),
      const AuthorAvatarDone('https://example.com/avatar.jpg'),
    ],
    verify: (_) {
      verify(mockGetAuthorProfile.call(
        params: argThat(
          isA<GetAuthorProfileParams>()
              .having((p) => p.authorId, 'authorId', 'user-123'),
          named: 'params',
        ),
      )).called(1);
    },
  );

  blocTest<AuthorAvatarCubit, AuthorAvatarState>(
    'emits [Loading, Missing] for a blank author id without reading',
    build: () => buildCubit(),
    act: (cubit) => cubit.load('  '),
    expect: () => [
      const AuthorAvatarMissing(),
    ],
    verify: (_) {
      verifyZeroInteractions(mockGetAuthorProfile);
    },
  );

  blocTest<AuthorAvatarCubit, AuthorAvatarState>(
    'emits [Loading, Missing] when the author has no photo',
    build: () {
      when(mockGetAuthorProfile.call(params: anyNamed('params'))).thenAnswer(
          (_) async => const DataSuccess(
                UserProfileEntity(id: 'user-123'),
              ));
      return buildCubit();
    },
    act: (cubit) => cubit.load('user-123'),
    expect: () => [
      const AuthorAvatarLoading(),
      const AuthorAvatarMissing(),
    ],
  );

  blocTest<AuthorAvatarCubit, AuthorAvatarState>(
    'emits [Loading, Missing] when the lookup fails',
    build: () {
      when(mockGetAuthorProfile.call(params: anyNamed('params'))).thenAnswer(
          (_) async => const DataGenericFailed('Failed to load profile'));
      return buildCubit();
    },
    act: (cubit) => cubit.load('user-123'),
    expect: () => [
      const AuthorAvatarLoading(),
      const AuthorAvatarMissing(),
    ],
  );
}
