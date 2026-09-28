import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user_profile.entity.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_author_profile.dart';
import 'package:news_app_clean_architecture/features/news/presentation/bloc/article/avatar/author_avatar_cubit.dart';
import 'package:news_app_clean_architecture/features/news/presentation/widgets/author_avatar.dart';

import 'author_avatar_test.mocks.dart';

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

  Widget buildAvatar(String? authorId) {
    return MaterialApp(
      home: Scaffold(
        body: AuthorAvatar(
          authorId: authorId,
          cubitFactory: () => AuthorAvatarCubit(mockGetAuthorProfile),
        ),
      ),
    );
  }

  testWidgets('shows a silhouette without reading when author id is null',
      (tester) async {
    await tester.pumpWidget(buildAvatar(null));

    expect(find.byIcon(Icons.person), findsOneWidget);
    verifyZeroInteractions(mockGetAuthorProfile);
  });

  testWidgets('shows a silhouette when the author has no photo',
      (tester) async {
    when(mockGetAuthorProfile.call(params: anyNamed('params'))).thenAnswer(
        (_) async => const DataSuccess(
              UserProfileEntity(id: 'user-123'),
            ));

    await tester.pumpWidget(buildAvatar('user-123'));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.person), findsOneWidget);
  });

  testWidgets('shows the photo avatar when the author has one',
      (tester) async {
    when(mockGetAuthorProfile.call(params: anyNamed('params')))
        .thenAnswer((_) async => const DataSuccess(tProfile));

    await tester.pumpWidget(buildAvatar('user-123'));
    await tester.pump();
    await tester.pump();

    expect(find.byIcon(Icons.person), findsNothing);
    expect(find.byType(CircleAvatar), findsOneWidget);
  });

  testWidgets(
      'bounds photo decode size (regression: full-res uploads must not '
      'decode at native resolution for a thumbnail)', (tester) async {
    when(mockGetAuthorProfile.call(params: anyNamed('params')))
        .thenAnswer((_) async => const DataSuccess(tProfile));

    await tester.pumpWidget(buildAvatar('user-123'));
    await tester.pump();
    await tester.pump();

    final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
    final image = avatar.backgroundImage! as ResizeImage;
    expect(image.width, 144);
  });
}
