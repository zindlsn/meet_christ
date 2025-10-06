part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final User user;

  LoginSuccess(this.user);
}

class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}

// New state for initialized values
class LoginInitialized extends LoginState {
  final String email;
  final String password;

  LoginInitialized({
    required this.email,
    required this.password,
  });
}

class LoginWithoutAccountSuccess extends LoginState {
  final UserModel user;

  LoginWithoutAccountSuccess({required this.user});
}