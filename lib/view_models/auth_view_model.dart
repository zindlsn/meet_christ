import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/models/user_credentails.dart';
import 'package:meet_christ/services/user_service.dart';
import 'package:uuid/uuid.dart';

class AuthViewModel extends ChangeNotifier {
  final UserService userService;

  AuthViewModel({required this.userService});

  bool isLoading = false;

  void setLoading(bool loading) {
    isLoading = loading;
    notifyListeners();
  }

  String email = "";
  void setEmail(String email) {
    this.email = email;
  }

  String password = "";

  void setPassword(String password) {
    this.password = password;
  }

  String repeatPassword = "";

  String? errorMessage;

  String firstname = "";

  void setFirstname(String firstname) {
    this.firstname = firstname;
  }

  String lastname = "";

  void setLastname(String lastname) {
    this.lastname = lastname;
  }

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

  Future<bool> login(String email, String password) async {
    try {
      var user = await userService.login(
        UserCredentials(email: email, password: password),
      );
      if (user == null) {
        return false;
      }
      await userService.saveUserdataLocally(
        LoginData(name: email, password: password),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> signUp() async {
    try {
      var user = await userService.signUp(
        UserCredentials(email: email, password: password),
        User(
          id: Uuid().v4(),
          firstname: firstname,
          lastname: lastname,
          email: email,
        ),
      );
      errorMessage = null;
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message;
      return false;
    }
  }

  Future<User?> tryAutoLogin() async {
    setLoading(true);
    var logindata = await GetIt.I.get<UserService>().loadLogindataLocally();
    User? user;
    if (logindata != null) {
      user = await GetIt.I.get<UserService>().login(
        UserCredentials(email: logindata.name, password: logindata.password),
      );
    }
    setLoading(false);
    return user;
  }
}

enum UserGender { female, male }
