import 'package:flutter/material.dart';

enum TextFieldType {
  initial,
  alternative,
  outline,
  none;

  bool get isNone => this == TextFieldType.none;

  TextFieldStyle getStyle(ThemeData theme) {
    switch (this) {
      case TextFieldType.initial:
        return TextFieldStyle(
          textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
          backgroundColor: Colors.white,
          borderColor: Colors.transparent,
          iconColor: theme.primaryColor,
        );
      case TextFieldType.alternative:
        return TextFieldStyle(
          textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
          backgroundColor: theme.colorScheme.secondaryContainer,
          borderColor: Colors.transparent,
          iconColor: theme.colorScheme.onSecondaryContainer,
        );
      case TextFieldType.outline:
        return TextFieldStyle(
          textColor: theme.textTheme.bodyLarge?.color ?? Colors.white,
          backgroundColor: Colors.white,
          borderColor: theme.primaryColor,
          iconColor: theme.primaryColor,
        );
      case TextFieldType.none:
        return const TextFieldStyle(
          textColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          borderColor: Colors.transparent,
          iconColor: Colors.transparent,
        );
    }
  }
}

class TextFieldStyle {
  const TextFieldStyle({
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
  });

  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
}
