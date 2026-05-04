/// Abstract base class for use cases that return a continuous [Stream].
///
/// Mirrors [UseCase] for one-shot futures, but exposes [Stream<T>]
/// so that reactive subscriptions (e.g. auth state changes) fit cleanly
/// into the use-case taxonomy without wrapping streams in futures.
abstract class StreamUseCase<T, Params> {
  Stream<T> call({Params? params});
}
