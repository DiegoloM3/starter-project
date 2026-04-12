import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/mappers/failure_mapper.dart';

void main() {
  group('mapDioFailure', () {
    test('connectionTimeout returns NetworkFailure', () {
      final exception = DioException(
        type: DioExceptionType.connectionTimeout,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<NetworkFailure>());
    });

    test('receiveTimeout returns NetworkFailure', () {
      final exception = DioException(
        type: DioExceptionType.receiveTimeout,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<NetworkFailure>());
    });

    test('sendTimeout returns NetworkFailure', () {
      final exception = DioException(
        type: DioExceptionType.sendTimeout,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<NetworkFailure>());
    });

    test('connectionError returns NetworkFailure', () {
      final exception = DioException(
        type: DioExceptionType.connectionError,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<NetworkFailure>());
    });

    test('badResponse returns ServerFailure', () {
      final exception = DioException(
        type: DioExceptionType.badResponse,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<ServerFailure>());
    });

    test('cancel returns ServerFailure', () {
      final exception = DioException(
        type: DioExceptionType.cancel,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<ServerFailure>());
    });

    test('unknown returns ServerFailure', () {
      final exception = DioException(
        type: DioExceptionType.unknown,
        requestOptions: RequestOptions(),
      );

      expect(mapDioFailure(exception), isA<ServerFailure>());
    });
  });

  group('mapFirebaseFailure', () {
    test('SocketException returns NetworkFailure', () {
      const exception = SocketException('no network');

      expect(mapFirebaseFailure(exception), isA<NetworkFailure>());
    });

    test('FirebaseException with not-found code returns NotFoundFailure', () {
      final exception = FirebaseException(
        plugin: 'firestore',
        code: 'not-found',
      );

      expect(mapFirebaseFailure(exception), isA<NotFoundFailure>());
    });

    test('FirebaseException with other code returns ServerFailure', () {
      final exception = FirebaseException(
        plugin: 'firestore',
        code: 'permission-denied',
      );

      expect(mapFirebaseFailure(exception), isA<ServerFailure>());
    });

    test('other Exception returns StorageFailure', () {
      final exception = FormatException('bad data');

      expect(mapFirebaseFailure(exception), isA<StorageFailure>());
    });
  });
}
