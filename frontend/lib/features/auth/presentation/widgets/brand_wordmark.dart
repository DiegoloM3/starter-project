import 'package:flutter/material.dart';

/// Name of the app with a line below, used on the splash and the sign in screens.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('SYMMETRY', style: textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 8)),
        const SizedBox(width: 64, child: Divider(thickness: 3)),
        const SizedBox(height: 8),
        Text('NEWS', style: textTheme.labelLarge?.copyWith(letterSpacing: 6)),
      ],
    );
  }
}
