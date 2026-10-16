import 'package:flutter/material.dart';

import '../../../../config/theme/app_design_tokens.dart';
import 'formatting_toolbar.dart';
import 'markdown_editing_controller.dart';
import 'markdown_formatting.dart';
import 'outlined_text_area.dart';

/// Box to write the content of an article, with a toolbar inside its border
/// to add bold text and subheadings, which are shown formatted while typing. It fills the height given by its parent.
class ArticleContentEditor extends StatefulWidget {
  final String hintText;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final int maxLength;
  final bool hasError;
  final ValueChanged<String> onChanged;

  const ArticleContentEditor({
    Key? key,
    required this.hintText,
    required this.textStyle,
    required this.hintStyle,
    required this.maxLength,
    required this.onChanged,
    this.hasError = false,
  }) : super(key: key);

  @override
  State<ArticleContentEditor> createState() => _ArticleContentEditorState();
}

class _ArticleContentEditorState extends State<ArticleContentEditor> {
  final MarkdownEditingController _controller = MarkdownEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onEditorChanged);
    _controller.addListener(_onEditorChanged);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.standard,
        border: Border.all(color: _selectBorderColor()),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormattingToolbar(
            isBoldActive: MarkdownFormatting.isBold(_controller.value),
            isSubheadingActive: MarkdownFormatting.isSubheading(_controller.value),
            onBoldPressed: () => _applyFormatting(MarkdownFormatting.toggleBold),
            onSubheadingPressed: () => _applyFormatting(MarkdownFormatting.toggleSubheading),
          ),
          const Divider(height: 1, thickness: 1, color: AppColors.inputBorder),
          Expanded(
            child: OutlinedTextArea.borderless(
              controller: _controller,
              focusNode: _focusNode,
              hintText: widget.hintText,
              textStyle: widget.textStyle,
              hintStyle: widget.hintStyle,
              maxLength: widget.maxLength,
              onChanged: widget.onChanged,
            ),
          ),
        ],
      ),
    );
  }

  /// Same colors as the borders of the other fields of the screen.
  Color _selectBorderColor() {
    if (widget.hasError) {
      return AppColors.error;
    }
    return _focusNode.hasFocus ? AppColors.darkText : AppColors.inputBorder;
  }

  /// Updates the border and the highlighted buttons.
  void _onEditorChanged() {
    setState(() {});
  }

  /// Formats the text unless the result would exceed the maximum length.
  void _applyFormatting(TextEditingValue Function(TextEditingValue value) format) {
    final formattedValue = format(_controller.value);
    if (formattedValue.text.length > widget.maxLength) return;
    _controller.value = formattedValue;
    widget.onChanged(formattedValue.text);
  }
}
