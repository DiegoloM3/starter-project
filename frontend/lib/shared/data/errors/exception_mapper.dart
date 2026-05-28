import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:news_app_clean_architecture/core/errors/app_exception.dart';

class ExceptionMapper {
  ExceptionMapper._();

  static AppException fromFirebaseException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
      case 'unauthenticated':
        return AuthException(
          message: e.message ?? 'Authentication required',
          code: e.code,
        );
      case 'not-found':
        return NotFoundException(
          message: e.message ?? 'Document not found',
          code: e.code,
        );
      case 'already-exists':
        return ValidationException(
          message: e.message ?? 'Document already exists',
          code: e.code,
        );
      case 'unavailable':
      case 'deadline-exceeded':
        return NetworkException(
          message: e.message ?? 'Service unavailable',
          code: e.code,
        );
      case 'object-not-found':
      case 'unauthorized':
      case 'retry-limit-exceeded':
        return StorageException(
          message: e.message ?? 'Storage operation failed',
          code: e.code,
        );
      default:
        return AppException(
          message: e.message ?? 'Unknown Firebase error',
          code: e.code,
        );
    }
  }

  static AppException fromDioError(DioError e) {
    switch (e.type) {
      case DioErrorType.connectTimeout:
      case DioErrorType.sendTimeout:
      case DioErrorType.receiveTimeout:
        return NetworkException(
          message: 'Connection timeout',
          code: e.type.toString(),
        );
      case DioErrorType.response:
        final statusCode = e.response?.statusCode;
        if (statusCode == 401 || statusCode == 403) {
          return AuthException(
            message: 'Unauthorized',
            code: '$statusCode',
          );
        }
        return NetworkException(
          message: e.response?.statusMessage ?? 'Request failed',
          code: '$statusCode',
        );
      default:
        return NetworkException(
          message: e.message,
          code: e.type.toString(),
        );
    }
  }

  static AppException fromException(Object e) {
    if (e is FirebaseException) return fromFirebaseException(e);
    if (e is DioError) return fromDioError(e);
    if (e is AppException) return e;
    return AppException(message: e.toString(), code: 'unknown');
  }
}
