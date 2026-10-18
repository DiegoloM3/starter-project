import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/watch_current_user.dart';

void main() {
  final watchCurrentUser = WatchCurrentUserUseCase();

  test('starts with nobody signed in', () async {
    final currentUser = await watchCurrentUser(const NoParams()).first;

    expect(currentUser, isNull);
  });

  test('emits the user that signs in and null when they sign out', () async {
    final emittedUsers = watchCurrentUser(const NoParams()).take(3).toList();

    final signedInUser = (await SignInUseCase().call(SignInParams(email: 'jane@test.com', password: 'any'))).data;
    await SignOutUseCase().call(const NoParams());

    expect(await emittedUsers, [null, signedInUser, null]);
  });

  test('emits the current user to new listeners', () async {
    final signedInUser = (await SignInUseCase().call(SignInParams(email: 'jane@test.com', password: 'any'))).data;

    final currentUser = await watchCurrentUser(const NoParams()).first;

    expect(currentUser, signedInUser);
  });
}
