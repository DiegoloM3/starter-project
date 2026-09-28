

abstract interface class UseCase<ResultType,Params> {
  Future<ResultType> call({Params params});
}