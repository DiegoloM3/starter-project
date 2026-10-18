import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/params/auth_validation.dart';
import '../../bloc/auth_form/auth_form_cubit.dart';
import '../../bloc/auth_form/auth_form_state.dart';
import '../../widgets/submit_button.dart';
import '../auth_validation_messages.dart';

/// New accounts are readers. Journalists are promoted by an administrator.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: BlocConsumer<AuthFormCubit, AuthFormState>(
        listener: _onStateChanged,
        builder: (context, state) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: _buildForm(state)),
      ),
    );
  }

  Widget _buildForm(AuthFormState state) {
    final errors = state.validationErrors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildNameField(_firstNameController, 'Nombre', messageForField(errors, firstNameErrors)),
        const SizedBox(height: 16),
        _buildNameField(_lastNameController, 'Apellido', messageForField(errors, lastNameErrors)),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          decoration: InputDecoration(labelText: 'Email', errorText: messageForField(errors, emailErrors)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _submit(),
          decoration: InputDecoration(
            labelText: 'Contraseña',
            helperText: 'Mínimo ${AuthLimits.passwordMinLength} caracteres.',
            errorText: messageForField(errors, passwordErrors),
          ),
        ),
        const SizedBox(height: 24),
        SubmitButton(label: 'CREAR CUENTA', isSubmitting: state.isSubmitting, onPressed: _submit),
      ],
    );
  }

  Widget _buildNameField(TextEditingController controller, String label, String? errorText) {
    return TextField(
      controller: controller,
      maxLength: AuthLimits.nameMaxLength,
      textCapitalization: TextCapitalization.words,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label, errorText: errorText, counterText: ''),
    );
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    context.read<AuthFormCubit>().signUp(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );
  }

  void _onStateChanged(BuildContext context, AuthFormState state) {
    if (state.status == AuthFormStatus.failure && state.validationErrors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(unexpectedErrorMessage)));
    }
  }
}
