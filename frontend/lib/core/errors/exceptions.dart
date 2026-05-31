import 'package:news_app_clean_architecture/core/errors/error_keys.dart';

/// Application-specific exceptions thrown by the data layer.
///
/// **Architecture Pattern:**
/// - **DataSources** throw typed exceptions when operations fail
/// - **Repositories** catch these exceptions and convert them to [Failure] objects
/// - Never catch generic [Exception], always use specific exception types
///
/// **Example Flow:**
/// ```dart
/// // DataSource (throws exception)
/// Future<ArticleModel> getArticle(String id) async {
///   try {
///     final doc = await firestore.collection('articles').doc(id).get();
///     if (!doc.exists) throw CacheException('Article not found');
///     return ArticleModel.fromJson(doc.data()!);
///   } on FirebaseException catch (e) {
///     throw ServerException(message: e.message, statusCode: e.code);
///   }
/// }
///
/// // Repository (catches exception, returns Either<Failure, Data>)
/// ResultFuture<ArticleEntity> getArticle(String id) async {
///   try {
///     final model = await dataSource.getArticle(id);
///     return Right(model.toEntity());
///   } on ServerException catch (e) {
///     return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
///   } on CacheException catch (e) {
///     return Left(CacheFailure(message: e.message));
///   } on NetworkException catch (e) {
///     return Left(NetworkFailure());
///   }
/// }
/// ```

/// Base class for all application exceptions.
///
/// These are thrown by the data layer (datasources) and caught by repositories.
/// Never catch the generic [Exception] class - always use specific exception types.
abstract class AppException implements Exception {
  const AppException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      '$runtimeType: $message${statusCode != null ? ' (code: $statusCode)' : ''}';
}

/// Exception thrown when a server/API call fails.
///
/// Typical causes:
/// - HTTP error responses (4xx, 5xx)
/// - Firebase/Firestore errors
/// - Third-party API failures
///
/// Example:
/// ```dart
/// if (response.statusCode != 200) {
///   throw ServerException(
///     message: 'Failed to fetch data',
///     statusCode: response.statusCode,
///   );
/// }
/// ```
class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});

  /// Create from HTTP status code with a default message.
  factory ServerException.fromStatusCode(
    int statusCode, [
    String? customMessage,
  ]) {
    final message = customMessage ?? _getDefaultMessage(statusCode);
    return ServerException(message: message, statusCode: statusCode);
  }

  static String _getDefaultMessage(int statusCode) {
    return switch (statusCode) {
      400 => ServerErrorKeys.badRequest,
      401 => ServerErrorKeys.unauthorized,
      403 => ServerErrorKeys.forbidden,
      404 => ServerErrorKeys.notFound,
      429 => ServerErrorKeys.tooManyRequests,
      500 => ServerErrorKeys.internalError,
      502 => ServerErrorKeys.badGateway,
      503 => ServerErrorKeys.serviceUnavailable,
      _ => ServerErrorKeys.generic,
    };
  }
}

/// Exception thrown when local storage (cache/database) operations fail.
///
/// Typical causes:
/// - File system errors
/// - Database query failures
/// - Serialization/deserialization errors
/// - Data not found in cache
///
/// Example:
/// ```dart
/// final article = await database.getArticle(id);
/// if (article == null) {
///   throw CacheException('Article not found in local storage');
/// }
/// ```
class CacheException extends AppException {
  const CacheException(String message) : super(message: message);
}

/// Exception thrown when network connectivity fails.
///
/// Typical causes:
/// - No internet connection
/// - Request timeout
/// - DNS resolution failure
///
/// Example:
/// ```dart
/// final isConnected = await connectivity.checkConnectivity();
/// if (!isConnected) {
///   throw NetworkException.noConnection();
/// }
/// ```
class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: NetworkErrorKeys.noConnection,
      statusCode: -1,
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: NetworkErrorKeys.timeout,
      statusCode: -2,
    );
  }
}

/// Exception thrown when authentication operations fail.
///
/// Typical causes:
/// - Invalid credentials
/// - User cancelled authentication (e.g., Google sign-in)
/// - Token expired
/// - Account disabled
///
/// Example:
/// ```dart
/// try {
///   await firebaseAuth.signIn(email, password);
/// } on FirebaseAuthException catch (e) {
///   throw AuthException.fromFirebaseError(e);
/// }
/// ```
class AuthException extends AppException {
  const AuthException({required super.message, super.statusCode});

  /// Creates an [AuthException] from a Firebase Auth error.
  ///
  /// Converts Firebase error codes to user-friendly messages.
  factory AuthException.fromFirebaseError(dynamic error) {
    // Handle cases where error code might be in different formats
    final code = error.code?.toString() ?? '';
    final message = _getFirebaseErrorMessage(code);
    return AuthException(message: message, statusCode: code.hashCode);
  }

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: AuthErrorKeys.invalidCredentials,
      statusCode: 401,
    );
  }

  factory AuthException.userCancelled() {
    return const AuthException(
      message: AuthErrorKeys.userCancelled,
      statusCode: -10,
    );
  }

  factory AuthException.tokenExpired() {
    return const AuthException(
      message: AuthErrorKeys.tokenExpired,
      statusCode: 401,
    );
  }

  /// Returns localization key for Firebase Auth error codes.
  static String _getFirebaseErrorMessage(String code) {
    return switch (code) {
      'user-not-found' => AuthErrorKeys.userNotFound,
      'wrong-password' => AuthErrorKeys.wrongPassword,
      'invalid-email' => AuthErrorKeys.invalidEmail,
      'user-disabled' => AuthErrorKeys.userDisabled,
      'email-already-in-use' => AuthErrorKeys.emailAlreadyInUse,
      'weak-password' => AuthErrorKeys.weakPassword,
      'operation-not-allowed' => AuthErrorKeys.operationNotAllowed,
      'invalid-credential' => AuthErrorKeys.invalidCredentials,
      'account-exists-with-different-credential' => AuthErrorKeys.generic,
      'requires-recent-login' => AuthErrorKeys.tokenExpired,
      'network-request-failed' => NetworkErrorKeys.generic,
      'too-many-requests' => ServerErrorKeys.tooManyRequests,
      _ => AuthErrorKeys.generic,
    };
  }
}

/// Exception thrown when data validation fails.
///
/// Typical causes:
/// - Invalid input format
/// - Missing required fields
/// - Data constraint violations
///
/// Can include field-specific errors for form validation.
///
/// Example:
/// ```dart
/// if (email.isEmpty) {
///   throw ValidationException(
///     message: 'Email is required',
///     fieldErrors: {'email': 'This field is required'},
///   );
/// }
/// ```
class ValidationException extends AppException {
  const ValidationException({required super.message, this.fieldErrors});

  final Map<String, String>? fieldErrors;

  @override
  String toString() {
    final buffer = StringBuffer(super.toString());
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      buffer.write(' - Fields: ${fieldErrors!.keys.join(', ')}');
    }
    return buffer.toString();
  }
}

/// Exception thrown when parsing/serialization fails.
///
/// Typical causes:
/// - Invalid JSON format
/// - Missing required fields in JSON
/// - Type mismatch during deserialization
///
/// Example:
/// ```dart
/// factory ArticleModel.fromJson(Map<String, dynamic> json) {
///   if (!json.containsKey('id')) {
///     throw ParsingException.missingField('id');
///   }
///   // ...
/// }
/// ```
class ParsingException extends AppException {
  const ParsingException({required super.message, super.statusCode});

  factory ParsingException.invalidJson() {
    return const ParsingException(
      message: 'Invalid JSON format',
      statusCode: -100,
    );
  }

  factory ParsingException.missingField(String fieldName) {
    return ParsingException(
      message: 'Missing required field: $fieldName',
      statusCode: -101,
    );
  }

  factory ParsingException.typeMismatch(String fieldName, String expectedType) {
    return ParsingException(
      message: 'Type mismatch for field "$fieldName": expected $expectedType',
      statusCode: -102,
    );
  }
}
