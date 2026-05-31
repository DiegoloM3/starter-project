import 'package:dio/dio.dart';

class Cancellable<T> {
  final Future<T> call;
  final CancelToken token;

  const Cancellable(this.call, this.token);

  Cancellable<R> modifyCall<R>(Future<R> Function(Future<T> call) update) =>
      Cancellable(update(call), token);

  void cancel() {
    if (!token.isCancelled) {
      token.cancel();
    }
  }
}
