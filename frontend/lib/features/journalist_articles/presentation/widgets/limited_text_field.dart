import 'package:flutter/material.dart';

import 'length_counter.dart';

/// Outlined text field with a live character counter and an optional error message.
class LimitedTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final int maxLength;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final bool enabled;
  final TextStyle? style;
  final int? maxLines;

  const LimitedTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.maxLength,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
    this.style,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      enabled: enabled,
      style: style,
      maxLines: maxLines,
      minLines: 1,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        errorText: errorText,
        errorMaxLines: 2,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        counter: LengthCounter(controller: controller, maxLength: maxLength),
      ),
    );
  }
}
