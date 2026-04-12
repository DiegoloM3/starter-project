import 'package:news_app_clean_architecture/core/resources/error_type.dart';

sealed class Failure {
  final ErrorType type;

  const Failure(this.type);
}

class ServerFailure extends Failure {
  const ServerFailure() : super(ErrorType.server);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super(ErrorType.network);
}

class StorageFailure extends Failure {
  const StorageFailure() : super(ErrorType.storage);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure() : super(ErrorType.notFound);
}

class UnknownFailure extends Failure {
  const UnknownFailure() : super(ErrorType.unknown);
}
