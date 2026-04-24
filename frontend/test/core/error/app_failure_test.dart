import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';

void main() {
  group('AppFailure', () {
    test('value equality holds across identical factories', () {
      const a = AppFailure.network(message: 'boom', statusCode: 500);
      const b = AppFailure.network(message: 'boom', statusCode: 500);
      expect(a, equals(b));
    });

    test('different variants are not equal', () {
      const net = AppFailure.network(message: 'boom');
      const cache = AppFailure.cache(message: 'boom');
      expect(net, isNot(equals(cache)));
    });

    test('exhaustive when() on every variant', () {
      String classify(AppFailure f) => f.when(
            network: (_, __) => 'network',
            cache: (_) => 'cache',
            validation: (_, __) => 'validation',
            auth: (_) => 'auth',
            unknown: (_, __) => 'unknown',
          );

      expect(classify(const AppFailure.network()), equals('network'));
      expect(classify(const AppFailure.cache()), equals('cache'));
      expect(
        classify(const AppFailure.validation(field: 'x', reason: 'y')),
        equals('validation'),
      );
      expect(classify(const AppFailure.auth()), equals('auth'));
      expect(classify(const AppFailure.unknown()), equals('unknown'));
    });

    test('validation carries field and reason', () {
      const v = AppFailure.validation(field: 'title', reason: 'too short');
      expect(v, isA<ValidationFailure>());
      v.maybeWhen(
        validation: (field, reason) {
          expect(field, equals('title'));
          expect(reason, equals('too short'));
        },
        orElse: () => fail('expected validation variant'),
      );
    });
  });
}
