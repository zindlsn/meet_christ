import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/view_models/changemail/bloc/change_mail_bloc.dart';

class ChangeMailAddressPage extends StatefulWidget {
  final String currentEmail;
  const ChangeMailAddressPage({super.key, required this.currentEmail});

  @override
  State<ChangeMailAddressPage> createState() => _ChangeMailAddressPageState();
}

class _ChangeMailAddressPageState extends State<ChangeMailAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _oldEmailController = TextEditingController();
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    _oldEmailController.text = widget.currentEmail;
    _newEmailController.text = "szindl@posteo.de";
    _passwordController.text = "Jesus10001.";
    super.initState();
  }

  @override
  void dispose() {
    _oldEmailController.dispose();
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      context.read<ChangeMailBloc>().add(
        ChangeMailRequested(
          oldEmail: _oldEmailController.text,
          newEmail: _newEmailController.text,
          password: _passwordController.text,
        ),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // use your app’s theme
    final accentColor = theme.colorScheme.primary; // == Color(0xFFC4A466)

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Change Email'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: BlocConsumer<ChangeMailBloc, ChangeMailState>(
            listener: (context, state) {},
            builder: (context, state) {
              return Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Center(
                      child: Icon(
                        Icons.email_outlined,
                        size: 80,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Center(
                      child: Text(
                        "Update Your Email",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Old Email
                    TextFormField(
                      enabled: false,
                      controller: _oldEmailController,
                      decoration: const InputDecoration(
                        labelText: "Old Email",
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your old email" : null,
                    ),
                    const SizedBox(height: 15),

                    // New Email
                    TextFormField(
                      controller: _newEmailController,
                      decoration: const InputDecoration(
                        labelText: "New Email",
                        prefixIcon: Icon(Icons.mail_lock_outlined),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter a new email" : null,
                    ),
                    const SizedBox(height: 15),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: "Current Password",
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? "Please enter your password" : null,
                    ),
                    const SizedBox(height: 30),

                    // Save Button (uses themed color)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentColor, // from your theme
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _saveChanges,
                        child: const Text(
                          "SAVE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
