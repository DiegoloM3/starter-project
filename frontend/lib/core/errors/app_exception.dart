abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, this.code);

  @override
  String toString() => '$code: $message';
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
      : super(message, 'network_error');
}

class ApiException extends AppException {
  const ApiException([String message = 'API request failed'])
      : super(message, 'api_error');
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException([String message = 'Permission denied'])
      : super(message, 'permission_denied');
}

class UserNotFoundException extends AppException {
  const UserNotFoundException([String message = 'User not found'])
      : super(message, 'user_not_found');
}

class NotAuthenticatedException extends AppException {
  const NotAuthenticatedException([String message = 'User not authenticated'])
      : super(message, 'not_authenticated');
}

class ResourceNotFoundException extends AppException {
  const ResourceNotFoundException([String message = 'Resource not found'])
      : super(message, 'resource_not_found');
}

class StorageUploadException extends AppException {
  const StorageUploadException([String message = 'Image upload failed'])
      : super(message, 'storage_upload_error');
}

class DatabaseException extends AppException {
  const DatabaseException([String message = 'Database operation failed'])
      : super(message, 'database_error');
}

class UnknownAppException extends AppException {
  const UnknownAppException([String message = 'Unexpected error'])
      : super(message, 'unknown_error');
}
