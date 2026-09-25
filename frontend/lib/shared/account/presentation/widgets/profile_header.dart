import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/account_entity.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';

class ProfileHeader extends StatelessWidget {
  static const _avatarSize = 96.0;

  final AccountEntity? account;

  const ProfileHeader({super.key, required this.account});

  bool get _isGuest => account?.isGuest ?? true;

  String _name(AppLocalizations l10n) {
    if (_isGuest) return l10n.guest;
    return account?.displayName ?? account?.email ?? l10n.yourAccount;
  }

  String _subtitle(AppLocalizations l10n) {
    if (_isGuest) return l10n.articlesOnlyOnThisPhone;
    // Without a display name, the email is already the title.
    return account?.displayName == null ? l10n.signedIn : account?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        _buildAvatar(context),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _name(context.l10n),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineLarge,
            ),
            // Renaming needs a real account to attach the name to -- a
            // guest's name would just be lost the moment they connect one,
            // since connecting keeps the id but replaces these profile
            // fields with whatever the sign-in method itself provides.
            if (!_isGuest) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                iconSize: 20,
                tooltip: context.l10n.editName,
                onPressed: () => _editName(context),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          _subtitle(context.l10n),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Future<void> _editName(BuildContext context) async {
    final cubit = context.read<AccountCubit>();
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _EditNameDialog(initialName: account?.displayName ?? ''),
    );
    if (name != null && name.isNotEmpty) {
      unawaited(cubit.updateDisplayName(name));
    }
  }

  Widget _buildAvatar(BuildContext context) {
    final photoUrl = account?.photoUrl;
    final fallback = _AvatarFallback(
      initials: _isGuest ? null : initialsFor(account),
      size: _avatarSize,
    );
    return Container(
      width: _avatarSize,
      height: _avatarSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 3,
        ),
      ),
      child: ClipOval(
        child: photoUrl == null
            ? fallback
            : CachedNetworkImage(
                imageUrl: photoUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => fallback,
                errorWidget: (_, __, ___) => fallback,
              ),
      ),
    );
  }
}

/// Its own controller, owned and disposed by this widget's own State --
/// not by whoever calls [showDialog] -- so it's disposed when this widget
/// actually leaves the tree, after the dialog's closing animation finishes.
/// Disposing it right after `showDialog`'s Future resolves (as soon as
/// `Navigator.pop` runs) is too early: the dialog is still playing its
/// exit transition and its `TextFormField` is still mounted, still
/// listening to that now-disposed controller -- the next frame throws
/// ("A TextEditingController was used after being disposed"), which
/// cascades into further framework assertions and froze the whole app on
/// a real device (confirmed via an ANR trace and a `flutter attach`
/// session that caught the exact exception).
class _EditNameDialog extends StatefulWidget {
  final String initialName;

  const _EditNameDialog({required this.initialName});

  @override
  State<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends State<_EditNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editName),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: context.l10n.nameLabel),
          validator: (value) => (value ?? '').trim().isEmpty
              ? context.l10n.requiredField
              : null,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(context, _controller.text.trim());
          },
          child: Text(context.l10n.save),
        ),
      ],
    );
  }
}

/// Up to two letters: the first of each of the display name's first two
/// words, or the email's first letter when there's no name.
String? initialsFor(AccountEntity? account) {
  final name = account?.displayName?.trim() ?? '';
  if (name.isNotEmpty) {
    return name
        .split(RegExp(r'\s+'))
        .take(2)
        .map((word) => word[0])
        .join()
        .toUpperCase();
  }
  final email = account?.email?.trim() ?? '';
  return email.isEmpty ? null : email[0].toUpperCase();
}

class _AvatarFallback extends StatelessWidget {
  final String? initials;
  final double size;

  const _AvatarFallback({required this.initials, required this.size});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      alignment: Alignment.center,
      child: initials == null
          ? Icon(
              Icons.person_outline,
              size: size / 2,
              color: colorScheme.onSecondaryContainer,
            )
          : Text(
              initials!,
              style: theme.textTheme.headlineLarge
                  ?.copyWith(color: colorScheme.onSecondaryContainer),
            ),
    );
  }
}
