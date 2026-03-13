import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final DioError? error;
  final Exception? exception;

  const DataState({this.data, this.error, this.exception});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  DataFailed(dynamic error)
      : super(
          error: error is DioError ? error : null,
          exception: error is Exception ? error : null,
        );
}
