abstract class DataState<T> {
  final T? data;
  final Exception? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Exception error) : super(error: error);
}

/// Runs [request] and wraps its result, or the exception it throws, in a [DataState].
/// Repositories use it so that exceptions never reach the presentation layer.
Future<DataState<T>> runAsDataState<T>(Future<T> Function() request) async {
  try {
    return DataSuccess(await request());
  } on Exception catch (error) {
    return DataFailed(error);
  }
}
