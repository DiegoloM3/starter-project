import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

/// Outcome of a repository or use case operation.
///
/// Sealed so that consumers can `switch` exhaustively over
/// [DataSuccess] and [DataFailed].
sealed class DataState<T> extends Equatable {
  const DataState();

  bool get isSuccess => this is DataSuccess<T>;

  bool get isFailure => this is DataFailed<T>;

  /// The payload when successful, otherwise `null`.
  T? get dataOrNull => switch (this) {
        DataSuccess(:final data) => data,
        DataFailed() => null,
      };

  /// The failure when unsuccessful, otherwise `null`.
  Failure? get failureOrNull => switch (this) {
        DataSuccess() => null,
        DataFailed(:final failure) => failure,
      };

  /// Transforms the payload while preserving a failure untouched.
  DataState<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      DataSuccess(:final data) => DataSuccess(transform(data)),
      DataFailed(:final failure) => DataFailed(failure),
    };
  }
}

final class DataSuccess<T> extends DataState<T> {
  final T data;

  const DataSuccess(this.data);

  @override
  List<Object?> get props => [data];
}

final class DataFailed<T> extends DataState<T> {
  final Failure failure;

  const DataFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}

/// Runs [operation] and wraps its outcome: the value as a [DataSuccess], any
/// thrown error as a [DataFailed] through [onError]. The one place where the
/// data layer turns exceptions into failures.
Future<DataState<T>> runGuarded<T>(
  Future<T> Function() operation, {
  required Failure Function(Object error) onError,
}) async {
  try {
    return DataSuccess(await operation());
  } catch (error) {
    return DataFailed(onError(error));
  }
}
