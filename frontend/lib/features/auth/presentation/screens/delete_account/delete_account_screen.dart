import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth_form/auth_form_cubit.dart';
import '../../bloc/auth_form/auth_form_state.dart';
import '../auth_validation_messages.dart';

/// Explains what is deleted and asks for the password to confirm. When it succeeds, the session
/// ends and the app goes back to the sign in screen by itself.
class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar cuenta')),
      body: BlocConsumer<AuthFormCubit, AuthFormState>(
        listener: _onStateChanged,
        builder:
            (context, state) => ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(
                  'Esta acción no se puede deshacer.',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 16),
                Text(
                  'Se borrarán tu perfil, tus artículos guardados, tu historial y los usuarios que sigues. '
                  'Los artículos y comentarios que publicaste se conservarán con tu nombre.',
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirma tu contraseña',
                    errorText: messageForField(state.validationErrors, passwordErrors),
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  ),
                  onPressed: state.isSubmitting ? null : _submit,
                  child:
                      state.isSubmitting
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('ELIMINAR MI CUENTA'),
                ),
              ],
            ),
      ),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthFormCubit>().deleteAccount(_passwordController.text);
  }

  void _onStateChanged(BuildContext context, AuthFormState state) {
    final failure = state.failure;
    if (failure == null) return;
    final message = failure == AuthFormFailure.invalidCredentials ? 'La contraseña no es correcta.' : failure.message;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
