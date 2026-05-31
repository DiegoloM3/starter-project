import 'package:news_app_clean_architecture/core/errors/failure.dart';

/// Sealed class hierarchy representing the result of a data operation.
///
/// Used throughout the application to represent success or failure states
/// from repositories, consistently replacing the old Either pattern.
///
/// **Usage in use cases:**
/// ```dart
/// // Use case returns DataState
/// Future<DataState<ArticleEntity>> getArticle(String id) =>
///   _repository.getArticle(id);
/// ```
///
/// **Usage in BLoCs (pattern matching):**
/// ```dart
/// final dataState = await _getArticleUseCase(params: ArticleParams());
/// switch (dataState) {
///   case DataSuccess<ArticleEntity>(:final data):
///     emit(ArticleLoaded(article: data));
///   case DataFailed<dynamic>(:final failure):
///     emit(ArticleError(failure: failure));
/// }
/// ```

/// Base sealed class for operation results.
sealed class DataState<T> {
  const DataState();
}

/// Represents a successful operation with data.
final class DataSuccess<T> extends DataState<T> {
  const DataSuccess(this.data);

  /// The data returned from the successful operation.
  final T data;
}

/// Represents a failed operation with error details.
final class DataFailed<T> extends DataState<T> {
  const DataFailed(this.failure);

  /// The failure object containing error information (message is l10n key).
  final Failure failure;
}
