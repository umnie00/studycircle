import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  static const Color maroon = Color(0xFF800000);

  final AuthService authService = AuthService();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isCompleted = false;

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  String? completionMessage;

  Future<void> saveNewPassword() async {
    final String password = passwordController.text;
    final String confirmPassword =
        confirmPasswordController.text;

    if (password.isEmpty || confirmPassword.isEmpty) {
      showMessage('Please complete both password fields.');
      return;
    }

    if (password.length < 6) {
      showMessage(
        'Your password must contain at least 6 characters.',
      );
      return;
    }

    if (password != confirmPassword) {
      showMessage('Your passwords do not match.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error =
        await authService.updatePassword(
      newPassword: password,
    );

    if (!mounted) return;

    if (error != null) {
      setState(() {
        isLoading = false;
      });

      showMessage(error);
      return;
    }

    // End the recovery session after updating the password.
    final String? logoutError = await authService.logout();

    if (!mounted) return;

    setState(() {
      isLoading = false;
      isCompleted = true;

      completionMessage = logoutError == null
          ? 'Your password has been changed successfully. '
              'You can now log in using your new password.'
          : 'Your password has been changed. Please close '
              'and reopen StudyCircle before logging in again.';
    });
  }

  void returnToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
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
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        automaticallyImplyLeading: !isCompleted,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: isCompleted
                ? buildSuccessView()
                : buildPasswordForm(),
          ),
        ),
      ),
    );
  }

  Widget buildPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.lock_reset,
          size: 80,
          color: maroon,
        ),

        const SizedBox(height: 24),

        const Text(
          'Create a New Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: maroon,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Choose a new password for your StudyCircle account.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 32),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'New Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscurePassword = !obscurePassword;
                });
              },
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 16),

        TextField(
          controller: confirmPasswordController,
          obscureText: obscureConfirmPassword,
          enabled: !isLoading,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              onPressed: () {
                setState(() {
                  obscureConfirmPassword =
                      !obscureConfirmPassword;
                });
              },
              icon: Icon(
                obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),
            border: const OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: isLoading ? null : saveNewPassword,
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Save New Password',
                  style: TextStyle(fontSize: 16),
                ),
        ),
      ],
    );
  }

  Widget buildSuccessView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 88,
          color: maroon,
        ),

        const SizedBox(height: 24),

        const Text(
          'Password Updated',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: maroon,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          completionMessage ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: returnToLogin,
          child: const Text('Return to Login'),
        ),
      ],
    );
  }
}