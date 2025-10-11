import 'package:flutter/material.dart';
import 'package:meet_christ/pages/auth/auth.dart';
import 'package:meet_christ/pages/signup/signup_passwort_page.dart';
import 'package:meet_christ/view_models/signup/bloc/sign_up_bloc.dart';
import 'package:provider/provider.dart';

class SignupEmailPage extends StatefulWidget {
  const SignupEmailPage({super.key});

  @override
  State<SignupEmailPage> createState() => _SignupEmailPageState();
}

class _SignupEmailPageState extends State<SignupEmailPage> {
  final TextEditingController _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    _emailController.text =
        context.watch<SignupBloc>().state.email;
    return Scaffold(
      appBar: AppBar(title: Text("Create account")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "What is your email address?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Form(
              child: TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.grey, // change color as needed
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(
                      color: Colors.blue, // change color as needed
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    final isEmailAvailable = await context
                        .read<SignupBloc>()
                        .authRepository
                        .emailIsAvailable(_emailController.text);
                    if (isEmailAvailable) {
                      context.read<SignupBloc>().add(SignupEmailUpdated(_emailController.text));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return SignupPasswordPage();
                          },
                        ),
                      );
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: Text("Email is connected to an account"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  // Handle login action here, e.g. navigate to login page

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return JesusLoginScreen();
                                      },
                                    ),
                                  );
                                },
                                child: Text("Want to log in?"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text("Next"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
