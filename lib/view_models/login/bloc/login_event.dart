part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginRequested extends LoginEvent {
  final String email;
  final String password;

  LoginRequested(this.email, this.password);
}

class LoginWithoutAccountRequested extends LoginEvent {}

// New event for initialization
class LoginInit extends LoginEvent {
  final String email;
  final String password;

  LoginInit({
    required this.email,
    required this.password,
  });
}
