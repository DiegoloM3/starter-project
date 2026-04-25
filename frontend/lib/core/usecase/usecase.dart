import 'package:dartz/dartz.dart';
import 'package:news_app_clean_architecture/core/error/app_failure.dart';

abstract class UseCase<R, P> {
  const UseCase();
  Future<Either<AppFailure, R>> call(P params);
}

class NoParams {
  const NoParams();
}
