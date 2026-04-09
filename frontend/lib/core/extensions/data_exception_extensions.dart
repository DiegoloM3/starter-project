import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/core/errors/network_exception.dart';
import 'package:dio/dio.dart';
import 'package:news_app_clean_architecture/core/extensions/database_exception_extensions.dart';
import 'package:news_app_clean_architecture/core/extensions/dio_exception_extensions.dart';
import 'package:news_app_clean_architecture/core/extensions/firebase_auth_exception_extensions.dart';
import 'package:news_app_clean_architecture/core/extensions/firebase_exception_extensions.dart';
import 'package:sqflite/sqflite.dart';

extension DataExceptionExtensions on Exception {
  Exception get exception {
    if (this is DioException) {
      return (this as DioException).parse;
      //! Always after FirebaseException to avoid parse errors
    } else if (this is FirebaseAuthException) {
      return (this as FirebaseAuthException).parseAuthException;
    } else if (this is FirebaseException) {
      return (this as FirebaseException).parse;
    } else if (this is DatabaseException) {
      return (this as DatabaseException).parse;
    } else {
      return NetworkUnknownException(
          message: 'Unknown error', originalError: this);
    }
  }
}
