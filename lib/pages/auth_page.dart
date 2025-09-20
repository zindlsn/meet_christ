// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'package:meet_christ/models/user.dart';
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
          model.loadStoredLogindata();
          return Stack(
            children: [
              FlutterLogin(
                titleTag: "login",
                savedEmail: model.email,
                savedPassword: model.password,
                onResendCode: (code) {
                  return null;
                },
                onLogin: (loginData) async {
                  if (await model.login(loginData.name, loginData.password) ==
                      true) {
                    return null;
                  } else {
                    return "Username or password incorrect";
                  }
                  if (context.read<ConnectivityViewModel>().isOnline == false) {
                    return "Check internet connection";
                  }
                  if (context.read<ConnectivityViewModel>().isOnline == true) {
                    if (await model.login(loginData.name, loginData.password) ==
                        true) {
                      return null;
                    } else {
                      return "Login failed";
                    }
                  }
                  return null;
                },
                onRecoverPassword: (password) {
                  return null;
                },
                initialAuthMode: AuthMode.login,
                onSignup: (loginData) async {
                  model.setEmail(loginData.name ?? "");
                  model.setPassword(loginData.password ?? "");
                  var isSuccess = await model.signUp();
                  if (isSuccess) {
                    return null;
                  } else {
                    return "error signup";
                  }
                },
                validateUserImmediately: true,
                loginAfterSignUp: false,

                onSubmitAnimationCompleted: () {
                  if (titleTag == "login") {
                    Navigator.pushReplacement(
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
  ConnectivityBanner({super.key});
  SnackBar? snackBar;
  @override
  Widget build(BuildContext context) {
    return Selector<ConnectivityViewModel, bool?>(
      selector: (_, vm) => vm.isOnline,
      builder: (context, isOnline, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (isOnline == true) {
            snackBar = SnackBar(
              content: Text('Wieder online', style: TextStyle(fontSize: 12)),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar!);
          } else if (isOnline == false) {
            //show offline snackbar indefinitely
            snackBar = SnackBar(
              content: Text(
                'Keine Internetverbindung',
                style: TextStyle(fontSize: 12),
              ),
              backgroundColor: Colors.redAccent,
              duration: const Duration(days: 2),
            );
            ScaffoldMessenger.of(context).showSnackBar(snackBar!);
          }
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
  bool initCheck = false;

  Future<void> init() async {
    final nowOnline = await _checkInternet();
    if (_isOnline != null && nowOnline) {
      _isOnline = true;
    } else if (!nowOnline) {
      _isOnline = false;
    }
    _sub = _connectivity.onConnectivityChanged.listen((_) async {
      final nowOnline = await _checkInternet();
      if (_isOnline != null && nowOnline) {
        _isOnline = true;
      } else if (!nowOnline) {
        _isOnline = false;
      }
      notifyListeners();
      /*if (!initCheck) {
        notifyListeners();
        initCheck = true;
        return;
      }
      if (isOnline == null && nowOnline) {
        _isOnline = null;
        notifyListeners();
        return;
      }
      if (isOnline == null && !nowOnline) {
        _isOnline = false;
        notifyListeners();
      } else if (isOnline == false && nowOnline) {
        //went online
        _isOnline = true;
        notifyListeners();
      }
      if (isOnline == true && !nowOnline) {
        //went offline
        _isOnline = false;
        notifyListeners();
      } */
    });
  }

  Future<bool> _checkInternet() async {
    final result = await _connectivity.checkConnectivity();
    if (result.any((element) => element == ConnectivityResult.none)) {
      return false;
    }
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

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  User? user;
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      final conn = context.read<ConnectivityViewModel>();
      await conn.init();
      if (conn.isOnline == null) {
        user = await context.read<AuthViewModel>().tryAutoLogin();
        setState(() {
          user = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, value, child) {
        if (value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        return user == null
            ? const AuthPage()
            : HomePage(
                indexTab: 0,
              ); //HomePage(indexTab: 3) : HomePage(indexTab: 0)
      },
    );
  }
}
