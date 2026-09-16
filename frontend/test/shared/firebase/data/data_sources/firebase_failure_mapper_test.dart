import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/core/resources/failure.dart';
import 'package:news_app_clean_architecture/shared/firebase/data/data_sources/firebase_failure_mapper.dart';

void main() {
  FailureType typeOf(Object error) => FirebaseFailureMapper.map(error).type;

  test('auth codes map to the credential failures the forms understand', () {
    expect(typeOf(FirebaseAuthException(code: 'user-not-found')), FailureType.invalidCredentials);
    expect(typeOf(FirebaseAuthException(code: 'invalid-credential')), FailureType.invalidCredentials);
    expect(typeOf(FirebaseAuthException(code: 'email-already-in-use')), FailureType.emailAlreadyInUse);
    expect(typeOf(FirebaseAuthException(code: 'weak-password')), FailureType.weakPassword);
    expect(typeOf(FirebaseAuthException(code: 'network-request-failed')), FailureType.network);
    expect(typeOf(FirebaseAuthException(code: 'something-new')), FailureType.unknown);
  });

  test('Firestore and Storage codes map to permission, not-found, network or server', () {
    expect(typeOf(FirebaseException(plugin: 'x', code: 'permission-denied')), FailureType.permissionDenied);
    expect(typeOf(FirebaseException(plugin: 'x', code: 'unauthorized')), FailureType.permissionDenied);
    expect(typeOf(FirebaseException(plugin: 'x', code: 'object-not-found')), FailureType.notFound);
    expect(typeOf(FirebaseException(plugin: 'x', code: 'unavailable')), FailureType.network);
    expect(typeOf(FirebaseException(plugin: 'x', code: 'unauthenticated')), FailureType.unauthenticated);
    expect(typeOf(FirebaseException(plugin: 'x', code: 'internal')), FailureType.server);
  });

  test('a dismissed Google picker is cancelled; sockets are network; the rest unknown', () {
    expect(
      typeOf(const GoogleSignInException(code: GoogleSignInExceptionCode.canceled)),
      FailureType.cancelled,
    );
    expect(
      typeOf(const GoogleSignInException(code: GoogleSignInExceptionCode.unknownError)),
      FailureType.unknown,
    );
    expect(typeOf(const SocketException('offline')), FailureType.network);
    expect(typeOf(StateError('x')), FailureType.unknown);
  });
}
