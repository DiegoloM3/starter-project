import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';
import 'package:news_app_clean_architecture/features/auth/domain/use_cases/sign_in_with_google.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  late MockAuthRepository auth;

  setUp(() => auth = MockAuthRepository());

  test('returns the provider result', () async {
    when(() => auth.signInWithGoogle()).thenAnswer((_) async => const DataSuccess(user));

    final result = await SignInWithGoogleUseCase(auth)(const NoParams());

    expect(result.dataOrNull, user);
  });

  test('surfaces a cancelled picker', () async {
    when(() => auth.signInWithGoogle())
        .thenAnswer((_) async => const DataFailed(Failure.cancelled()));

    final result = await SignInWithGoogleUseCase(auth)(const NoParams());

    expect(result.failureOrNull?.type, FailureType.cancelled);
  });
}
