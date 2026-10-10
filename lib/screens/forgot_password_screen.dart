import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({
    super.key,
    this.initialEmail = '',
  });

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  static const Color maroon = Color(0xFF800000);

  final AuthService authService = AuthService();

  final TextEditingController emailController =
      TextEditingController();

  bool isLoading = false;
  bool emailSent = false;

  @override
  void initState() {
    super.initState();

    emailController.text = widget.initialEmail;
  }

  Future<void> sendResetLink() async {
    final String email =
        emailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      showMessage('Please enter your UM email.');
      return;
    }

    if (!email.endsWith('@umindanao.edu.ph')) {
      showMessage('Please use your UM student email.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    final String? error =
        await authService.sendPasswordResetEmail(
      email: email,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (error != null) {
      showMessage(error);
      return;
    }

    setState(() {
      emailSent = true;
    });
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
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: emailSent
                ? buildEmailSentView()
                : buildEmailForm(),
          ),
        ),
      ),
    );
  }

  Widget buildEmailForm() {
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
          'Reset Your Password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: maroon,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Enter your UM student email. We will send '
          'you a link to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 32),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          decoration: const InputDecoration(
            labelText: 'UM Student Email',
            hintText: 'yourname@umindanao.edu.ph',
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 24),

        ElevatedButton(
          onPressed: isLoading ? null : sendResetLink,
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
                  'Send Reset Link',
                  style: TextStyle(fontSize: 16),
                ),
        ),

        const SizedBox(height: 12),

        TextButton(
          onPressed: isLoading
              ? null
              : () => Navigator.pop(context),
          child: const Text(
            'Back to Login',
            style: TextStyle(color: maroon),
          ),
        ),
      ],
    );
  }

  Widget buildEmailSentView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: maroon,
        ),

        const SizedBox(height: 24),

        const Text(
          'Check Your Email',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: maroon,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          'If an account exists for ${emailController.text.trim()}, '
          'a password reset link will be sent. Check your inbox '
          'and spam folder.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 28),

        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Back to Login'),
        ),

        const SizedBox(height: 8),

        TextButton(
          onPressed: () {
            setState(() {
              emailSent = false;
            });
          },
          child: const Text(
            'Try Another Email',
            style: TextStyle(color: maroon),
          ),
        ),
      ],
    );
  }
}