import 'package:flutter/material.dart';

import 'legal_documents.dart';

class LegalScreen extends StatelessWidget {
  final LegalDocument document;

  const LegalScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(document.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          for (final section in document.sections) ...[
            const SizedBox(height: 16),
            Text(section.heading, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(section.body, style: textTheme.bodyLarge?.copyWith(height: 1.5)),
          ],
        ],
      ),
    );
  }
}
