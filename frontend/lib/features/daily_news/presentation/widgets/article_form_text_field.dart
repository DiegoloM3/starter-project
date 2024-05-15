import 'package:flutter/material.dart';

class ArticleFormTextField extends StatelessWidget {
  final String labelText;
  final String validationMessage;
  final TextInputType? keyboardType;
  final bool? autofoucs;
  final TextEditingController controller;

  const ArticleFormTextField({
    super.key,
    required this.labelText,
    required this.validationMessage,
    required this.controller,
    this.keyboardType,
    this.autofoucs,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      autofocus: autofoucs ?? false,
      textCapitalization: TextCapitalization.sentences,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        return null;
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: labelText,
      ),
      keyboardType: keyboardType ?? TextInputType.text,
    );
  }
}
