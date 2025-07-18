import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/services/user_service.dart';

class AuthViewModel extends ChangeNotifier {
  final UserService2 userService;

  AuthViewModel({required this.userService});

  String email = "";
  void setEmail(String email) {
    this.email = email;
  }

  String password = "";

  void setPassword(String password) {
    this.password = password;
  }

  String repeatPassword = "";

  void setRepeatPassword(String repeatPassword) {
    this.repeatPassword = repeatPassword;
  }

  Future<void> loadStoredLogindata() async {
    LoginData? data = await userService.loadLogindataLocally();
    if (data != null) {
      email = data.name;
      password = data.password;
    }
    notifyListeners();
  }

  Future<bool> login() async {
    var user = await userService.login(
      UserCredentials(email: email, password: password),
    );

    await userService.saveUserdataLocally(
      LoginData(name: email, password: password),
    );

    return user != null;
  }

  Future<bool> signUp() async {
    var user = await userService.signUp(
      UserCredentials(email: email, password: password),
      User(id: "", name: "Stefan Zindl", email: email),
    );
    return user != null;
  }
}
