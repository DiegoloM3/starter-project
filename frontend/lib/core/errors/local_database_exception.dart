sealed class LocalDatabaseException implements Exception {
  final String message;
  final dynamic originalError;

  const LocalDatabaseException({required this.message, this.originalError});
}

class LocalDatabaseClosedException extends LocalDatabaseException {
  const LocalDatabaseClosedException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseDuplicateColumnException extends LocalDatabaseException {
  const LocalDatabaseDuplicateColumnException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseNoSuchTableException extends LocalDatabaseException {
  const LocalDatabaseNoSuchTableException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseNotNullConstraintException extends LocalDatabaseException {
  const LocalDatabaseNotNullConstraintException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseOpenFailedException extends LocalDatabaseException {
  const LocalDatabaseOpenFailedException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseReadOnlyException extends LocalDatabaseException {
  const LocalDatabaseReadOnlyException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseSyntaxException extends LocalDatabaseException {
  const LocalDatabaseSyntaxException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseUniqueConstraintException extends LocalDatabaseException {
  const LocalDatabaseUniqueConstraintException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}

class LocalDatabaseUnknownException extends LocalDatabaseException {
  const LocalDatabaseUnknownException({
    required String message,
    dynamic originalError,
  }) : super(message: message, originalError: originalError);
}
