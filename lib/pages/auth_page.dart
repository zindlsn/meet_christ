import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
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
          return Stack(
            children: [
              ConnectivityBanner(),
              FlutterLogin(
                titleTag: "login",
                savedEmail: "szindl@posteo.de",
                savedPassword: "Jesus1000.",
                onResendCode: (code) {
                  return null;
                },
                onLogin: (loginData) async {
                  model.setEmail(loginData.name);
                  model.setPassword(loginData.password);
                  await model.login();
                  return null;
                },
                onRecoverPassword: (password) {
                  return null;
                },
                onConfirmSignup: (text, loginData) {
                  model.setEmail(loginData.name);
                  model.setPassword(loginData.password);
                  model.signUp();
                  return null;
                },
                initialAuthMode: AuthMode.login,
                onSignup: (loginData) async {
                  model.setEmail(loginData.name ?? "");
                  model.setPassword(loginData.password ?? "");
                  await model.signUp();
                  return null;
                },
                validateUserImmediately: true,
                loginAfterSignUp: true,
                onSubmitAnimationCompleted: () {
                  if (titleTag == "login") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(indexTab: 0),
                      ),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class ConnectivityBanner extends StatelessWidget {
  const ConnectivityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Selector<ConnectivityViewModel, bool?>(
      selector: (_, vm) => vm.isOnline,
      builder: (context, isOnline, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final snackBar = SnackBar(
            content: Text(
              isOnline == null
                  ? ''
                  : (isOnline ? 'Wieder online' : 'Offline'),
            ),
            backgroundColor: isOnline == true ? Colors.green : Colors.red,
            duration: const Duration(days: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        });
        return const SizedBox.shrink();
      },
    );
  }
}

class ConnectivityViewModel extends ChangeNotifier {
  final _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>>? _sub;

  bool? _isOnline;
  bool? get isOnline => _isOnline;

  Future<void> init() async {
    _isOnline = await _checkInternet();
    _sub = _connectivity.onConnectivityChanged.listen((_) async {
      final nowOnline = await _checkInternet();
      if (isOnline == null && !nowOnline) {
        _isOnline = false;
        notifyListeners();
      } else if (!isOnline! && nowOnline) {
        //went online
        _isOnline = true;
        notifyListeners();
      }
      if (isOnline! && !nowOnline) {
        //went offline
        _isOnline = false;
        notifyListeners();
      }
    });
  }

  Future<bool> _checkInternet() async {
    final result = await _connectivity.checkConnectivity();
    if (result.any((element) => element == ConnectivityResult.none))
      return false;
    try {
      final r = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 3));
      return r.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
