import 'dart:convert';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/entities/article_draft.dart';
import '../../../domain/entities/article_thumbnail.dart';
import '../../models/article_draft.dart';

/// Device storage for the draft being written. The texts go to the app preferences, and the
/// thumbnail is copied to [_thumbnailDirectory]: the image picker's copy lives in a temporary
/// folder the system may empty. The copy is stored by file name only, because iOS moves the app
/// folder to a new path with every app update.
class ArticleDraftLocalDataSource {
  static const String _draftKey = 'journalist_articles.draft';

  final SharedPreferences _preferences;
  final Directory _thumbnailDirectory;

  /// Picked image path → its copy, so the image is copied once and not on every save.
  final Map<String, String> _thumbnailCopies = {};

  ArticleDraftLocalDataSource(this._preferences, this._thumbnailDirectory);

  /// The saved draft, or `null`. A thumbnail whose file is gone is left out.
  /// Throws a [FormatException] when the stored draft is corrupted.
  ArticleDraftModel? readDraft() {
    final json = _preferences.getString(_draftKey);
    if (json == null) return null;
    final rawData = jsonDecode(json);
    if (rawData is! Map<String, dynamic>) throw const FormatException('Stored draft is not an object');
    final stored = ArticleDraftModel.fromRawData(rawData);
    return _draftWithThumbnail(stored, _restoredThumbnail(stored.thumbnail));
  }

  /// Throws an [Exception] when the draft cannot be stored.
  Future<void> writeDraft(ArticleDraftEntity draft) async {
    final thumbnail = await _keptThumbnail(draft.thumbnail);
    final stored = _draftWithThumbnail(draft, thumbnail == null ? null : _byFileName(thumbnail));
    final isStored = await _preferences.setString(_draftKey, jsonEncode(ArticleDraftModel.rawDataOf(stored)));
    if (!isStored) throw Exception('The draft could not be saved on this device');
  }

  Future<void> deleteDraft() async {
    await _preferences.remove(_draftKey);
    await _deleteThumbnailCopies();
  }

  ArticleDraftModel _draftWithThumbnail(ArticleDraftEntity draft, ArticleThumbnailEntity? thumbnail) {
    return ArticleDraftModel(title: draft.title, content: draft.content, author: draft.author, thumbnail: thumbnail);
  }

  ArticleThumbnailEntity _byFileName(ArticleThumbnailEntity thumbnail) {
    final fileName = thumbnail.localPath.split('/').last;
    return ArticleThumbnailEntity(localPath: fileName, sizeInBytes: thumbnail.sizeInBytes);
  }

  ArticleThumbnailEntity? _restoredThumbnail(ArticleThumbnailEntity? stored) {
    if (stored == null) return null;
    final file = File('${_thumbnailDirectory.path}/${stored.localPath}');
    if (!file.existsSync()) return null;
    return ArticleThumbnailEntity(localPath: file.path, sizeInBytes: stored.sizeInBytes);
  }

  Future<ArticleThumbnailEntity?> _keptThumbnail(ArticleThumbnailEntity? thumbnail) async {
    if (thumbnail == null || thumbnail.localPath.startsWith(_thumbnailDirectory.path)) return thumbnail;
    final copyPath = _thumbnailCopies[thumbnail.localPath] ?? await _copyThumbnail(thumbnail);
    return ArticleThumbnailEntity(localPath: copyPath, sizeInBytes: thumbnail.sizeInBytes);
  }

  /// Replaces the previous copy. Each copy gets a new name, so no screen shows a cached old image.
  Future<String> _copyThumbnail(ArticleThumbnailEntity thumbnail) async {
    await _deleteThumbnailCopies();
    await _thumbnailDirectory.create(recursive: true);
    final name = 'thumbnail-${DateTime.now().microsecondsSinceEpoch}.${thumbnail.extension}';
    final copy = await File(thumbnail.localPath).copy('${_thumbnailDirectory.path}/$name');
    _thumbnailCopies[thumbnail.localPath] = copy.path;
    return copy.path;
  }

  Future<void> _deleteThumbnailCopies() async {
    _thumbnailCopies.clear();
    if (await _thumbnailDirectory.exists()) await _thumbnailDirectory.delete(recursive: true);
  }
}
