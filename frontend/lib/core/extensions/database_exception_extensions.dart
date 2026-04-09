import 'package:news_app_clean_architecture/core/errors/local_database_exception.dart';
import 'package:sqflite/sqflite.dart';

extension DatabaseExceptionExtensions on DatabaseException {
  LocalDatabaseException get parse {
    if (isDatabaseClosedError()) {
      return LocalDatabaseClosedException(
        message: toString(),
        originalError: this,
      );
    } else if (isDuplicateColumnError()) {
      return LocalDatabaseDuplicateColumnException(
        message: toString(),
        originalError: this,
      );
    } else if (isNoSuchTableError()) {
      return LocalDatabaseNoSuchTableException(
        message: toString(),
        originalError: this,
      );
    } else if (isNotNullConstraintError()) {
      return LocalDatabaseNotNullConstraintException(
        message: toString(),
        originalError: this,
      );
    } else if (isOpenFailedError()) {
      return LocalDatabaseOpenFailedException(
        message: toString(),
        originalError: this,
      );
    } else if (isReadOnlyError()) {
      return LocalDatabaseReadOnlyException(
        message: toString(),
        originalError: this,
      );
    } else if (isSyntaxError()) {
      return LocalDatabaseSyntaxException(
        message: toString(),
        originalError: this,
      );
    } else if (isUniqueConstraintError()) {
      return LocalDatabaseUniqueConstraintException(
        message: toString(),
        originalError: this,
      );
    } else {
      return LocalDatabaseUnknownException(
        message: toString(),
        originalError: this,
      );
    }
  }
}
