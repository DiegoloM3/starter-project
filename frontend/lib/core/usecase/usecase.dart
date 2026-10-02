abstract class UseCase<Result, Params> {
  Future<Result> call({Params params});
}

/// A use case whose result keeps arriving over time, like the signed-in journalist.
abstract class StreamUseCase<Result, Params> {
  Stream<Result> call({Params params});
}
