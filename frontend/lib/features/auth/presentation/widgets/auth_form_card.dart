import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_themes.dart';

/// White card that groups the fields of a form, separated by the same space.
class AuthFormCard extends StatelessWidget {
  final List<Widget> fields;

  const AuthFormCard({super.key, required this.fields});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: palette.textPrimary.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < fields.length; index++) ...[
            if (index > 0) const SizedBox(height: 14),
            fields[index],
          ],
        ],
      ),
    );
  }
}
