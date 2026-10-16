import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../config/theme/app_design_tokens.dart';

/// Text input drawn as the bordered boxes of the publishing screen.
/// It fills the height given by its parent.
class OutlinedTextArea extends StatelessWidget {
  final String hintText;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final int maxLength;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool _isOutlined;

  const OutlinedTextArea({
    Key? key,
    required this.hintText,
    required this.textStyle,
    required this.hintStyle,
    required this.maxLength,
    required this.onChanged,
    this.hasError = false,
    this.controller,
  })  : focusNode = null,
        _isOutlined = true,
        super(key: key);

  /// The same input without its border, for parents that draw it around
  /// more widgets than the input.
  const OutlinedTextArea.borderless({
    Key? key,
    required this.hintText,
    required this.textStyle,
    required this.hintStyle,
    required this.maxLength,
    required this.onChanged,
    this.controller,
    this.focusNode,
  })  : hasError = false,
        _isOutlined = false,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      expands: true,
      maxLines: null,
      maxLength: maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: textStyle,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        counterText: '',
        contentPadding: _isOutlined ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        enabledBorder: _buildBorder(hasError ? AppColors.error : AppColors.inputBorder),
        focusedBorder: _buildBorder(hasError ? AppColors.error : AppColors.darkText),
      ),
    );
  }

  InputBorder _buildBorder(Color color) {
    if (!_isOutlined) {
      return InputBorder.none;
    }
    return OutlineInputBorder(
      borderRadius: AppRadius.standard,
      borderSide: BorderSide(color: color),
    );
  }
}
