import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

void main() {
  group('DataSuccess', () {
    test('stores data and error is null', () {
      const result = DataSuccess<String>('hello');

      expect(result.data, 'hello');
      expect(result.error, isNull);
    });

    test('stores null data for void operations', () {
      const result = DataSuccess<void>(null);

      expect(result.error, isNull);
    });
  });

  group('DataFailed', () {
    test('stores error and data is null', () {
      const error = AppException(message: 'fail', code: 'err');
      const result = DataFailed<String>(error);

      expect(result.data, isNull);
      expect(result.error, error);
      expect(result.error!.message, 'fail');
      expect(result.error!.code, 'err');
    });
  });

  group('type checking', () {
    test('DataSuccess is DataState', () {
      const result = DataSuccess<int>(42);

      expect(result, isA<DataState<int>>());
      expect(result, isA<DataSuccess<int>>());
      expect(result, isNot(isA<DataFailed<int>>()));
    });

    test('DataFailed is DataState', () {
      const result = DataFailed<int>(
        AppException(message: 'err', code: '0'),
      );

      expect(result, isA<DataState<int>>());
      expect(result, isA<DataFailed<int>>());
      expect(result, isNot(isA<DataSuccess<int>>()));
    });
  });
}
