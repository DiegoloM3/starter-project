/// A provider-independent failure used at the application boundary.
class AppFailure {
  final String message;
  final Object? cause;

  const AppFailure(this.message, {this.cause});

  @override
  String toString() => message;
}

/// Result returned by repositories without leaking provider exceptions into the domain.
abstract class DataState<T> {
  final T? data;
  final AppFailure? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(AppFailure error) : super(error: error);
}
