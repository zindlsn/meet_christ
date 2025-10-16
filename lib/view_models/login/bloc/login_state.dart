part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;

  LoginSuccess(this.user);
}

class AutoLoginSuccess extends LoginState {
  final User user;

  AutoLoginSuccess(this.user);
}


class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}

// New state for initialized values
class LoginInitialized extends LoginState {
  final String email;
  final String password;
  final bool rememberMe;
  final bool isLoading;
  final bool isLoggingIn;

  LoginInitialized({
    required this.email,
    required this.password,
    required this.rememberMe,
    this.isLoading = false,
    this.isLoggingIn = false,
  });
}

class LoginWithoutAccountSuccess extends LoginState {
  final UserModel user;

  LoginWithoutAccountSuccess({required this.user});
}

class LoginDataLoaded extends LoginState {
  final String email;
  final String password;
  final bool rememberMe;

  LoginDataLoaded({
    required this.email,
    required this.password,
    required this.rememberMe,
  });
}