import 'package:google_sign_in/google_sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/data/data_sources/remote/google_sign_in_service.dart';

/// Concrete implementation of [GoogleSignInService] wrapping [GoogleSignIn].
class GoogleSignInServiceImpl implements GoogleSignInService {
  final GoogleSignIn _googleSignIn;

  GoogleSignInServiceImpl(this._googleSignIn);

  @override
  Future<GoogleSignInAccount?> signIn() => _googleSignIn.signIn();

  @override
  Future<GoogleSignInAuthentication> getAuthentication(
    GoogleSignInAccount account,
  ) =>
      account.authentication;

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
