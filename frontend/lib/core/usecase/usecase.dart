abstract class UseCase<ResultType, Params> {
  Future<ResultType> call(Params params);
}

abstract class StreamUseCase<ResultType, Params> {
  Stream<ResultType> call(Params params);
}

class NoParams {
  const NoParams();
}
