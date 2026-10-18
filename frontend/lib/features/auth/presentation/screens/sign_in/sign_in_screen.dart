import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routes/routes.dart';
import '../../bloc/auth_form/auth_form_cubit.dart';
import '../../bloc/auth_form/auth_form_state.dart';
import '../../widgets/brand_wordmark.dart';
import '../../widgets/submit_button.dart';
import '../auth_validation_messages.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthFormCubit, AuthFormState>(
          listener: _onStateChanged,
          builder:
              (context, state) =>
                  Center(child: SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildForm(state))),
        ),
      ),
    );
  }

  Widget _buildForm(AuthFormState state) {
    final errors = state.validationErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const BrandWordmark(),
        const SizedBox(height: 48),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: 'Email', errorText: messageForField(errors, emailErrors)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          autofillHints: const [AutofillHints.password],
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(labelText: 'Contraseña', errorText: messageForField(errors, passwordErrors)),
        ),
        const SizedBox(height: 24),
        SubmitButton(label: 'INICIAR SESIÓN', isSubmitting: state.isSubmitting, onPressed: _submit),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.of(context).pushNamed(AppRoutes.signUp),
          child: const Text('¿No tienes cuenta? Regístrate'),
        ),
        const SizedBox(height: 24),
        const _DemoAccountsHint(),
      ],
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthFormCubit>().signIn(email: _emailController.text, password: _passwordController.text);
  }

  void _onStateChanged(BuildContext context, AuthFormState state) {
    if (state.status == AuthFormStatus.failure && state.validationErrors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(unexpectedErrorMessage)));
    }
  }
}

/// Temporary help while the use cases return mock data.
class _DemoAccountsHint extends StatelessWidget {
  const _DemoAccountsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Modo demo: entra con journalist@symmetry.com para publicar como periodista, '
      'o con cualquier otro email como lector.',
      textAlign: TextAlign.center,
      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
    );
  }
}
