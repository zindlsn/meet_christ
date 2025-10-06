part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class Authenticated extends AuthState {
  final UserModel user;
  Authenticated(this.user);
}

final class Unauthenticated extends AuthState {}
