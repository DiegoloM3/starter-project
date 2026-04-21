abstract class UseCase<Result, Params> {
  Future<Result> call({Params params});
}
