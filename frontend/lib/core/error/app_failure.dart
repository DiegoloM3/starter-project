import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_failure.freezed.dart';

@freezed
class AppFailure with _$AppFailure {
  const factory AppFailure.network({
    String? message,
    int? statusCode,
  }) = NetworkFailure;

  const factory AppFailure.cache({String? message}) = CacheFailure;

  const factory AppFailure.validation({
    required String field,
    required String reason,
  }) = ValidationFailure;

  const factory AppFailure.auth({String? message}) = AuthFailure;

  const factory AppFailure.unknown({
    Object? cause,
    StackTrace? stackTrace,
  }) = UnknownFailure;
}
