<<<<<<< HEAD
abstract class UseCase<Type,Params> {
  Future<Type> call({Params params});
}
=======
abstract class UseCase<Type, Params> {
  Future<Type> call({required Params params});
}

abstract class NoParamsUseCase<Type> {
  Future<Type> call();
}
>>>>>>> fbce432 (Finish PR (project setup))
