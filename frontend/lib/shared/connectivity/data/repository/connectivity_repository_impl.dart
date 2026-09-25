import '../../domain/repository/connectivity_repository.dart';
import '../data_sources/connectivity_data_source.dart';

class ConnectivityRepositoryImpl implements ConnectivityRepository {
  final ConnectivityDataSource _dataSource;

  ConnectivityRepositoryImpl(this._dataSource);

  @override
  Stream<bool> watch() async* {
    yield await _dataSource.checkConnectivity();
    yield* _dataSource.onConnectivityChanged;
  }
}
