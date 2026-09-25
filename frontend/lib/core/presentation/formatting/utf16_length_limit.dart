import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Caps a field at [maxLength] UTF-16 code units: Dart's `String.length`,
/// and the unit Firestore security rules measure strings in (an emoji is 2
/// there). TextField's own `maxLength` counts user-perceived characters
/// instead (an emoji is 1), so text it accepts can still be longer than the
/// rules allow -- measured with a live probe against this project's rules,
/// not assumed. Limiting in the rules' own unit keeps what the form accepts
/// and what the backend accepts the same thing.
///
/// Never cuts a character in half: an over-long paste keeps only the whole
/// characters that fit.
class Utf16LengthLimitingTextInputFormatter extends TextInputFormatter {
  final int maxLength;

  const Utf16LengthLimitingTextInputFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length <= maxLength) return newValue;
    // Text that's already over (loaded from before this limit existed) can
    // still be edited back down; it just can't grow.
    if (newValue.text.length < oldValue.text.length) return newValue;
    if (oldValue.text.length >= maxLength) return oldValue;
    final truncated = _truncate(newValue.text);
    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(
        offset: newValue.selection.end.clamp(0, truncated.length),
      ),
    );
  }

  String _truncate(String text) {
    final buffer = StringBuffer();
    for (final character in text.characters) {
      if (buffer.length + character.length > maxLength) break;
      buffer.write(character);
    }
    return buffer.toString();
  }
}

/// "42/120" under a field limited by [Utf16LengthLimitingTextInputFormatter],
/// counted the same way the limit is (TextField's own counter would count
/// an emoji as 1 and never reach the real limit).
InputCounterWidgetBuilder utf16LengthCounter(
  TextEditingController controller,
  int limit,
) {
  return (
    context, {
    required currentLength,
    required maxLength,
    required isFocused,
  }) {
    final theme = Theme.of(context);
    final length = controller.text.length;
    return Text(
      '$length/$limit',
      style: theme.textTheme.bodySmall?.copyWith(
        color: length > limit
            ? theme.colorScheme.error
            : theme.colorScheme.onSurfaceVariant,
      ),
    );
  };
}
