import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/pages/auth/auth.dart';
import 'package:meet_christ/repositories/auth_repository.dart';
import 'package:meet_christ/view_models/auth/bloc/auth_bloc.dart';

class ForgotPasswordPage extends StatelessWidget {
  final String? email;
  const ForgotPasswordPage({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    if (email?.isNotEmpty == true) {
      emailController.text = email!;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password'), centerTitle: true),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Forgot your password?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Enter your email address below and we’ll send you a link to reset your password.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    final email = emailController.text.trim();

                    if (email.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please enter your email address.'),
                        ),
                      );
                      return;
                    }

                    context.read<AuthBloc>().add(
                      ResetPasswordRequested(email: emailController.text),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Password reset link sent to $email'),
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => JesusLoginScreen(),
                      ),
                    );
                  },
                  child: const Text('Send Reset Link'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
