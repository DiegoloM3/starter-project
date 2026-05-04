import 'package:news_app_clean_architecture/core/error/app_exception.dart';

abstract class DataState<T> {
  final T? data;
  final AppException? error;

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(AppException error) : super(error: error);
}
