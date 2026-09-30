import 'package:flutter/material.dart';

import '../../../../l10n/l10n.dart';

/// Live `12/100` counter for a text field. It counts UTF-16 code units ([String.length]), the
/// unit the backend rules use, so an emoji counts as 2. Flutter's built-in `maxLength` counts
/// emoji as 1 and would accept titles the backend rejects.
class LengthCounter extends StatelessWidget {
  final TextEditingController controller;
  final int maxLength;

  const LengthCounter({super.key, required this.controller, required this.maxLength});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => _buildCounter(context, value.text.length),
    );
  }

  Widget _buildCounter(BuildContext context, int length) {
    final colors = Theme.of(context).colorScheme;
    final isOverLimit = length > maxLength;
    return Text(
      '$length/$maxLength',
      semanticsLabel: context.l10n.charactersUsed(length, maxLength),
      style: TextStyle(
        fontSize: 13,
        fontWeight: isOverLimit ? FontWeight.bold : FontWeight.normal,
        color: isOverLimit ? colors.error : colors.onSurfaceVariant,
      ),
    );
  }
}
