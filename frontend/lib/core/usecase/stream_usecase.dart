abstract class StreamUseCase<Type, Params> {
  Stream<Type> call({Params params});
}
