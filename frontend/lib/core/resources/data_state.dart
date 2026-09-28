import 'package:dio/dio.dart';

/// Result wrapper returned by repositories for remote reads.
/// [DataSuccess] carries data; [DataDioFailed]/[DataGenericFailed] carry errors.
abstract class DataState<T> {
  final T? data;
  final DioException? error;
  final String? errorMessage;

  const DataState({this.data, this.error, this.errorMessage});
}

/// Successful result carrying non-null [DataState.data].
class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

/// Failed result carrying the [DioException] from a remote call.
class DataDioFailed<T> extends DataState<T> {
  const DataDioFailed(DioException error) : super(error: error);
}

/// Failed result carrying a plain [errorMessage] for non-Dio failures.
class DataGenericFailed<T> extends DataState<T> {
  const DataGenericFailed(String errorMessage)
      : super(errorMessage: errorMessage);
}
