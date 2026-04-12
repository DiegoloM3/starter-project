abstract class UseCase<Output, Params> {
  Future<Output> call({Params params});
}
