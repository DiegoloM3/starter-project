import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

void main() {
  const success = DataSuccess<int>(42);
  const failed = DataFailed<int>(Failure.network());

  group('DataSuccess', () {
    test('exposes the payload and no failure', () {
      expect(success.isSuccess, isTrue);
      expect(success.isFailure, isFalse);
      expect(success.dataOrNull, 42);
      expect(success.failureOrNull, isNull);
    });

    test('map() transforms the payload', () {
      expect(success.map((d) => d.toString()), const DataSuccess<String>('42'));
    });
  });

  group('DataFailed', () {
    test('exposes the failure and no payload', () {
      expect(failed.isSuccess, isFalse);
      expect(failed.isFailure, isTrue);
      expect(failed.dataOrNull, isNull);
      expect(failed.failureOrNull, const Failure.network());
    });

    test('map() keeps the failure untouched', () {
      final mapped = failed.map((d) => d.toString());
      expect(mapped, const DataFailed<String>(Failure.network()));
    });
  });

  group('Failure', () {
    test('validation failures carry the given message', () {
      const failure = Failure.validation('Title is required.');
      expect(failure.type, FailureType.validation);
      expect(failure.message, 'Title is required.');
    });
  });

  group('runGuarded', () {
    test('wraps the value of an operation that completes', () async {
      expect(await runGuarded(() async => 7, onError: (_) => const Failure.unknown()), const DataSuccess(7));
    });

    test('turns a thrown error into the failure the mapper chooses', () async {
      final result = await runGuarded<int>(
        () async => throw StateError('boom'),
        onError: (error) => Failure.server('$error'),
      );
      expect(result, const DataFailed<int>(Failure.server('Bad state: boom')));
    });
  });
}
