import 'package:news_app_clean_architecture/core/resources/failure.dart';

abstract class DataState<T> {
  final T? data;
  final Failure? failure;

  const DataState({this.data, this.failure});
}

class DataSuccess<T> extends DataState<T> {
  final bool isCached;
  const DataSuccess(T data, {this.isCached = false}) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Failure failure) : super(failure: failure);
}
