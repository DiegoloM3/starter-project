import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

void main() {
  group('runAsDataState', () {
    test('wraps the result in a success', () async {
      final result = await runAsDataState(() async => 42);

      expect(result, isA<DataSuccess<int>>());
      expect(result.data, 42);
    });

    test('wraps the thrown exception in a failure', () async {
      final error = Exception('offline');

      final result = await runAsDataState<int>(() async => throw error);

      expect(result, isA<DataFailed<int>>());
      expect(result.error, error);
    });
  });
}
