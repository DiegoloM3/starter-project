import 'package:flutter/material.dart';
import 'package:news_app_clean_architecture/config/theme/app_colors.dart';
import 'package:news_app_clean_architecture/config/theme/app_dimensions.dart';
import 'package:news_app_clean_architecture/config/theme/app_typography.dart';
import 'package:news_app_clean_architecture/l10n/app_localizations.dart';

class EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final void Function(String name, String email) onSave;

  const EditProfileDialog({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.onSave,
  });

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  bool get _isValid {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty && email.isEmpty) return false;
    if (email.isNotEmpty && !email.contains('@')) return false;
    return true;
  }

  void _handleSave() {
    if (!_isValid) {
      setState(() {
        _errorText = AppLocalizations.of(context)!.nameOrEmailRequired;
      });
      return;
    }
    widget.onSave(
      _nameController.text.trim(),
      _emailController.text.trim(),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.editProfileTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: l10n.nameLabel),
            onChanged: (_) => setState(() => _errorText = null),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: AppDimensions.spacing12),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(labelText: l10n.emailLabel),
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => setState(() => _errorText = null),
          ),
          if (_errorText != null) ...[
            const SizedBox(height: AppDimensions.spacing8),
            Text(
              _errorText!,
              style: AppTypography.footnote
                  .copyWith(color: AppColors.destructive),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancelAction),
        ),
        TextButton(
          onPressed: _handleSave,
          child: Text(l10n.saveAction),
        ),
      ],
    );
  }
}
