import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/student.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() {
    return _LoginScreenState();
  }
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color maroon = Color(0xFF800000);

  final AuthService authService = AuthService();

  final ProfileService profileService = ProfileService();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  StreamSubscription<AuthState>? authSubscription;

  bool isLoading = false;
  bool isGoogleLoading = false;

  @override
  void initState() {
    super.initState();

    authSubscription = authService.authStateChanges.listen(
      (authState) {
        if (authState.event == AuthChangeEvent.signedIn) {
          handleSignedIn();
        }
      },
      onError: (error) {
        if (!mounted) return;

        setState(() {
          isLoading = false;
          isGoogleLoading = false;
        });

        showMessage('Authentication error occurred.');
      },
    );
  }

  Future<void> login() async {
    final String email =
        emailController.text.trim().toLowerCase();

    final String password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your UM email and password.');
      return;
    }

    if (!email.endsWith('@umindanao.edu.ph')) {
      showMessage('Please use your UM student email.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error = await authService.login(
      email: email,
      password: password,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        isLoading = false;
      });

      showMessage(error);
    }

    // Successful login navigation happens through
    // authStateChanges.
  }

  Future<void> loginWithGoogle() async {
    setState(() {
      isGoogleLoading = true;
    });

    final String? error =
        await authService.loginWithGoogle();

    if (!mounted) return;

    if (error != null) {
      setState(() {
        isGoogleLoading = false;
      });

      showMessage(error);
      return;
    }

    setState(() {
      isGoogleLoading = false;
    });
  }

  Future<void> handleSignedIn() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isGoogleLoading = false;
    });

    final currentUser = authService.currentUser;

    final String email =
        currentUser?.email?.trim().toLowerCase() ?? '';

    if (!email.endsWith('@umindanao.edu.ph')) {
      await authService.logout();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Please use your UM Google account.');
      return;
    }

    try {
      final Student? student =
          await profileService.getProfile();

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (student == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const ProfileScreen(),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              student: student,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      showMessage('Could not load your profile.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    authSubscription?.cancel();

    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.groups,
                  size: 80,
                  color: maroon,
                ),

                const SizedBox(height: 16),

                const Text(
                  'StudyCircle',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Find students to study with.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'UM Student Email',
                    hintText: 'yourname@umindanao.edu.ph',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: (isLoading || isGoogleLoading)
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ForgotPasswordScreen(
                                    initialEmail: emailController
                                        .text
                                        .trim()
                                        .toLowerCase(),
                                  );
                                },
                              ),
                            );
                          },
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: maroon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isLoading || isGoogleLoading)
                        ? null
                        : login,
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Text(
                        'OR',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    Expanded(
                      child: Divider(
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: (isLoading || isGoogleLoading)
                        ? null
                        : loginWithGoogle,
                    icon: isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: maroon,
                            ),
                          )
                        : const Icon(
                            Icons.account_circle_outlined,
                            color: maroon,
                          ),
                    label: Text(
                      isGoogleLoading
                          ? 'Opening Google...'
                          : 'Continue with Google',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: maroon,
                      side: const BorderSide(color: maroon),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: (isLoading || isGoogleLoading)
                      ? null
                      : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return const RegisterScreen();
                              },
                            ),
                          );
                        },
                  child: const Text(
                    "Don't have an account? Register",
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