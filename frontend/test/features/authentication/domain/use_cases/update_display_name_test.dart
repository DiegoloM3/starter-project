import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/entities/auth_failures.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/params/update_display_name_params.dart';
import 'package:news_app_clean_architecture/features/authentication/domain/use_cases/update_display_name.dart';

import '../../../../helpers/fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late UpdateDisplayNameUseCase updateDisplayName;

  setUp(() {
    repository = FakeAuthRepository();
    updateDisplayName = UpdateDisplayNameUseCase(repository);
  });

  test('stores the new byline', () async {
    final result =
        await updateDisplayName(const UpdateDisplayNameParams('A. Rivera'));

    expect(result, isA<DataSuccess>());
    expect(result.data?.displayName, 'A. Rivera');
    expect(repository.lastDisplayName, 'A. Rivera');
  });

  test('trims what was typed before storing it', () async {
    await updateDisplayName(const UpdateDisplayNameParams('  A. Rivera  '));

    expect(repository.lastDisplayName, 'A. Rivera');
  });

  test('refuses an empty name, which would leave articles unsigned', () async {
    final result =
        await updateDisplayName(const UpdateDisplayNameParams('   '));

    expect(
      (result.error as CredentialsValidationException).errors,
      contains(CredentialsValidationError.displayNameInvalid),
    );
    expect(repository.updateDisplayNameCallCount, 0);
  });

  test('refuses a name too long to fit an article byline', () async {
    final tooLong = 'a' * (UpdateDisplayNameParams.maxLength + 1);

    final result = await updateDisplayName(UpdateDisplayNameParams(tooLong));

    expect(result, isA<DataFailed>());
    expect(repository.updateDisplayNameCallCount, 0);
  });
}
