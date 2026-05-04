import 'package:flutter/material.dart';

class MetricsBadge extends StatelessWidget {
  final int views;
  final int favorites;

  const MetricsBadge({
    super.key,
    required this.views,
    required this.favorites,
  });

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.visibility_outlined, size: 14),
        const SizedBox(width: 2),
        Text('$views', style: style),
        const SizedBox(width: 10),
        const Icon(Icons.favorite_border, size: 14),
        const SizedBox(width: 2),
        Text('$favorites', style: style),
      ],
    );
  }
}
