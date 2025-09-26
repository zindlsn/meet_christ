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

  String email = "szindl@posteo.de";
  void setEmail(String email) {
    this.email = email;
  }

  String password = "Jesus1000.";

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
    var data = await userService.loadLogindataLocally();
    if (data.$1 != null) {
      email = data.$1!.name;
      password = data.$1!.password;
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
      setLoading(false);
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
      setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "email-already-in-use") {
        errorMessage = "Email already in use";
      } else if (e.code == "weak-password") {
        errorMessage = "Password is too weak";
      } else {
        errorMessage = e.message;
      }
      setLoading(false);
      return false;
    }
  }

  Future<User?> tryAutoLogin() async {
    setLoading(true);
    try {
      var login = await GetIt.I.get<UserService>().loadLogindataLocally();
      User? user;
      if (login.$2) {
        user = await GetIt.I.get<UserService>().loginAnonymously();
        setLoading(false);
        return user;
      }
      if (login.$1 != null) {
        user = await GetIt.I.get<UserService>().login(
          UserCredentials(email: login.$1!.name, password: login.$1!.password),
        );
      }
      setLoading(false);
      return user;
    } catch (e) {
      setLoading(false);
      return null;
    }
  }

  Future<void> loginWithoutAccount() async {
    await userService.loginAnonymously();
  }
}

enum UserGender { female, male }
