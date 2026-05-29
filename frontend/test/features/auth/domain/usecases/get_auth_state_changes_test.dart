import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_auth_state_changes.dart';

import '../../../../helpers/mock_classes.dart';
import '../../../../helpers/test_fixtures.dart';

void main() {
  late GetAuthStateChangesUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetAuthStateChangesUseCase(mockRepository);
  });

  test('emits the authenticated user from the repository stream', () {
    final user = testAuthUser();
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => Stream.value(user));

    final stream = useCase();

    expect(stream, emits(user));
    verify(() => mockRepository.authStateChanges).called(1);
  });

  test('emits null when the user is signed out', () {
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => Stream<AuthUserEntity?>.value(null));

    expect(useCase(), emits(null));
  });

  test('delegates to repository.authStateChanges', () {
    when(() => mockRepository.authStateChanges)
        .thenAnswer((_) => const Stream.empty());

    useCase();

    verify(() => mockRepository.authStateChanges).called(1);
  });
}
