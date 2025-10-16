part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

final class UserLoggedIn extends AuthEvent {
  final User user;
  UserLoggedIn(this.user);
}

final class UserLoggedOut extends AuthEvent {}

final class ResetPasswordRequested extends AuthEvent{
  final String email;
  ResetPasswordRequested({required this.email});
}