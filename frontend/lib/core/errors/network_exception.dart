import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

sealed class NetworkException extends Equatable implements Exception {
  final String message;
  final dynamic originalError;

  const NetworkException({required this.message, this.originalError});

  static NetworkException handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;

    return switch (statusCode) {
      400 => NetworkBadRequestException(originalError: e),
      401 => NetworkUnauthorizedException(originalError: e),
      403 => NetworkForbiddenException(originalError: e),
      404 => NetworkNotFoundException(originalError: e),
      500 => NetworkServerException(originalError: e),
      502 => NetworkServerException(originalError: e),
      _ => NetworkUnknownException(
          message: 'Server returned an error with status code: $statusCode',
          originalError: e,
        ),
    };
  }

  @override
  List<Object?> get props => [message, originalError];
}

class NetworkTimeoutException extends NetworkException {
  const NetworkTimeoutException({required super.message, super.originalError});
}

class NetworkNoInternetException extends NetworkException {
  const NetworkNoInternetException({super.originalError})
      : super(message: 'No internet connection');
}

class NetworkUnauthorizedException extends NetworkException {
  const NetworkUnauthorizedException({super.originalError})
      : super(message: 'Unauthorized access');
}

class NetworkForbiddenException extends NetworkException {
  const NetworkForbiddenException({super.originalError})
      : super(message: 'Forbidden access');
}

class NetworkNotFoundException extends NetworkException {
  const NetworkNotFoundException({super.originalError})
      : super(message: 'Resource not found');
}

class NetworkBadRequestException extends NetworkException {
  const NetworkBadRequestException({super.originalError})
      : super(message: 'Bad request');
}

class NetworkConflictException extends NetworkException {
  const NetworkConflictException({super.originalError})
      : super(message: 'The resource already exists');
}

class NetworkServerException extends NetworkException {
  const NetworkServerException({super.originalError})
      : super(message: 'Internal server error');
}

class NetworkCancelException extends NetworkException {
  const NetworkCancelException({super.originalError})
      : super(message: 'Request to the server was cancelled');
}

class NetworkUnknownException extends NetworkException {
  const NetworkUnknownException({required super.message, super.originalError});
}
