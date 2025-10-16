import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meet_christ/pages/forgot_password_page.dart';
import 'package:meet_christ/pages/home.dart';
import 'package:meet_christ/pages/signup/signup_email_page.dart';
import 'package:meet_christ/view_models/auth/bloc/auth_bloc.dart';
import 'package:meet_christ/view_models/login/bloc/login_bloc.dart';
import 'package:meet_christ/view_models/signup/bloc/sign_up_bloc.dart';

class JesusLoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController verifyPasswordController =
      TextEditingController();
  JesusLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      BlocProvider.of<LoginBloc>(context).add(AutoLoginRequested());
      if (kIsWeb || kIsWasm) {
        context.read<LoginBloc>().add(
          LoginInit(email: "stefan.zindl@outlook.de", password: "Jesus10001."),
        );
      } else {
        BlocProvider.of<LoginBloc>(context).add(
          LoginInit(email: "stefan.zindl@outlook.de", password: "Jesus10001."),
        );
      }
    });
    return Scaffold(
      backgroundColor: const Color(0xFFF9EFF9),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is Unauthenticated) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => JesusLoginScreen()),
                );
              }
              if(state is AutoLoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              }
            },
          ),
          BlocListener<LoginBloc, LoginState>(
            listener: (context, state) {
              if (state is LoginSuccess) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              } else if (state is LoginFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              } else if (state is LoginInitialized) {
                emailController.text = state.email;
                passwordController.text = state.password;
              }
            },
          ),
          BlocListener<SignupBloc, SignupState>(
            listener: (context, state) {
              if (state is SignupSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Account created!")),
                );
              } else if (state is SignupFailure) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.error!)));
              }
            },
          ),
        ],
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            return state is LoginInitialized
                ? SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 40.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Title
                          RichText(
                            textAlign: TextAlign.center,
                            text: const TextSpan(
                              children: [
                                TextSpan(
                                  text: "Start your journey with\n",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC4A466),
                                  ),
                                ),
                                TextSpan(
                                  text: "Jesus",
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.redAccent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Email Field
                          _TextFieldWithIcon(
                            label: "Email",
                            icon: Icons.email_outlined,
                            hintText: "email@example.com",
                            obscureText: false,
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          _TextFieldWithIcon(
                            label: "Password",
                            icon: Icons.lock_outline,
                            hintText: "Password",
                            obscureText: true,
                          ),
                          const SizedBox(height: 4),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: state.rememberMe,
                                  onChanged: (value) {
                                    context.read<LoginBloc>().add(
                                      RememberMeChanged(value ?? false),
                                    );
                                  },
                                ),
                                const Text("Remember Me"),
                              ],
                            ),
                          ),

                          // Forgot Password
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage(
                                    email: emailController.text,
                                  ),
                                ),
                              );
                            },
                            child: const Text(
                              "Forgot Password?",
                              style: TextStyle(
                                color: Color(0xFFC4A466),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () {
                              context.read<LoginBloc>().add(
                                LoginRequested(
                                  emailController.text,
                                  passwordController.text,
                                  state.rememberMe,
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFEFEFEF),
                              foregroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFFC4A466),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // OR
                          const Center(
                            child: Text(
                              "or",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Sign Up Button
                          BlocBuilder<SignupBloc, SignupState>(
                            builder: (context, state) {
                              return ElevatedButton(
                                onPressed: () {
                                  context.read<SignupBloc>().add(
                                    InitSignup(email: emailController.text),
                                  );
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SignupEmailPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFFC4A466),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                ),
                                child: const Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Login without account
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                BlocProvider.of<LoginBloc>(
                                  context,
                                ).add(LoginWithoutAccountRequested());
                              },
                              child: const Text(
                                "Login without an account",
                                style: TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}

class _TextFieldWithIcon extends StatefulWidget {
  final String label;
  final IconData icon;
  final String hintText;
  bool obscureText;

  _TextFieldWithIcon({
    required this.label,
    required this.icon,
    required this.hintText,
    required this.obscureText,
  });

  @override
  State<_TextFieldWithIcon> createState() => _TextFieldWithIconState();
}

class _TextFieldWithIconState extends State<_TextFieldWithIcon> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.label == "Email"
          ? (context.findAncestorWidgetOfExactType<JesusLoginScreen>()
                    as JesusLoginScreen)
                .emailController
          : (context.findAncestorWidgetOfExactType<JesusLoginScreen>()
                    as JesusLoginScreen)
                .passwordController,
      obscureText: widget.obscureText,
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: Icon(widget.icon),
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() {
              widget.obscureText = !widget.obscureText;
              print("obscured is now ${widget.obscureText}");
            });
          },
          child: const Icon(Icons.remove_red_eye_outlined),
        ),
      ),
    );
  }
}
