import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';

class _PublishFailure implements Exception {}

void main() {
  test('DataSuccess carries data and no error', () {
    const state = DataSuccess<int>(42);

    expect(state.data, 42);
    expect(state.error, isNull);
  });

  test('DataFailed accepts any exception, not only network errors', () {
    final failure = _PublishFailure();
    final state = DataFailed<int>(failure);

    expect(state.error, same(failure));
    expect(state.data, isNull);
  });
}
