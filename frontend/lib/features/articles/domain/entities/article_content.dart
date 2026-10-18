import 'dart:convert';

import 'package:equatable/equatable.dart';

/// Rich text of an article, stored as Quill Delta JSON: a list of operations
/// such as `{"insert": "Hello", "attributes": {"bold": true}}`.
///
/// This class keeps the business logic that depends on the text itself
/// (emptiness, word count) independent from the editor package.
class ArticleContent extends Equatable {
  final String deltaJson;

  const ArticleContent(this.deltaJson);

  factory ArticleContent.fromPlainText(String text) {
    return ArticleContent(jsonEncode([
      {'insert': '$text\n'},
    ]));
  }

  String get plainText => _textInserts().join();

  bool get isEmpty => plainText.trim().isEmpty;

  int get wordCount => plainText.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  // Images and other embeds are maps instead of strings, so they are skipped.
  Iterable<String> _textInserts() {
    final operations = _decodeOperations();
    return operations.whereType<Map>().map((operation) => operation['insert']).whereType<String>();
  }

  List<dynamic> _decodeOperations() {
    try {
      final decoded = jsonDecode(deltaJson);
      return decoded is List ? decoded : const [];
    } on FormatException {
      return const [];
    }
  }

  @override
  List<Object?> get props => [deltaJson];
}
