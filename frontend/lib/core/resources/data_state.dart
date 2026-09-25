/// [error] is intentionally `Object`, not any one backend's exception type.
/// core/ is imported by every layer's data source (dio-based REST today,
/// Firestore in features/user_articles later), so this file must not itself
/// depend on any one of them -- each repository impl wraps whatever failure
/// its own backend throws.
abstract class DataState<T> {
  final T ? data;
  final Object ? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Object error) : super(error: error);
}
