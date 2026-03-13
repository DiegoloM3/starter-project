/// Base class for use cases that require parameters.
/// [Type] is the return type of the use case.
/// [Params] is the type of parameters the use case requires.
abstract class UseCase<Type, Params> {
  Future<Type> call({Params params});
}

/// Base class for use cases that don't require parameters.
/// [Type] is the return type of the use case.
abstract class UseCaseNoParams<Type> {
  Future<Type> call();
}

/// Base class for use cases that return a stream.
/// [Type] is the type emitted by the stream.
/// [Params] is the type of parameters the use case requires.
abstract class StreamUseCase<Type, Params> {
  Stream<Type> call({Params params});
}

/// Base class for stream use cases that don't require parameters.
/// [Type] is the type emitted by the stream.
abstract class StreamUseCaseNoParams<Type> {
  Stream<Type> call();
}
