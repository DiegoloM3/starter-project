import 'package:flutter/material.dart';

class ReadingTimeBadge extends StatelessWidget {
  final int minutes;

  const ReadingTimeBadge({Key? key, required this.minutes}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 12, color: cs.outlineVariant),
        const SizedBox(width: 3),
        Text(
          '$minutes min read',
          style: tt.labelMedium?.copyWith(
            color: cs.outlineVariant,
            fontWeight: FontWeight.w400,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}
