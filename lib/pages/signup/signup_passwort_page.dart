import 'package:flutter/material.dart';
import 'package:meet_christ/pages/profile/setup_profile_page.dart';
import 'package:meet_christ/view_models/auth/cubit/auth_cubit.dart';
import 'package:provider/provider.dart';

class SignupPasswordPage extends StatefulWidget {
  const SignupPasswordPage({super.key});

  @override
  State<SignupPasswordPage> createState() => _SignupPasswordPageState();
}

class _SignupPasswordPageState extends State<SignupPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    _passwordController.text = authCubit.state.password;
    return Scaffold(
      appBar: AppBar(title: Text("Create account")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom:8.0),
              child: Text(
                "Choose a password",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Form(
              child: TextFormField(
                obscureText: true,
                controller: _passwordController,
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          authCubit.passwordChanged(_passwordController.text);
                          print(authCubit.state.email);
                          return SetupProfileNamePage();
                        },
                      ),
                    );
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
