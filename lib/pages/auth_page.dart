// ignore_for_file: must_be_immutable

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:http/http.dart' as http;
import 'package:meet_christ/models/user.dart';
import 'package:meet_christ/pages/home.dart';
import 'package:meet_christ/pages/signup/signup_email_page.dart';
import 'package:meet_christ/view_models/auth_view_model.dart';
import 'package:provider/provider.dart';

class CustomAuthPage extends StatefulWidget {
  final Future<bool> Function(LoginInfo) onLogin;
  final Future<void> Function() onSignup;
  final Future<void> Function() onForgotPassword;
  const CustomAuthPage({
    super.key,
    required this.onLogin,
    required this.onSignup,
    required this.onForgotPassword,
  });

  @override
  State<CustomAuthPage> createState() => _CustomAuthPageState();
}

class _CustomAuthPageState extends State<CustomAuthPage> {
  bool _isPasswordVisible = true;
  bool _isEmailVisible = true;
  bool _loginSuccess = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    _emailController.text = context.read<AuthViewModel>().email;
    _passwordController.text = context.read<AuthViewModel>().password;
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurpleAccent,
                ),
                children: [
                  TextSpan(text: 'Start your journey with '),
                  TextSpan(
                    text: 'Jesus',
                    style: TextStyle(color: Colors.orangeAccent),
                  ),
                ],
              ),
            ),
            Form(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _emailController,
                        obscureText: !_isEmailVisible,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isEmailVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _isEmailVisible = !_isEmailVisible;
                              });
                            },
                          ),
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
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
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        widget.onForgotPassword();
                      },
                      child: Text("Forgot Password?"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.deepPurpleAccent,
                      ),
                      onPressed:
                          context.read<ConnectivityViewModel>().isOnline == true
                          ? null
                          : () async {
                              _loginSuccess = await widget.onLogin(
                                LoginInfo(
                                  email: _emailController.text,
                                  password: _passwordController.text,
                                ),
                              );

                              setState(() {});
                            },
                      child: Text('Login'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                      child: Text("or"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                        backgroundColor: Colors.deepPurpleAccent,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          context.read<ConnectivityViewModel>().isOnline == true
                          ? null
                          : () {
                              widget.onSignup();
                            },
                      child: Text('Sign Up'),
                    ),
                    GestureDetector(
                      onTap: () async {
                        await context
                            .read<AuthViewModel>()
                            .loginWithoutAccount();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(indexTab: 0),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          "Login without an account",
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  @override
  void initState() {
    Future.microtask(() async {
      final authViewModel = context.read<AuthViewModel>();
      await authViewModel.loadStoredLogindata();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var titleTag = "login";
    bool isOnline = context.watch<ConnectivityViewModel>().isOnline ?? true;
    bool loginSuccess = false;
    return Scaffold(
      body: Consumer<AuthViewModel>(
        builder: (context, model, child) {
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
                  if (isOnline) {
                    return showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text("Info"),
                          content: Text("You are already logged in."),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    if (await model.login(loginData.name, loginData.password) ==
                        true) {
                      loginSuccess = true;
                      return null;
                    } else {
                      loginSuccess = false;
                      return "Username or password incorrect";
                    }
                    if (context.read<ConnectivityViewModel>().isOnline ==
                        false) {
                      return "Check internet connection";
                    }
                    if (context.read<ConnectivityViewModel>().isOnline ==
                        true) {
                      if (await model.login(
                            loginData.name,
                            loginData.password,
                          ) ==
                          true) {
                        return null;
                      } else {
                        return "Login failed";
                      }
                    }
                    return null;
                  }
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
                    return model.errorMessage ?? "Signup failed";
                  }
                },
                loginAfterSignUp: false,
                onSubmitAnimationCompleted: () {
                  if (titleTag == "login" && loginSuccess) {
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
        print("User");
        print(user.toString());
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
          return Scaffold(
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        return user == null
            ? CustomAuthPage(
                onLogin: (loginInfo) async {
                  value.setEmail(loginInfo.email);
                  value.setPassword(loginInfo.password);
                  bool succuss = await value.login(
                    loginInfo.email,
                    loginInfo.password,
                  );
                  if (succuss) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(indexTab: 0),
                      ),
                    );
                  }
                  return succuss;
                },
                onSignup: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SignupEmailPage()),
                  );
                  return Future<void>.value();
                },
                onForgotPassword: () async {
                  return Future<void>.value();
                },
              )
            : HomePage(
                indexTab: 0,
              ); //HomePage(indexTab: 3) : HomePage(indexTab: 0)
      },
    );
  }
}

class LoginInfo {
  final String email;
  final String password;

  LoginInfo({required this.email, required this.password});
}
