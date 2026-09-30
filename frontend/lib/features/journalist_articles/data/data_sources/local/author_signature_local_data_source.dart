import 'package:shared_preferences/shared_preferences.dart';

/// Device storage for the journalist's signature.
class AuthorSignatureLocalDataSource {
  static const String _authorNameKey = 'journalist_articles.author_name';

  final SharedPreferences _preferences;

  AuthorSignatureLocalDataSource(this._preferences);

  String? readAuthorName() => _preferences.getString(_authorNameKey);

  /// Throws an [Exception] when the device refuses to store the value.
  Future<void> writeAuthorName(String authorName) async {
    final isStored = await _preferences.setString(_authorNameKey, authorName);
    if (!isStored) throw Exception('The signature could not be saved on this device');
  }
}
