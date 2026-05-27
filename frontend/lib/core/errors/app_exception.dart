import 'package:equatable/equatable.dart';

class AppException extends Equatable implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => 'AppException(code: $code, message: $message)';
}

class NetworkException extends AppException {
  const NetworkException({required String message, String? code})
      : super(message: message, code: code);
}

class AuthException extends AppException {
  const AuthException({required String message, String? code})
      : super(message: message, code: code);
}

class StorageException extends AppException {
  const StorageException({required String message, String? code})
      : super(message: message, code: code);
}

class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    this.fieldErrors,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

class NotFoundException extends AppException {
  const NotFoundException({required String message, String? code})
      : super(message: message, code: code);
}
