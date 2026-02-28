import 'dart:io';

import 'package:firebase_core/firebase_core.dart';

import 'app_exception.dart';

AppException mapException(Object e) {
  if (e is AppException) return e;
  if (e is FirebaseException) return mapFirebaseException(e);
  if (e is SocketException) return const NetworkException();
  if (e.toString().toLowerCase().contains('socket')) {
    return const NetworkException();
  }
  return UnknownAppException(e.toString());
}

AppException mapFirebaseException(FirebaseException e) {
  switch (e.code) {
    case 'permission-denied':
      return PermissionDeniedException(e.message ?? 'Permission denied');
    case 'not-found':
      return ResourceNotFoundException(e.message ?? 'Resource not found');
    case 'unauthenticated':
      return NotAuthenticatedException(e.message ?? 'Not authenticated');
    case 'user-not-found':
      return UserNotFoundException(e.message ?? 'User not found');
    default:
      return DatabaseException(e.message ?? 'Firebase operation failed');
  }
}
