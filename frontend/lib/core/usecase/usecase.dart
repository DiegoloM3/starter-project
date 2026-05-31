abstract class UseCase<Result, Params> {
  Future<Result> call({Params params});
}

abstract class StreamUseCase<Result, Params> {
  Stream<Result> call({Params params});
}
