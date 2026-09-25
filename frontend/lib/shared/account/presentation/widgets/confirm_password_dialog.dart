import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';

/// Asks for the account's password again before a sensitive action.
/// Returns the password, or null if the user cancels.
class ConfirmPasswordDialog extends StatefulWidget {
  const ConfirmPasswordDialog({super.key});

  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ConfirmPasswordDialog(),
    );
  }

  @override
  State<ConfirmPasswordDialog> createState() => _ConfirmPasswordDialogState();
}

class _ConfirmPasswordDialogState extends State<ConfirmPasswordDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_controller.text.isEmpty) return;
    Navigator.pop(context, _controller.text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.confirmItsYou),
      content: TextField(
        controller: _controller,
        autofocus: true,
        obscureText: true,
        decoration: InputDecoration(labelText: context.l10n.passwordLabel),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(context.l10n.continueAction)),
      ],
    );
  }
}
