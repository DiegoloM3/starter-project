import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../rich_content/image_embed_builder.dart';

/// Mid grey, readable under both the black text of the light theme and the white text of the dark one.
const String _highlightColor = '#808080';

/// Rich text editor area of an article. The toolbar is built separately so it can stay above the keyboard.
class ArticleContentEditor extends StatelessWidget {
  final QuillController controller;
  final String? errorText;

  const ArticleContentEditor({super.key, required this.controller, this.errorText});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: errorText == null ? colorScheme.outline : colorScheme.error)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 240),
        child: QuillEditor.basic(
          controller: controller,
          config: const QuillEditorConfig(
            scrollable: false,
            padding: EdgeInsets.all(12),
            placeholder: 'Escribe tu artículo…',
            embedBuilders: [ImageEmbedBuilder()],
          ),
        ),
      ),
    );
  }
}

/// Bold, italic, headings, lists, quotes, highlight and images. Other formats are hidden
/// to keep the style of the articles consistent.
class ArticleContentToolbar extends StatelessWidget {
  final QuillController controller;
  final VoidCallback onInsertImage;
  final bool isUploadingImage;

  const ArticleContentToolbar({
    super.key,
    required this.controller,
    required this.onInsertImage,
    required this.isUploadingImage,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline))),
      child: QuillSimpleToolbar(
        controller: controller,
        config: QuillSimpleToolbarConfig(
          multiRowsDisplay: false,
          showDividers: false,
          showFontFamily: false,
          showFontSize: false,
          showStrikeThrough: false,
          showInlineCode: false,
          showColorButton: false,
          showBackgroundColorButton: false,
          showClearFormat: false,
          showListCheck: false,
          showCodeBlock: false,
          showIndent: false,
          showLink: false,
          showSearchButton: false,
          showSubscript: false,
          showSuperscript: false,
          showUnderLineButton: false,
          customButtons: [
            QuillToolbarCustomButtonOptions(
              icon: const Icon(Icons.border_color_outlined),
              tooltip: 'Resaltar',
              onPressed: _toggleHighlight,
            ),
            QuillToolbarCustomButtonOptions(
              icon:
                  isUploadingImage
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.image_outlined),
              tooltip: 'Insertar imagen',
              onPressed: isUploadingImage ? null : onInsertImage,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleHighlight() {
    final isHighlighted = controller.getSelectionStyle().attributes.containsKey(Attribute.background.key);
    controller.formatSelection(isHighlighted ? Attribute.background : const BackgroundAttribute(_highlightColor));
  }
}

extension InsertImage on QuillController {
  /// Replaces the selected text, if any, with the image.
  void insertImage(String imageURL) {
    final index = selection.baseOffset < 0 ? document.length - 1 : selection.start;
    final length = selection.baseOffset < 0 ? 0 : selection.end - selection.start;
    replaceText(index, length, BlockEmbed.image(imageURL), TextSelection.collapsed(offset: index + 1));
  }
}
