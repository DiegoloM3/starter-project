/// Result of an operation that fetches data from an external source.
///
/// Repository implementations always return a [DataState] so that the business
/// layer can react to failures without knowing which provider (news API,
/// Firestore, Cloud Storage, ...) produced them. For that reason the error is
/// kept as a plain [Object]: coupling this class to a provider specific error
/// type would leak that provider into the domain layer.
abstract class DataState<T> {
  final T? data;
  final Object? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Object error) : super(error: error);
}
