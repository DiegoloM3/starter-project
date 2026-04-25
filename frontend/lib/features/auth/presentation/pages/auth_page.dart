import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:news_app_clean_architecture/config/routes/app_routes.dart';
import 'package:news_app_clean_architecture/config/theme/app_theme_extension.dart';
import 'package:news_app_clean_architecture/core/session/firebase_auth_session.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';
import 'package:news_app_clean_architecture/features/user_articles/presentation/widgets/primary_button.dart';
import 'package:news_app_clean_architecture/injection_container.dart';

enum _Mode { signIn, signUp }

class AuthPage extends StatefulWidget {
  const AuthPage({this.next, super.key});

  /// Path to navigate to after a successful login. When null, falls back
  /// to the home route.
  final String? next;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  late final AuthCubit _cubit;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  _Mode _mode = _Mode.signIn;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _cubit = AuthCubit(sl<FirebaseAuthSession>());
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _cubit.close();
    super.dispose();
  }

  void _toggleMode(_Mode mode) {
    if (_mode == mode) return;
    setState(() => _mode = mode);
    _cubit.resetError();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (_mode == _Mode.signIn) {
      _cubit.signIn(email: email, password: password);
    } else {
      _cubit.signUp(
        email: email,
        password: password,
        name: _nameController.text.trim(),
      );
    }
  }

  void _onAuthSuccess() {
    final destination = (widget.next != null && widget.next!.isNotEmpty)
        ? widget.next!
        : AppRoutes.home();
    context.go(destination);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _cubit,
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (prev, curr) => prev.status != curr.status,
        listener: (context, state) {
          if (state.status == AuthStatus.success) {
            _onAuthSuccess();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Welcome'),
            elevation: 0,
            leading: IconButton(
              tooltip: 'Home',
              icon: const Icon(Icons.home_outlined),
              onPressed: () => context.go(AppRoutes.home()),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(context.appTheme.spacing.lg),
              child: Form(
                key: _formKey,
                child: BlocBuilder<AuthCubit, AuthState>(
                  builder: _buildContent,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AuthState state) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(height: theme.spacing.md),
        Text(
          _mode == _Mode.signIn ? 'Sign in' : 'Create your account',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: theme.onSurface,
          ),
        ),
        SizedBox(height: theme.spacing.xs),
        Text(
          _mode == _Mode.signIn
              ? 'Use your email and password to access "My Articles".'
              : 'A free account lets you publish, edit, and manage articles.',
          style: TextStyle(fontSize: 13, color: theme.onSurfaceMuted),
        ),
        SizedBox(height: theme.spacing.lg),
        _ModeToggle(mode: _mode, onSelect: _toggleMode),
        SizedBox(height: theme.spacing.lg),

        if (_mode == _Mode.signUp) ...[
          _Field(
            controller: _nameController,
            label: 'Display name',
            hint: 'How other readers will see you',
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            validator: _validateName,
          ),
          SizedBox(height: theme.spacing.md),
        ],

        _Field(
          controller: _emailController,
          label: 'Email',
          hint: 'you@example.com',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.email],
          validator: _validateEmail,
        ),
        SizedBox(height: theme.spacing.md),

        _Field(
          controller: _passwordController,
          label: 'Password',
          hint: _mode == _Mode.signUp ? 'At least 6 characters' : 'Your password',
          obscure: _obscure,
          textInputAction: TextInputAction.done,
          autofillHints: _mode == _Mode.signUp
              ? const [AutofillHints.newPassword]
              : const [AutofillHints.password],
          validator: _validatePassword,
          onSubmitted: (_) => _submit(),
          suffix: IconButton(
            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
            tooltip: _obscure ? 'Show password' : 'Hide password',
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
        ),

        if (state.status == AuthStatus.failure &&
            state.errorMessage != null) ...[
          SizedBox(height: theme.spacing.md),
          Text(
            state.errorMessage!,
            style: TextStyle(fontSize: 13, color: theme.danger),
          ),
        ],

        SizedBox(height: theme.spacing.xl),
        PrimaryButton(
          label: _mode == _Mode.signIn ? 'Sign in' : 'Create account',
          icon: Icons.lock_open,
          isLoading: state.isSubmitting,
          onPressed: state.isSubmitting ? null : _submit,
        ),
        SizedBox(height: theme.spacing.lg),
        Center(
          child: TextButton(
            onPressed: () => _toggleMode(
              _mode == _Mode.signIn ? _Mode.signUp : _Mode.signIn,
            ),
            child: Text(
              _mode == _Mode.signIn
                  ? "Don't have an account? Create one"
                  : 'Already have an account? Sign in',
            ),
          ),
        ),
      ],
    );
  }

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Required';
    if (v.length < 2) return 'Use at least 2 characters';
    if (v.length > 60) return 'Keep it under 60 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(v)) return 'Use a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Required';
    if (_mode == _Mode.signUp && value.length < 6) {
      return 'At least 6 characters';
    }
    return null;
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onSelect});

  final _Mode mode;
  final ValueChanged<_Mode> onSelect;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_Mode>(
      segments: const [
        ButtonSegment(
          value: _Mode.signIn,
          label: Text('Sign in'),
          icon: Icon(Icons.login),
        ),
        ButtonSegment(
          value: _Mode.signUp,
          label: Text('Register'),
          icon: Icon(Icons.person_add_alt_1),
        ),
      ],
      selected: {mode},
      onSelectionChanged: (s) => onSelect(s.first),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.validator,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscure = false,
    this.suffix,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscure;
  final Widget? suffix;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: theme.onSurface,
          ),
        ),
        SizedBox(height: theme.spacing.xs),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          autofillHints: autofillHints,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: theme.surfaceMuted,
            suffixIcon: suffix,
            border: OutlineInputBorder(
              borderRadius: theme.radii.smRadius,
              borderSide: BorderSide(color: theme.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: theme.radii.smRadius,
              borderSide: BorderSide(color: theme.divider),
            ),
          ),
        ),
      ],
    );
  }
}
