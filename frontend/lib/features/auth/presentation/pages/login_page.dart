import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Elegant Imports (Barrels)
import 'package:news_app_clean_architecture/features/auth/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF03050F),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => WelcomePage(user: state.user)),
            );
          }
          if (state is AuthError) {
            String message = state.message;
            if (message.contains('CONFIGURATION_NOT_FOUND')) {
              message = 'AVISO: El método de autenticación Email/Password no está habilitado en Firebase Console.';
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
            );
          }
        },
        child: Stack(
          children: [
            // Decorative background elements
            Positioned(
              top: -100,
              right: -50,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.05),
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
                          const Icon(Icons.auto_awesome, color: Colors.cyanAccent, size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            'SYMMETRY',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'ACCESO AGENTE',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontSize: 12,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 48),
                          _buildTextField(_emailController, 'EMAIL', Icons.alternate_email),
                          const SizedBox(height: 20),
                          _buildTextField(_passwordController, 'PASSWORD', Icons.lock_outline, obscure: true),
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
                                      backgroundColor: Colors.cyanAccent,
                                      foregroundColor: Colors.black,
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      elevation: 10,
                                      shadowColor: Colors.cyanAccent.withOpacity(0.5),
                                    ),
                                    onPressed: () {
                                      context.read<AuthCubit>().login(
                                        _emailController.text,
                                        _passwordController.text,
                                      );
                                    },
                                    child: const Text(
                                      'AUTENTICAR',
                                      style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Google Sign-In Button
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(double.infinity, 60),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                                    icon: const Icon(Icons.g_mobiledata, color: Colors.white, size: 30),
                                    label: const Text(
                                      'CONTINUAR CON GOOGLE',
                                      style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 12),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          
                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const RegisterPage()),
                              );
                            },
                            child: const Text(
                              '¿NUEVO AGENTE? SOLICITAR CREDENCIALES',
                              style: TextStyle(color: Colors.white, fontSize: 10, letterSpacing: 1),
                            ),
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
