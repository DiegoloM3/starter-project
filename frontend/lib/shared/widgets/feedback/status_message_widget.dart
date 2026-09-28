import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/global_themes.dart';

class StatusMessageWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const StatusMessageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconFrame(context),
            const SizedBox(height: 14),
            _buildTitle(context),
            const SizedBox(height: 6),
            _buildMessage(context),
            if (_hasAction) _buildActionButton(),
          ],
        ),
      ),
    );
  }

  bool get _hasAction => actionLabel != null && onAction != null;

  Widget _buildIconFrame(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(border: Border.all(color: GlobalTheme.kRule, width: 1.5)),
      child: Icon(icon, size: 28, color: colorScheme.onSurface.withValues(alpha: 0.35)),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(title, style: GlobalTheme.masthead(Theme.of(context).colorScheme, fontSize: 16));
  }

  Widget _buildMessage(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Text(
      message,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.5)),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildActionButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(onPressed: onAction, child: Text(actionLabel!)),
    );
  }
}