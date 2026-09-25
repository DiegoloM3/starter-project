import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/l10n/l10n.dart';
import 'package:news_app_clean_architecture/shared/account/domain/entities/sign_in_method.dart';
import 'package:news_app_clean_architecture/shared/account/presentation/bloc/account_cubit.dart';

class EmailSignInForm extends StatefulWidget {
  final bool isBusy;
  final String? errorText;
  final VoidCallback onBack;

  const EmailSignInForm({
    super.key,
    required this.isBusy,
    required this.errorText,
    required this.onBack,
  });

  @override
  State<EmailSignInForm> createState() => _EmailSignInFormState();
}

class _EmailSignInFormState extends State<EmailSignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Which tab is selected. The actual sign-in call underneath is the same
  // either way (see AccountAuthDataSource.linkWithEmail): Firebase itself
  // decides whether this email is new or already has an account, and the
  // "already has one" case is handled by the existing switch-account flow
  // regardless of which tab was picked. This choice only changes what the
  // form itself asks for -- confirming a new password only makes sense
  // when actually choosing one.
  bool _creatingAccount = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AccountCubit>().connect(EmailSignInMethod(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName:
              _creatingAccount ? _nameController.text.trim() : null,
        ));
  }

  String? _validateName(String? value) {
    return (value ?? '').trim().isEmpty ? context.l10n.requiredField : null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    return email.contains('@') && email.contains('.')
        ? null
        : context.l10n.enterValidEmail;
  }

  String? _validatePassword(String? value) {
    return (value ?? '').length >= 6
        ? null
        : context.l10n.atLeastSixCharacters;
  }

  String? _validateConfirmPassword(String? value) {
    return value == _passwordController.text
        ? null
        : context.l10n.passwordsDontMatch;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(context.l10n.signIn)),
                ButtonSegment(
                    value: true, label: Text(context.l10n.createAccount)),
              ],
              selected: {_creatingAccount},
              showSelectedIcon: false,
              onSelectionChanged: widget.isBusy
                  ? null
                  : (selection) =>
                      setState(() => _creatingAccount = selection.first),
            ),
            const SizedBox(height: 16),
            if (_creatingAccount) ...[
              TextFormField(
                controller: _nameController,
                enabled: !widget.isBusy,
                decoration: InputDecoration(labelText: context.l10n.nameLabel),
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                validator: _validateName,
              ),
              const SizedBox(height: 12),
            ],
            TextFormField(
              controller: _emailController,
              enabled: !widget.isBusy,
              decoration: InputDecoration(labelText: context.l10n.emailLabel),
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _passwordController,
              enabled: !widget.isBusy,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  tooltip: _obscurePassword
                      ? context.l10n.showPassword
                      : context.l10n.hidePassword,
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              obscureText: _obscurePassword,
              autofillHints: [
                _creatingAccount
                    ? AutofillHints.newPassword
                    : AutofillHints.password,
              ],
              textInputAction: _creatingAccount
                  ? TextInputAction.next
                  : TextInputAction.done,
              onFieldSubmitted: (_) => _creatingAccount ? null : _submit(),
              validator: _validatePassword,
            ),
            if (_creatingAccount) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmPasswordController,
                enabled: !widget.isBusy,
                decoration: InputDecoration(
                  labelText: context.l10n.confirmPasswordLabel,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    tooltip: _obscureConfirmPassword
                        ? context.l10n.showPassword
                        : context.l10n.hidePassword,
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: _validateConfirmPassword,
              ),
            ],
            if (widget.errorText != null) ...[
              const SizedBox(height: 12),
              Text(
                widget.errorText!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                TextButton(
                  onPressed: widget.isBusy ? null : widget.onBack,
                  child: Text(context.l10n.back),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: widget.isBusy ? null : _submit,
                  child: Text(_creatingAccount
                      ? context.l10n.createAccount
                      : context.l10n.signIn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
