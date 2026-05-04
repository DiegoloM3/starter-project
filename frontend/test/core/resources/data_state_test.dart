import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/error/app_exception.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

void main() {
  group('DataState', () {
    group('DataSuccess', () {
      test('wraps a value', () {
        const state = DataSuccess<String>('hello');

        expect(state.data, equals('hello'));
        expect(state.error, isNull);
      });

      test('is a DataState', () {
        const state = DataSuccess<int>(42);

        expect(state, isA<DataState<int>>());
      });
    });

    group('DataFailed', () {
      test('wraps an AppException', () {
        const appException = NetworkException(message: 'no connection');
        const state = DataFailed<String>(appException);

        expect(state.error, equals(appException));
        expect(state.data, isNull);
      });

      test('is a DataState', () {
        const exception = NetworkException(message: 'error');
        const state = DataFailed<int>(exception);

        expect(state, isA<DataState<int>>());
      });

      test('error field type is AppException', () {
        const exception = FirestoreException(message: 'not found');
        const state = DataFailed<String>(exception);

        expect(state.error, isA<AppException>());
      });

      test('error subtype is preserved', () {
        const exception = StorageException(message: 'upload failed');
        const state = DataFailed<void>(exception);

        expect(state.error, isA<StorageException>());
      });
    });
  });
}
