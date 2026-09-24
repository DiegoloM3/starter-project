/// A single piece of business logic the application can perform.
///
/// Use cases are invoked as functions (`await createArticle(params)`) and
/// receive their input through a params class. Use [NoParams] for use cases
/// that need no input.
abstract class UseCase<ReturnType, Params> {
  Future<ReturnType> call(Params params);
}

/// Placeholder for use cases that do not need any input.
class NoParams {
  const NoParams();
}
