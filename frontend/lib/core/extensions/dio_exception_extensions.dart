import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';

extension DioExceptionExtensions on DioException {
  NetworkException get parse => switch (type) {
        DioExceptionType.connectionTimeout => NetworkTimeoutException(
            message: 'Connection timeout with the server',
            originalError: this,
          ),
        DioExceptionType.sendTimeout => NetworkTimeoutException(
            message: 'Send timeout in connection with the server',
            originalError: this,
          ),
        DioExceptionType.receiveTimeout => NetworkTimeoutException(
            message: 'Receive timeout in connection with the server',
            originalError: this,
          ),
        DioExceptionType.cancel => NetworkCancelException(
            originalError: this,
          ),
        DioExceptionType.connectionError => NetworkNoInternetException(
            originalError: this,
          ),
        DioExceptionType.badResponse =>
          NetworkException.handleBadResponse(this),
        _ => NetworkUnknownException(
            message: 'An unexpected network error occurred',
            originalError: this,
          ),
      };
}
