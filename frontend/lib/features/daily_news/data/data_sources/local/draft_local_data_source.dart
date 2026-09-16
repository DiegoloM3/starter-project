import 'dart:convert';
import 'dart:io';

import 'package:news_app_clean_architecture/features/daily_news/data/models/saved_draft_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists one draft per account as a JSON string in the platform key-value
/// store; the scope (the account id) is part of the key.
class DraftLocalDataSource {
  final SharedPreferences _preferences;
  final bool Function(String path) _fileExists;

  /// [fileExists] is only overridden by tests; on a device it asks the file
  /// system, because the picker's copy of a photo can be cleaned up between
  /// two visits to the Write screen.
  DraftLocalDataSource(this._preferences, {bool Function(String path)? fileExists})
      : _fileExists = fileExists ?? _existsOnDisk;

  static bool _existsOnDisk(String path) => File(path).existsSync();

  /// Whether the photo a draft points at is still on the device.
  bool imageExists(String path) => _fileExists(path);

  static const String key = 'draft.article';

  static String scopedKey(String scope) => '$scope.$key';

  /// `null` when nothing is stored or the stored text is not a draft document.
  SavedDraftModel? read(String scope) {
    final raw = _preferences.getString(scopedKey(scope));
    if (raw == null) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? SavedDraftModel.fromJson(decoded) : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> write(String scope, SavedDraftModel model) =>
      _preferences.setString(scopedKey(scope), jsonEncode(model.toJson()));

  Future<void> delete(String scope) => _preferences.remove(scopedKey(scope));
}
