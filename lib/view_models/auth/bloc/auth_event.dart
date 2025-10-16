part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class UserLoggedIn extends AuthEvent {
  final User user;
  UserLoggedIn(this.user);
}

final class UserLoggedOut extends AuthEvent {
  final User? user;
  UserLoggedOut(this.user);
}

final class Authenticat extends AuthEvent {
  final UserModel user;
  Authenticat(this.user);
}

final class ResetPasswordRequested extends AuthEvent {
  final String email;
  ResetPasswordRequested({required this.email});
}
