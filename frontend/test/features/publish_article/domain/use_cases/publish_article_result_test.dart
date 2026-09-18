import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/features/publish_article/domain/use_cases/publish_article_result.dart';

void main() {
  test('validation failure copies and protects its errors', () {
    const error = PublishArticleValidationError(
      PublishArticleField.author,
      'Required.',
    );
    final original = [error];
    final result = PublishArticleResult.validationFailure(original);
    original.clear();
    expect(result.article, isNull);
    expect(result.errors, [error]);
    expect(() => result.errors.clear(), throwsUnsupportedError);
    expect(() => result.errors[0] = error, throwsUnsupportedError);
  });

  test('validation failure cannot be created without errors', () {
    expect(
        () => PublishArticleResult.validationFailure([]), throwsArgumentError);
  });
}
