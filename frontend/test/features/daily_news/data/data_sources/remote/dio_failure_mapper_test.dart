import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/dio_failure_mapper.dart';

void main() {
  final options = RequestOptions(path: '/');

  DioException error(DioExceptionType type, {int? status, Object? cause}) {
    return DioException(
      requestOptions: options,
      type: type,
      error: cause,
      response: status == null ? null : Response(requestOptions: options, statusCode: status),
    );
  }

  group('DioFailureMapper.map', () {
    test('every timeout and connection error is a network failure', () {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.sendTimeout,
        DioExceptionType.receiveTimeout,
        DioExceptionType.transformTimeout,
        DioExceptionType.connectionError,
      ]) {
        expect(DioFailureMapper.map(error(type)).type, FailureType.network, reason: type.name);
      }
    });

    test('an unknown error wrapping a SocketException is a network failure', () {
      final failure = DioFailureMapper.map(
        error(DioExceptionType.unknown, cause: const SocketException('offline')),
      );
      expect(failure.type, FailureType.network);
    });

    test('other unknown errors stay unknown', () {
      expect(DioFailureMapper.map(error(DioExceptionType.unknown)).type, FailureType.unknown);
      expect(
        DioFailureMapper.map(error(DioExceptionType.badCertificate)).type,
        FailureType.unknown,
      );
    });

    test('cancel maps to cancelled', () {
      expect(DioFailureMapper.map(error(DioExceptionType.cancel)).type, FailureType.cancelled);
    });

    group('bad responses', () {
      test('401 and 403 are permission failures', () {
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse, status: 401)).type,
            FailureType.permissionDenied);
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse, status: 403)).type,
            FailureType.permissionDenied);
      });

      test('404 is not found', () {
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse, status: 404)).type,
            FailureType.notFound);
      });

      test('429 and 5xx are server failures', () {
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse, status: 429)).type,
            FailureType.server);
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse, status: 503)).type,
            FailureType.server);
      });

      test('a bad response without a status is a server failure', () {
        expect(DioFailureMapper.map(error(DioExceptionType.badResponse)).type, FailureType.server);
      });
    });
  });
}
