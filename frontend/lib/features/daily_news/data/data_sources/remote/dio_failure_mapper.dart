import 'dart:io';

import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

/// Translates transport errors from Dio into domain [Failure]s. Lives with
/// the data source because it is the only other place that knows Dio.
abstract final class DioFailureMapper {
  static Failure map(Object error) {
    if (error is! DioException) return const Failure.unknown();
    final exception = error;
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.connectionError:
        return const Failure.network();
      case DioExceptionType.badResponse:
        return _fromStatus(exception.response?.statusCode);
      case DioExceptionType.cancel:
        return const Failure.cancelled();
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        if (exception.error is SocketException) {
          return const Failure.network();
        }
        return Failure.unknown(exception.message ?? 'Unexpected network error.');
    }
  }

  static Failure _fromStatus(int? statusCode) {
    switch (statusCode) {
      case HttpStatus.unauthorized:
      case HttpStatus.forbidden:
        return const Failure.permissionDenied('The news provider rejected the request.');
      case HttpStatus.notFound:
        return const Failure.notFound();
      case HttpStatus.tooManyRequests:
        return const Failure.server('Too many requests. Try again in a moment.');
      default:
        return const Failure.server();
    }
  }
}
