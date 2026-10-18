import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

import '../../../domain/entities/article_content.dart';

/// Converts the content between the domain and the editor.
/// Malformed content opens as an empty document instead of breaking the screen.
Document documentFromContent(ArticleContent content) {
  try {
    final operations = jsonDecode(content.deltaJson) as List;
    return operations.isEmpty ? Document() : Document.fromJson(operations);
  } on Object {
    return Document();
  }
}

ArticleContent contentFromDocument(Document document) {
  return ArticleContent(jsonEncode(document.toDelta().toJson()));
}
