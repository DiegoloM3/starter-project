abstract class UseCase<Type,Params> {
  Future<Type> call({Params params});
}

/// A use case whose results arrive over time, like the progress of a long operation.
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call({Params params});
}
