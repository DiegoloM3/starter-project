import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.entity.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/widgets/user_avatar.dart';

void main() {
  const tUser = UserEntity(
    id: 'u1',
    email: 'jane@example.com',
    displayName: 'Jane Doe',
    photoUrl: 'https://example.com/avatar.jpg',
  );

  Widget buildAvatar(UserAvatar avatar) {
    return MaterialApp(home: Scaffold(body: avatar));
  }

  testWidgets('shows photo avatar when logged in with photoUrl',
      (tester) async {
    await tester.pumpWidget(
      buildAvatar(const UserAvatar(user: tUser, isLoggedIn: true)),
    );

    expect(find.byType(CircleAvatar), findsOneWidget);
    expect(find.text('J'), findsNothing);
  });

  testWidgets('shows initial letter when logged in without photo',
      (tester) async {
    const user = UserEntity(id: 'u1', email: 'jane@example.com');

    await tester.pumpWidget(
      buildAvatar(const UserAvatar(user: user, isLoggedIn: true)),
    );

    expect(find.text('J'), findsOneWidget);
  });

  testWidgets('shows loggedOutLetter when logged out', (tester) async {
    await tester.pumpWidget(
      buildAvatar(
        const UserAvatar(isLoggedIn: false, loggedOutLetter: 'G'),
      ),
    );

    expect(find.text('G'), findsOneWidget);
  });
}
