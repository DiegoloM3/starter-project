import 'package:flutter/material.dart';

enum ButtonType {
  normal,
  alternative,
  negative;

  bool get isAlternative => this == ButtonType.alternative;
  bool get isNegative => this == ButtonType.negative;

  ButtonStyle getOptionButtonStyle(ThemeData theme) {
    switch (this) {
      case ButtonType.normal:
        return ButtonStyle(
          textColor: theme.colorScheme.primaryContainer,
          backgroundColor: theme.colorScheme.onPrimaryContainer,
          borderColor: theme.colorScheme.onPrimaryContainer,
        );
      case ButtonType.negative:
        return ButtonStyle(
          textColor: theme.colorScheme.error,
          backgroundColor: theme.colorScheme.errorContainer,
          borderColor: theme.colorScheme.errorContainer,
        );
      case ButtonType.alternative:
        return ButtonStyle(
          textColor: theme.colorScheme.onPrimaryContainer,
          backgroundColor: theme.colorScheme.primaryContainer,
          borderColor: theme.colorScheme.primaryContainer,
        );
    }
  }

  ButtonStyle getButtonStyle(ThemeData theme) {
    switch (this) {
      case ButtonType.normal:
        return ButtonStyle(
          textColor: theme.colorScheme.surface,
          backgroundColor: theme.primaryColor,
          borderColor: theme.primaryColor,
        );
      case ButtonType.alternative:
        return ButtonStyle(
          textColor: theme.primaryColor,
          backgroundColor: theme.colorScheme.surface,
          borderColor: theme.primaryColor,
        );
      case ButtonType.negative:
        return ButtonStyle(
          textColor: theme.colorScheme.errorContainer,
          backgroundColor: theme.colorScheme.error,
          borderColor: theme.colorScheme.errorContainer,
        );
    }
  }
}

class ButtonStyle {
  const ButtonStyle({
    required this.textColor,
    required this.backgroundColor,
    required this.borderColor,
  });

  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
}
