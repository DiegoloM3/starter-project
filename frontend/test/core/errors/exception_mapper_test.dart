import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/errors/app_exception.dart';
import 'package:news_app_clean_architecture/shared/data/errors/exception_mapper.dart';

void main() {
  group('ExceptionMapper.fromFirebaseException', () {
    test('maps permission-denied to AuthException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
        message: 'Access denied',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<AuthException>());
      expect(result.code, 'permission-denied');
    });

    test('maps unauthenticated to AuthException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'unauthenticated',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<AuthException>());
    });

    test('maps not-found to NotFoundException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<NotFoundException>());
    });

    test('maps already-exists to ValidationException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'already-exists',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<ValidationException>());
    });

    test('maps unavailable to NetworkException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'unavailable',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<NetworkException>());
    });

    test('maps deadline-exceeded to NetworkException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'deadline-exceeded',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<NetworkException>());
    });

    test('maps object-not-found to StorageException', () {
      final e = FirebaseException(
        plugin: 'storage',
        code: 'object-not-found',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<StorageException>());
    });

    test('maps unknown code to AppException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'some-unknown-error',
        message: 'Something went wrong',
      );
      final result = ExceptionMapper.fromFirebaseException(e);

      expect(result, isA<AppException>());
      expect(result, isNot(isA<AuthException>()));
      expect(result, isNot(isA<NetworkException>()));
      expect(result.message, 'Something went wrong');
    });
  });

  group('ExceptionMapper.fromDioError', () {
    test('maps connectTimeout to NetworkException', () {
      final e = DioError(
        type: DioErrorType.connectTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<NetworkException>());
      expect(result.message, 'Connection timeout');
    });

    test('maps sendTimeout to NetworkException', () {
      final e = DioError(
        type: DioErrorType.sendTimeout,
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<NetworkException>());
    });

    test('maps 401 response to AuthException', () {
      final e = DioError(
        type: DioErrorType.response,
        response: Response(
          statusCode: 401,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<AuthException>());
      expect(result.code, '401');
    });

    test('maps 403 response to AuthException', () {
      final e = DioError(
        type: DioErrorType.response,
        response: Response(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<AuthException>());
    });

    test('maps 500 response to NetworkException', () {
      final e = DioError(
        type: DioErrorType.response,
        response: Response(
          statusCode: 500,
          statusMessage: 'Internal Server Error',
          requestOptions: RequestOptions(path: '/test'),
        ),
        requestOptions: RequestOptions(path: '/test'),
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<NetworkException>());
      expect(result.message, 'Internal Server Error');
    });

    test('maps other DioError to NetworkException', () {
      final e = DioError(
        type: DioErrorType.other,
        requestOptions: RequestOptions(path: '/test'),
        error: 'Socket error',
      );
      final result = ExceptionMapper.fromDioError(e);

      expect(result, isA<NetworkException>());
    });
  });

  group('ExceptionMapper.fromException', () {
    test('delegates FirebaseException', () {
      final e = FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
      );
      final result = ExceptionMapper.fromException(e);

      expect(result, isA<NotFoundException>());
    });

    test('returns AppException as-is', () {
      const e = AuthException(message: 'test', code: 'test');
      final result = ExceptionMapper.fromException(e);

      expect(identical(result, e), isTrue);
    });

    test('wraps unknown exception in AppException', () {
      final result = ExceptionMapper.fromException(Exception('something'));

      expect(result, isA<AppException>());
      expect(result.code, 'unknown');
    });
  });
}
