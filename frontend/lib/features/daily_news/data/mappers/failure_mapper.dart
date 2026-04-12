import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';

Failure mapDioFailure(DioException e) {
  return switch (e.type) {
    DioExceptionType.connectionTimeout ||
    DioExceptionType.receiveTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.connectionError =>
      const NetworkFailure(),
    _ => const ServerFailure(),
  };
}

Failure mapFirebaseFailure(Exception e) {
  if (e is SocketException) return const NetworkFailure();
  if (e is FirebaseException && e.code == 'not-found') {
    return const NotFoundFailure();
  }
  if (e is FirebaseException) return const ServerFailure();
  return const StorageFailure();
}
