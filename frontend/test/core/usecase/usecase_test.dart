import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';
import 'package:news_app_clean_architecture/core/usecase/usecase.dart';

class _SuccessUseCase extends UseCase<int, NoParams> {
  @override
  Future<Either<AppFailure, int>> call(NoParams params) async =>
      const Right(42);
}

class _FailingUseCase extends UseCase<int, String> {
  @override
  Future<Either<AppFailure, int>> call(String params) async =>
      Left(AppFailure.validation(field: 'input', reason: 'was "$params"'));
}

void main() {
  group('UseCase base', () {
    test('success path returns Right', () async {
      final result = await _SuccessUseCase().call(const NoParams());
      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('expected Right'),
        (value) => expect(value, equals(42)),
      );
    });

    test('failure path returns Left with AppFailure', () async {
      final result = await _FailingUseCase().call('bad');
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ValidationFailure>());
          failure.maybeWhen(
            validation: (field, reason) {
              expect(field, equals('input'));
              expect(reason, contains('bad'));
            },
            orElse: () => fail('expected validation variant'),
          );
        },
        (_) => fail('expected Left'),
      );
    });

    test('NoParams is const-constructible', () {
      const a = NoParams();
      const b = NoParams();
      expect(identical(a, b), isTrue);
    });
  });
}
