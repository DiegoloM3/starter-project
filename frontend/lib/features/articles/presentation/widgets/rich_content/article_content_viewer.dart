import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../domain/entities/article_content.dart';
import 'article_document.dart';
import 'image_embed_builder.dart';

/// Read only rich text of an article.
class ArticleContentViewer extends StatefulWidget {
  final ArticleContent content;

  const ArticleContentViewer({super.key, required this.content});

  @override
  State<ArticleContentViewer> createState() => _ArticleContentViewerState();
}

class _ArticleContentViewerState extends State<ArticleContentViewer> {
  late QuillController _controller = _buildController();

  @override
  void didUpdateWidget(ArticleContentViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content == widget.content) return;
    _controller.dispose();
    _controller = _buildController();
  }

  QuillController _buildController() {
    return QuillController(
      document: documentFromContent(widget.content),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return QuillEditor.basic(
      controller: _controller,
      config: const QuillEditorConfig(scrollable: false, showCursor: false, embedBuilders: [ImageEmbedBuilder()]),
    );
  }
}
