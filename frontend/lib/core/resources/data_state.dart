<<<<<<< HEAD
import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T ? data;
  final DioError ? error;
=======
import 'package:news_app_clean_architecture/core/resources/app_error.dart';

abstract class DataState<T> {
  final T? data;
  final AppError? error;
>>>>>>> fbce432 (Finish PR (project setup))

  const DataState({this.data, this.error});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
<<<<<<< HEAD
  const DataFailed(DioError error) : super(error: error);
=======
  const DataFailed(AppError error) : super(error: error);
>>>>>>> fbce432 (Finish PR (project setup))
}
