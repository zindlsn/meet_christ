import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:meet_christ/pages/home.dart';
import 'package:meet_christ/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  Widget build(BuildContext context) {
    var titleTag = "login";
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, model, child) {
          return FlutterLogin(
            titleTag: "login",
            savedEmail: "szindl@posteo.de",
            savedPassword: "Jesus1000.",
            onResendCode: (code) {},
            onLogin: (loginData) async {
              model.setEmail(loginData.name);
              model.setPassword(loginData.password);
              await model.login();
            },
            onRecoverPassword: (password) {},
            onConfirmSignup: (text, loginData) {
              model.setEmail(loginData.name);
              model.setPassword(loginData.password);
              model.signUp();
            },
            initialAuthMode: AuthMode.login,
            onSignup: (loginData) async {
              model.setEmail(loginData.name ?? "");
              model.setPassword(loginData.password ?? "");
              await model.signUp();
            },
            validateUserImmediately: true,
            loginAfterSignUp: true,
            onSubmitAnimationCompleted: () {
              if (titleTag == "login") {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage(indexTab: 0,)),
                );
              }
            },
          );
        },
      ),
    );
  }
}
