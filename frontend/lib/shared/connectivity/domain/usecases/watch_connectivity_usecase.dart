import '../repository/connectivity_repository.dart';

/// Not a [UseCase]: that interface is shaped for one request/one [Future]
/// response, and this is a running signal, not a request -- the same kind
/// of deliberate deviation RemoteArticlesBloc already makes by staying a
/// Bloc while the rest of the app moved to Cubits. Still one job, one
/// `call()`, wrapping exactly one repository.
class WatchConnectivityUseCase {
  final ConnectivityRepository _repository;

  WatchConnectivityUseCase(this._repository);

  Stream<bool> call() => _repository.watch();
}
