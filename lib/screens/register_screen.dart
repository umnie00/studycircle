import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() {
    return _RegisterScreenState();
  }
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final AuthService authService =
      AuthService();

  final TextEditingController
      emailController =
      TextEditingController();

  final TextEditingController
      passwordController =
      TextEditingController();

  bool isLoading = false;

  Future<void> register() async {
    final String email =
        emailController.text.trim().toLowerCase();

    final String password =
        passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage(
        'Please fill in all fields.',
      );
      return;
    }

    if (!email.endsWith(
      '@umindanao.edu.ph',
    )) {
      showMessage(
        'Registration is only available for UM students.',
      );
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Password must be at least 6 characters.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error =
        await authService.register(
      email: email,
      password: password,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = false;
    });

    if (error != null) {
      showMessage(error);
      return;
    }

    showMessage(
      'Account created! Check your UM email for verification.',
    );

    Navigator.pop(context);
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        behavior:
            SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Register',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add,
                  size: 70,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Use your UM student email to register.',
                  textAlign:
                      TextAlign.center,
                ),

                const SizedBox(height: 32),

                TextField(
                  controller:
                      emailController,
                  keyboardType:
                      TextInputType
                          .emailAddress,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'UM Student Email',
                    hintText:
                        'student@umindanao.edu.ph',
                    prefixIcon:
                        Icon(Icons.email),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller:
                      passwordController,
                  obscureText: true,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Password',
                    prefixIcon:
                        Icon(Icons.lock),
                    border:
                        OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 8),

                const Align(
                  alignment:
                      Alignment.centerLeft,
                  child: Text(
                    'Password must be at least 6 characters.',
                    style: TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width:
                      double.infinity,
                  height: 52,
                  child:
                      ElevatedButton(
                    onPressed:
                        isLoading
                            ? null
                            : register,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(),
                          )
                        : const Text(
                            'Register',
                            style:
                                TextStyle(
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}