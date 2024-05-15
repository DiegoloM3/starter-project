import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

abstract class DataState<T> {
  final T? data;
  final DioException? exception;
  final FirebaseException? fireException;

  const DataState({this.data, this.exception, this.fireException});
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(DioException exception) : super(exception: exception);
}

class FireFailed<T> extends DataState<T> {
  const FireFailed(FirebaseException exception) : super(fireException: exception);
}