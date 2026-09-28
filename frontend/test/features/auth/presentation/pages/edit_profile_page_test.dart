import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/profile/profile_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/edit_profile/edit_profile_page.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

import 'edit_profile_page_test.mocks.dart';

@GenerateMocks([ProfileBloc])
void main() {
  late MockProfileBloc mockProfileBloc;

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    when(mockProfileBloc.state).thenReturn(const ProfileLoading());
    when(mockProfileBloc.stream)
        .thenAnswer((_) => const Stream<ProfileState>.empty());
    sl.registerFactory<ProfileBloc>(() => mockProfileBloc);
    // The page header renders the shared AuthorAvatar, which resolves its
    // own cubit: answer "no photo" so it falls back to the silhouette.
    sl.registerFactory<AuthorAvatarCubit>(
      () => AuthorAvatarCubit(_StubGetAuthorProfile()),
    );
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('prefills the current display name', (tester) async {
    when(mockProfileBloc.state).thenReturn(const ProfileDone(
      userId: 'user-123',
      email: 'jane@example.com',
      displayName: 'Jane Doe',
      photoUrl: 'https://example.com/avatar.jpg',
    ));

    await tester.pumpWidget(
      const MaterialApp(home: EditProfilePage()),
    );
    await tester.pump();

    expect(find.text('Jane Doe'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('shows an error message when the profile cannot load',
      (tester) async {
    when(mockProfileBloc.state)
        .thenReturn(const ProfileError('Please log in.'));

    await tester.pumpWidget(
      const MaterialApp(home: EditProfilePage()),
    );
    await tester.pump();

    expect(find.text('Please log in.'), findsOneWidget);
  });
}

class _StubGetAuthorProfile extends Fake implements GetAuthorProfile {
  @override
  Future<DataState<UserProfileEntity?>> call(
      {GetAuthorProfileParams? params}) async {
    return const DataSuccess(null);
  }
}
