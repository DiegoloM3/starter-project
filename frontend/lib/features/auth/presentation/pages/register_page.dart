import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/pages/welcome_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.cyanAccent, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => WelcomePage(user: state.user)),
              (route) => false,
            );
          }
          if (state is AuthError) {
            String message = state.message;
            if (message.contains('CONFIGURATION_NOT_FOUND')) {
              message = 'ERROR: El servidor de autenticación no está configurado. Por favor, habilita "Email/Password" en el Firebase Console.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: Stack(
          children: [
            // Decorative elements
            Positioned(
              bottom: -50,
              left: -50,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.cyanAccent.withOpacity(0.05),
                ),
              ),
            ),
            
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_outlined, color: Colors.cyanAccent, size: 50),
                          const SizedBox(height: 16),
                          const Text(
                            'REGISTRO AGENTE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildTextField(_nameController, 'NOMBRE COMPLETO', Icons.person_outline),
                          const SizedBox(height: 20),
                          _buildTextField(_emailController, 'EMAIL AGENTE', Icons.alternate_email),
                          const SizedBox(height: 20),
                          _buildTextField(_passwordController, 'PASSWORD SEGURO', Icons.lock_outline, obscure: true),
                          const SizedBox(height: 40),
                          
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              if (state is AuthLoading) {
                                return const CircularProgressIndicator(color: Colors.cyanAccent);
                              }
                              return Column(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.cyanAccent,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(color: Colors.cyanAccent),
                                      ),
                                      shadowColor: Colors.cyanAccent.withOpacity(0.3),
                                    ),
                                    onPressed: () {
                                      context.read<AuthCubit>().register(
                                        _emailController.text,
                                        _passwordController.text,
                                        _nameController.text,
                                      );
                                    },
                                    child: const Text(
                                      'CREAR CREDENCIALES',
                                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Google Sign-In alternative
                                  TextButton.icon(
                                    onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                                    icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 24),
                                    label: const Text(
                                      'REGISTRAR CON GOOGLE',
                                      style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10, letterSpacing: 2),
        prefixIcon: Icon(icon, color: Colors.cyanAccent, size: 20),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
      ),
    );
  }
}
