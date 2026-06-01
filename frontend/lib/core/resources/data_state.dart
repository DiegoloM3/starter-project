import 'package:equatable/equatable.dart';

abstract class DataState<T> extends Equatable {
  final T? data;
  final Exception? error;

  const DataState({this.data, this.error});

  bool get isSuccess => this is DataSuccess<T>;
  bool get isFailure => this is DataFailed<T>;

  @override
  List<Object?> get props => [data, error];
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(Exception error) : super(error: error);
}
