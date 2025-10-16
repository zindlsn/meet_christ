part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  LoginRequested(this.email, this.password, this.rememberMe);
}

class LoginWithoutAccountRequested extends LoginEvent {}

final class UpdateLoginFields extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  UpdateLoginFields({
    required this.email,
    required this.password,
    required this.rememberMe,
  });
}

// New event for initialization
class LoginInit extends LoginEvent {
  final String email;
  final String password;

  LoginInit({required this.email, required this.password});
}

class RememberMeChanged extends LoginEvent {
  final bool rememberMe;

  RememberMeChanged(this.rememberMe);
}

class LoadLoginData extends LoginEvent {
  final String email;
  final String password;
  final bool rememberMe;

  LoadLoginData({
    required this.email,
    required this.password,
    required this.rememberMe,
  });
}

class TryAutoLoginRequested extends LoginEvent {
  TryAutoLoginRequested();
}
