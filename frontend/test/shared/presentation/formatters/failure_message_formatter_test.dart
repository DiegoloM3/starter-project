import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/shared/presentation/formatters/failure_message_formatter.dart';

void main() {
  test('every failure type gets a full sentence', () {
    for (final type in FailureType.values.where((t) => t != FailureType.validation)) {
      final message = FailureMessageFormatter.of(Failure(type, 'raw message'));
      expect(message, isNotEmpty, reason: type.name);
      expect(message, endsWith('.'), reason: type.name);
    }
  });

  test('validation failures pass the domain message through unchanged', () {
    const failure = Failure.validation('Give your article a title.');

    expect(FailureMessageFormatter.of(failure), 'Give your article a title.');
  });

  test('provider failures are reworded as advice', () {
    expect(
      FailureMessageFormatter.of(const Failure.invalidCredentials()),
      "That password isn't right. Check it and try again.",
    );
    expect(FailureMessageFormatter.of(const Failure.network()), contains('internet'));
    expect(
      FailureMessageFormatter.of(const Failure.server()),
      FailureMessageFormatter.of(const Failure.unknown()),
    );
  });
}
