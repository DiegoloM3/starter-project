import 'package:flutter/material.dart';

import '../extensions/build_context_extensions.dart';
import '../previews/app_preview.dart';

/// Centered loading indicator used across the app.
class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Preview of loading indicator.
@AppPreview(name: 'Loading Indicator')
Widget previewLoadingIndicator() {
  return const Material(
    child: LoadingIndicator(message: 'Loading articles...'),
  );
}
